-- scratches_mod / paint.lua  (GELUA)
-- Game-engine-side painter. Owns the Dynamic Decals projection per player vehicle.
-- Loads editor_api_dynamicDecals, auto-sets the dynamicTextures skin on
-- supported vehicles, turns scratches_detect batches (M.ingest) into
-- projection jobs drained under a per-frame budget, and composites the canvas
-- only when it changed.

local M = {}

local logTag = "scratches.paint"

-- ---- debug log ring buffer (Phase 1.1) ----
-- Every mod log line is mirrored into a fixed-size ring so the in-panel log
-- pane and the one-click "Copy debug report" can show recent activity without
-- a console session. The local `log` below shadows the global logger for the
-- rest of this file, so every existing log() call site is captured for free.
local LOG_RING_MAX = 240
-- Lines dropped per overflow. Trimming in blocks keeps the ring O(1) amortized
-- per push; table.remove(logRing, 1) shifts the whole array on every line once
-- the ring is full, which is exactly when a crash is generating the most log
-- traffic. Ring depth therefore floats between MAX-TRIM and MAX.
local LOG_RING_TRIM = 60
local logRing      = {}   -- {seq, t, lvl, src, msg}; oldest at [1], newest at [#]
local logRingSeq   = 0    -- monotonic id, survives drops — used for display/diff
local _log         = log  -- the real global logger, captured before shadowing

-- Append one line to the ring, dropping the oldest block when full.
local function ringPush(lvl, src, msg)
  logRingSeq = logRingSeq + 1
  logRing[#logRing + 1] = { seq = logRingSeq, t = os.clock(), lvl = lvl, src = src, msg = msg }
  local n = #logRing
  if n > LOG_RING_MAX then
    -- Shift the surviving tail down once, then nil the vacated slots.
    for i = 1, n - LOG_RING_TRIM do logRing[i] = logRing[i + LOG_RING_TRIM] end
    for i = n - LOG_RING_TRIM + 1, n do logRing[i] = nil end
  end
end

-- Shadow the global `log`. Every log(level, tag, msg) call in this file now
-- also lands in the ring tagged src='GE'. Args are coerced defensively — a
-- stray nil/non-string must never break logging or capture.
local function log(level, tag, msg)
  ringPush(level or 'I', 'GE', tostring(msg))
  _log(level, tag, msg)
end

-- ---- state ----
local adapter = nil
local adapterModule = nil
local soilColor = dofile("/lua/ge/extensions/scratches/soilColor.lua")
-- Paint / rubber left on the road. Optional: a load failure leaves it nil and
-- every call site is guarded.
local groundPaint
do
  local ok, mod = pcall(dofile, "/lua/ge/extensions/scratches/groundPaint.lua")
  if ok and type(mod) == "table" then groundPaint = mod end
end
-- Contact-patch wear (see patches.lua): contacts fold into patches and each
-- patch is painted as one decal. `now` advances with real frame time so the
-- mock harness can step it; `warm` lists brush sets not yet loaded this
-- session (a texture's first use costs ~15 ms inside the native bake).
local patchModule = dofile("/lua/ge/extensions/scratches/patches.lua")
local wear = { on = true, agg = patchModule.new(), now = 0, kick = false, frame = 0,
               warm = nil, warmed = {}, painted = 0, warmedCount = 0, last = {}, hotKey = nil }
local adapterReloaded = {}
local editorPaused = false
local api               = nil    -- editor_api_dynamicDecals module
local ready             = false  -- decals projection bound, skin set, ready to bake
local pendingSetup      = false  -- want setup but haven't succeeded yet
local setupAttemptTimer = 0      -- seconds since last attempt
local SETUP_RETRY       = 1.0    -- seconds between retry attempts
local ownedSkins        = {}     -- only skins selected by this extension instance
local lastSkinJBeam     = nil    -- last vehicle jbeam we successfully set skin on

-- Material-binding stabilization state. BeamNG's setVehicleMaterialJob runs
-- as a coroutine that yields after start, so its setMaterialIdx call lands
-- one or more frames AFTER our setup completes — and it clobbers anything we
-- did synchronously. To get reliable multi-material binding we instead:
--   1. Compute desiredMatIndices once at setup using scenetree.findObject
--      (the same check BeamNG uses internally at dynamicDecals.lua:1999).
--   2. Each onUpdate tick, additively ensure every desired index is bound.
--      That cooperates with BeamNG's job instead of racing it — once both
--      sides have run, bindings = our desired set.
--   3. Once stable (one tick where every desired index is present), we run
--      the canvas seed. Doing it earlier risks the seed writing to the
--      wrong material (the projection's initial materialIdx is 0).
local desiredMatIndices = nil
local matBindingsStable = false
local seedDone          = false

-- ---- per-frame discrete-stamp batching ----
-- stampAtLocal records a raw input descriptor here (no api calls, no project,
-- no getDecalData) and returns immediately. onUpdate drains the queue with
-- shared-camera batching: cluster the inputs by spatial proximity, project
-- ONCE per cluster (was once per stamp), call getDecalData per stamp under the
-- shared camera, and bake the lot in a single bakeLayers call.
--   1 project / cluster (was N), 1 bake / frame, N getDecalData (cheap — no
--   render pass), N setDecalLocalPos (cheap — unproject math).
-- Stream path is separate (it already batches its sub-strokes per stream).
local pendingStampInputs   = {}
local pendingStampsVid     = nil   -- vehicle id the queued stamps belong to (drop on vehicle switch)
local AGGREGATE_PER_FRAME_CAP = 160 -- stamps held per flush batch; further enqueues drop
-- Greedy spatial-cluster radius (vehicle-local meters). Stamps within this
-- distance share a project camera. Bigger = fewer clusters = fewer projects;
-- too big and the shared cam can land on the wrong panel for off-axis stamps.
-- Keep this tighter than a full roof/side span: realism beats a few saved
-- projection passes here, because an over-broad cluster can aim through a roof
-- edge and paint side/rear panels that never touched the ground.
local CLUSTER_RADIUS         = 0.65

-- ---- variation: brush recency avoidance ----
-- Bounded family history plus a short diagnostic ring. A family never picks
-- its immediately preceding brush, even across intervening haze picks.
local recentBrushes    = {}
local RECENT_BRUSH_MAX = 3

-- Per-brush scale bias for discrete stamps. Chips are dense, so they read at
-- a slightly smaller size than the gouges. Path -> multiplier.
local BRUSH_SCALE_BIAS = {
  ["/art/dynamicDecals/textures/scr_chips_01.png"] = 0.85,
  ["/art/dynamicDecals/textures/scr_chips_02.png"] = 0.85,
}

-- Luminance (0..1) of the current car's paint, set when the base fill is
-- seeded. Damage reads light on dark paint and dark on light paint.
local paintLum = 0.3

-- ---- paint-side stats (D) ----
-- Visibility for what the system did per session. Replaces the per-stamp
-- log line we silenced; dumpPaintStats prints the aggregate.
local stampStats = {
  stampsAttempted     = 0,
  stampsEnqueued      = 0,
  stampsSkippedMissed = 0,
  aggregateDropped    = 0,
  framesFlushed       = 0,
  bakesIssued         = 0,
  bakeFailures        = 0,
  layersLost          = 0,
  projectsIssued      = 0,  -- (F) shared-camera projects/frame; was N
  clustersTotal       = 0,
  clusterJobsMerged   = 0,  -- (F) total clusters across flushed frames
  streamsBaked        = 0,
  streamSubstrokesTotal = 0,
  streamLayersExpected = 0,
  streamLayersMissed = 0,
  jobsDropped         = 0,  -- projection jobs refused because the backlog was full
  jobsFailed          = 0,  -- projection jobs that threw (logged, then skipped)
  framesDeferred      = 0,  -- frames that hit the projection budget with work left over
  foreignDropped      = 0,  -- batches from a vehicle that isn't the player car
  combinesRun         = 0,  -- composites actually run (light or full)
  rebinds             = 0,  -- of those, full api.onUpdate_ texture-set re-binds
  spotsSkipped        = 0,  -- marks skipped: that spot was already painted enough
  streamsMerged       = 0,  -- slides that shared another slide's projection
  framesTicked        = 0,  -- ready frames seen (combinesRun / framesTicked = combine rate)
}
-- The painter's own CPU cost per ready frame, in ms (os.clockhp). Cheap enough
-- to leave on: two clock reads per frame, a few more while there is work. The
-- debug panel's imgui draw is excluded so opening the panel doesn't skew it.
local clockhp = os.clockhp or os.clock
local nativeEvents = {}
-- Bounded call histograms: 0.1 ms bins through 100 ms, 1 ms through 1000 ms,
-- then one overflow bin. Read separately so per-frame snapshots stay small.
local nativeProfiles = {project={bins={},count=0,maxMs=0},bakeBatch={bins={},count=0,maxMs=0}}
local perfStats = {
  frames = 0, lastMs = 0, msTotal = 0, msMax = 0,
  framesOver1ms = 0, framesOver4ms = 0,
  flushMsTotal = 0, flushMsMax = 0,     -- projection + bake (flushPendingStamps)
  combineMsTotal = 0, combineMsMax = 0, -- syncAndCombine composites
  -- Flush breakdown: synthetic-camera projection passes, per-layer capture
  -- (getDecalData + cursor moves), and the bakeLayers call.
  projectMsTotal = 0, projectMsMax = 0, projectCalls = 0,
  layerMsTotal = 0, layerCalls = 0,
  bakeMsTotal = 0, bakeMsMax = 0, bakeCalls = 0, bakeLayersTotal = 0,
  inputToBakeMaxMs = 0, inputToProjectMaxMs = 0,
  -- Detector batches arrive outside onUpdate, so they are timed separately.
  ingestMsTotal = 0, ingestMsMax = 0, ingestCalls = 0,
}

-- Add the time since t0 (os.clockhp seconds) to perfStats[totalKey], track
-- the max in perfStats[maxKey] if given, bump perfStats[countKey] if given.
local function perfAdd(t0, totalKey, maxKey, countKey, layers)
  local ended=clockhp()
  local ms = (ended - t0) * 1000
  if maxKey=="projectMsMax" or maxKey=="bakeMsMax" then
    local profile=nativeProfiles[maxKey=="projectMsMax" and "project" or "bakeBatch"]
    local bin=math.max(1,ms<=100 and math.ceil(ms*10) or math.min(1901,1000+math.ceil(ms-100)))
    profile.bins[bin]=(profile.bins[bin] or 0)+1
    profile.count=profile.count+1;profile.maxMs=math.max(profile.maxMs,ms)
  end
  if ms>=50 and (maxKey=="projectMsMax" or maxKey=="bakeMsMax") then
    if #nativeEvents>=32 then table.remove(nativeEvents,1) end
    nativeEvents[#nativeEvents+1]={stage=maxKey=="projectMsMax" and "project" or "bake",started=t0,ended=ended,ms=ms,layers=layers}
  end
  perfStats[totalKey] = perfStats[totalKey] + ms
  if maxKey and ms > perfStats[maxKey] then perfStats[maxKey] = ms end
  if countKey then perfStats[countKey] = perfStats[countKey] + 1 end
end
local stampVerbose = false  -- when true, the old per-stamp log line returns

-- (K) Live debug + tuning IMGUI panel. drawUI runs from onUpdate when
-- uiVisible is true. lastDetectStats is the most recent snapshot pushed
-- from detect.lua (every ~0.25s); paint-side stats live in stampStats.
-- uiPtrs holds persistent ImGui FloatPtr/IntPtr objects for the sliders;
-- created lazily once ui_imgui is loaded so module load doesn't depend on
-- the imgui module being available yet.
local uiVisible       = false
local lastDetectStats = {}
local uiPtrs          = nil
local uiClosePtr      = nil  -- BoolPtr the window's [x] button writes to

-- Forward declarations so the paint-fill helper (defined right after trySetup
-- so it can be called from setup) can reach these. The actual assignments
-- live further down where the synthetic-camera stamping logic is grouped.
local decalProjection      = nil
local resolveDecalProjection
local setScratchProjectionFence
-- Spawn-local AABB cache (see getSpawnAabb). Declared up here, not next to
-- getSpawnAabb, because onVehicleSwitched / onExtensionUnloaded reset it and
-- are defined earlier in the file — a later `local` would be invisible to
-- them and they'd index a nil global.
local spawnAabbCache       = { vid = nil, box = nil }

-- ---- texture-combine gating ----
-- api.onUpdate_ is meant to run every frame. Nearly all of its cost is one
-- call: re-binding the dynamic texture set to the car's materials
-- (veh:setTextureSet), measured at 24-55 ms per call on a sunburst. Its other
-- work - projection shape, transforms, and combineTextures (the canvas
-- composite) - measures ~0 ms. So:
--   * composite only when we baked or cleared (combineDirty), and
--   * re-bind only when the binding can actually be stale (rebindDirty): at
--     setup, and when our car spawns, resets, or is switched to, or after a
--     clear. Every other composite takes the light path (shape + transforms +
--     combineTextures), which avoids that repeated rebind cost.
-- fullRateCombine restores the API's every-frame full update for diagnosis.
local combineDirty         = true
local rebindDirty          = true
local fullRateCombine      = false
local sinceCombine         = 0      -- seconds since the last composite
local framesSinceCombine   = 0
local apiApp               = nil    -- the API's private `app` (texture set holder)

-- Earlier samples measured a more expensive first projection than subsequent
-- passes in a frame. Batch nearby work to amortize that observed cost; this is
-- not a native latency bound or proof of a particular synchronization cause.
-- New marks accumulate up to FLUSH_INTERVAL; the first after idle flushes now.
local FLUSH_INTERVAL       = 0.20   -- seconds between projection batches (tunable)
local sinceFlush           = math.huge

-- Recently painted spots, in a coarse vehicle-local grid. A slide keeps the
-- same body point on the ground and the detector re-sends it every 0.25 s, so
-- a 4.5 s slide used to repaint each contact spot ~18 times: ~1 ms of bake per
-- layer each time, with nothing visible changing after the first couple of
-- passes. Each spot takes a few passes (later ones scrape deeper), then
-- further marks there are skipped until the canvas is cleared.
local SPOT_CELL       = 0.08  -- m
local SPOT_MAX_SLIDE  = 2
local SPOT_MAX_IMPACT = 2
local spotHits        = {}
-- Returns this spot's pass number (1..maxHits), or nil once it's saturated.
local function spotTake(p, kind, maxHits)
  local k = kind .. math.floor(p.x / SPOT_CELL) .. ":" .. math.floor(p.y / SPOT_CELL)
            .. ":" .. math.floor(p.z / SPOT_CELL)
  local n = (spotHits[k] or 0) + 1
  if n > maxHits then
    stampStats.spotsSkipped = stampStats.spotsSkipped + 1
    return nil
  end
  spotHits[k] = n
  return n
end

-- Player vehicle id we must not retry setup on (unsupported, or liveried and
-- intentionally skipped). Without it every traffic spawn re-ran setup and
-- re-logged the same skip warning.
local skippedVid           = nil

-- ---- paint canvas seed tunables ----
-- The dynamic-decals skin reroutes baseColor + metallic + roughness onto the
-- engine-managed @DynamicTexture* canvas. We KEEP baseColor on the canvas
-- (scratches need to write it, and the projection-free `fill` layer can re-seed
-- it cleanly), but we PUT metallic + roughness BACK on the factory maps via
-- restoreFactoryMR(). That's why this file no longer carries PAINT_METALLIC /
-- PAINT_ROUGHNESS: the seed never writes those channels. Base gloss is whatever
-- the car ships with — factory-perfect and seamless.

-- Whether the seed paints the baseColor fill. Default TRUE — clearBakedTextures
-- zeroes the baseColor channel, so without the fill the body renders black
-- after a clear/reset. Off is debug-only (baseColor left wiped). Liveried cars
-- are skipped entirely by ensureSkin, so @DynamicTextureBaseColor only ever
-- holds a plain paint color we can safely re-stamp.
local PAINT_SEED_COLOR = true

-- ---- one-time setup ----
local function ensureApiLoaded()
  if api then return true end
  if extensions.editor_api_dynamicDecals then
    api = extensions.editor_api_dynamicDecals
    return true
  end
  log('I', logTag, "loading editor_api_dynamicDecals")
  extensions.load("editor_api_dynamicDecals")
  api = extensions.editor_api_dynamicDecals
  if not api then
    log('E', logTag, "extensions.load('editor_api_dynamicDecals') did not produce a module")
    return false
  end
  return true
end

-- (2.1) Read the part currently chosen in the vehicle's "paint_design" slot
-- — the single slot that holds either a livery skin OR our dynamicTextures
-- skin. setSkin() overwrites this slot outright, so whatever livery sits here
-- is evicted by the swap. Diagnostic only: returns the chosenPartName string
-- ("" if the slot is empty/default), or nil if the config isn't readable yet.
local function currentPaintDesignPart()
  if not (extensions.core_vehicle_partmgmt and extensions.core_vehicle_partmgmt.getConfig) then
    return nil
  end
  local ok, cfg = pcall(extensions.core_vehicle_partmgmt.getConfig)
  if not ok or type(cfg) ~= "table" or type(cfg.partsTree) ~= "table" then
    return nil
  end
  local found = nil
  local function walk(node)
    if found ~= nil or type(node) ~= "table" then return end
    if node.id == "paint_design" then
      found = node.chosenPartName or ""
      return
    end
    if type(node.children) == "table" then
      for _, child in pairs(node.children) do walk(child) end
    end
  end
  walk(cfg.partsTree)
  return found
end

-- Auto-select the dynamicTextures skin on the player vehicle if available.
-- Returns true if (a) skin was set or (b) skin is already in use.
-- Returns false if the vehicle's data isn't ready yet (transient — try again next tick).
-- Returns false AND clears pendingSetup if the vehicle is permanently unsupported.
local function ensureSkin(jbeam, vid)
  if not extensions.core_vehicle_partmgmt then
    return false  -- partmgmt not yet loaded; transient
  end
  -- partmgmt.hasAvailablePart() crashes if core_vehicle_manager.getPlayerVehicleData()
  -- returns nil (which happens transiently after Ctrl+L while the vehicle data cache
  -- is being rebuilt). Guard against it.
  if not core_vehicle_manager or not core_vehicle_manager.getPlayerVehicleData
     or not core_vehicle_manager.getPlayerVehicleData() then
    return false  -- vehicle data not yet populated; transient
  end
  local skinPart = jbeam .. "_skin_dynamicTextures"
  local ok, has = pcall(extensions.core_vehicle_partmgmt.hasAvailablePart, skinPart)
  if not ok then
    -- Some other internal error in partmgmt; treat as transient and retry next tick.
    return false
  end
  if not has then
    log('W', logTag, "vehicle '" .. jbeam .. "' has no '" .. skinPart .. "' part; vehicle is unsupported")
    pendingSetup = false  -- stop polling; this vehicle is a permanent no-go
    skippedVid   = vid
    return false
  end
  -- Always inspect the slot: same-model part changes may add a livery.

  -- (2.3) Inspect the paint_design slot before claiming it. BeamNG gives a
  -- vehicle exactly one skin slot and setSkin() overwrites it outright, so
  -- swapping in dynamicTextures evicts any livery sitting there. We refuse to
  -- do that silently: a car the player deliberately liveried is left
  -- untouched (no scratches) rather than stripped.
  -- TODO (future): livery+scratches compositing — capture the livery's
  -- textures and re-stamp them as a base layer in the dynamic canvas so
  -- liveried cars can get scratches too. Until then, preservation wins.
  local prevPart = currentPaintDesignPart()
  if prevPart == nil then
    return false  -- config not readable yet; transient, retry next tick
  end
  if prevPart == skinPart and ownedSkins[vid] == jbeam then
    -- Only a skin we selected in this extension instance is ours to write.
    log('I', logTag, "dynamicTextures skin already active on " .. jbeam)
    lastSkinJBeam = jbeam
    return true
  end
  if prevPart ~= "" then
    ownedSkins[vid] = nil
    log('W', logTag, "vehicle '" .. jbeam .. "' has livery '" .. tostring(prevPart) ..
      "' in the paint_design slot — SKIPPING to preserve it. No scratches on " ..
      "this car (livery+scratches compositing is a planned future feature).")
    pendingSetup = false  -- intentional, permanent skip for this vehicle
    skippedVid   = vid
    return false
  end

  -- Slot is empty: safe to claim it for the dynamic-decals canvas.
  ownedSkins[vid] = jbeam
  extensions.core_vehicle_partmgmt.setSkin("dynamicTextures")
  log('I', logTag, "set skin 'dynamicTextures' on vehicle " .. jbeam)
  lastSkinJBeam = jbeam
  return true
end

-- Walk every material on the active shape and ask the engine whether a
-- corresponding `.skin.dynamicTextures` variant has been registered. This is
-- the same existence check BeamNG itself uses at `dynamicDecals.lua:1999`,
-- so it can't disagree with the actual swap. Returns the list of material
-- INDICES (the keys getShapeMaterialNames returns) for which a variant
-- exists — those are the canvases dynamic decals will actually render onto.
--
-- Why we don't bind here: BeamNG's own setVehicleMaterialJob is a coroutine
-- that resumes after our setup returns and calls setMaterialIdx (singular)
-- using its own heuristic — that would clobber any addMaterialIdx we did
-- synchronously. Instead the caller stashes this list and the per-tick
-- ensureDesiredMaterialsBound() additively re-applies it until both sides
-- have run (typically within 1-2 ticks).
local function computeDesiredMaterials()
  if adapter then return adapter.indices end
  if not api or not api.getShapeMaterialNames then return {} end
  if not scenetree or not scenetree.findObject then return {} end
  local ok, names = pcall(api.getShapeMaterialNames)
  if not ok or type(names) ~= "table" then return {} end
  local desired = {}
  for k, materialName in pairs(names) do
    if type(materialName) == "string" then
      if scenetree.findObject(materialName .. ".skin.dynamicTextures") then
        desired[#desired + 1] = k
      end
    end
  end
  return desired
end

-- Take metallic + roughness OFF the dynamic-decals canvas by pointing the
-- body's skin-variant material at static texture maps. The dynamicTextures
-- skin reroutes baseColor / metallic / roughness onto @DynamicTexture*; we
-- keep baseColor (scratches write it and the `fill` layer re-seeds it
-- cleanly) but redirect metallic and roughness to known constant PNGs. Result:
-- base M/R is uniform across the whole body (no projection seams), and the
-- canvas seed never writes those channels.
--
-- For each body material (the ones with a .skin.dynamicTextures variant),
-- repoint every stage whose metallicMap / roughnessMap reads @DynamicTexture*
-- at the static paths — the same stage scan BeamNG's own "export dynamic skin"
-- path uses (editor/api/dynamicDecals.lua, the `for stage = 0, 3` block that
-- swaps only `value:startswith("@DynamicTexture")` stages). Factory stages
-- (e.g. a stage-0 layer with the car's real _m/_r maps) are left alone, and a
-- material that's already been repointed has no @DynamicTexture stage left,
-- so repeat calls (every clearStamps) skip the reload entirely. Changed
-- materials get flush() + reload() so the renderer picks up the new fields.
-- Other materials (interior, glass, mechanicals) have no skin variant and are
-- skipped silently — they don't render off the dynamic canvas in the first
-- place.
--
-- Static targets: metallic=0 (dielectric paint) via the engine-provided
-- _zero.png, and roughness=0.2 (typical clearcoat) via _paint_roughness.png
-- which ships with this mod (a 4x4 solid 51-grey PNG; linear 51/255 ≈ 0.20).
-- The textures aren't decal brushes so they don't need a .dynDecalTexture.json
-- sidecar — they're regular material maps, loaded by the renderer like any
-- other PBR texture.
--
-- Trade-off: scratch stamps' setMetallicIntensity / setRoughnessIntensity
-- still write to an unused dynamic canvas (harmless no-ops). Scratches read
-- as color marks; no metal-glint. The seam is gone with it.
local function restoreFactoryMR()
  if adapter then return false end
  if not api or not api.getShapeMaterialNames then return false end
  if not scenetree or not scenetree.findObject then return false end
  local ok, names = pcall(api.getShapeMaterialNames)
  if not ok or type(names) ~= "table" then return false end

  local METALLIC_PATH  = "/art/dynamicDecals/textures/_zero.png"
  local ROUGHNESS_PATH = "/art/dynamicDecals/textures/_paint_roughness.png"

  local function isDynamic(value)
    return type(value) == "string" and value:sub(1, 15) == "@DynamicTexture"
  end

  local restored = 0
  for _, matName in pairs(names) do
    if type(matName) == "string" then
      local skinMat = scenetree.findObject(matName .. ".skin.dynamicTextures")
      if skinMat then
        local changed = false
        for stage = 0, 3 do
          if isDynamic(skinMat:getField("metallicMap", stage)) then
            skinMat:setField("metallicMap", stage, METALLIC_PATH)
            changed = true
          end
          if isDynamic(skinMat:getField("roughnessMap", stage)) then
            skinMat:setField("roughnessMap", stage, ROUGHNESS_PATH)
            changed = true
          end
        end

        if changed then
          -- Live-update pattern: setField, then flush() to mark dirty, then
          -- reload() to apply. Both, in that order — reload alone re-reads
          -- the stale state.
          if skinMat.flush  then pcall(function() skinMat:flush()  end) end
          if skinMat.reload then pcall(function() skinMat:reload() end) end
          restored = restored + 1
        end
      end
      -- Non-body materials (no skin variant) are skipped silently — they
      -- don't render off the dynamic canvas, so there's nothing to fix.
    end
  end
  if restored > 0 then
    log('I', logTag, string.format(
      "restoreFactoryMR: %d material(s) had M/R repointed (M=_zero, R=_paint_roughness)",
      restored))
  end
  return restored > 0
end

-- Per-tick stabilizer. Idempotent: each call diffs the current bindings
-- against desiredMatIndices and adds anything missing. Becomes a no-op
-- once everything we want is present (the matBindingsStable latch). When
-- the first stable tick lands, fires the deferred canvas seed so it writes
-- to every dynamic-textures material instead of just whatever was bound
-- when setup returned.
local function ensureDesiredMaterialsBound()
  if matBindingsStable then return end
  if not (api and api.getMaterialIndices and api.addMaterialIdx) then return end
  if not (desiredMatIndices and #desiredMatIndices > 0) then
    -- Nothing to enforce; let BeamNG's heuristic stand and do the seed
    -- one-shot so single-material vehicles still get the baseColor fill.
    if not seedDone then
      restoreFactoryMR()
      M.addPaintFill()
      seedDone = true
    end
    matBindingsStable = true
    return
  end
  local current = api.getMaterialIndices() or {}
  local has = {}
  if type(current) == "table" then
    for _, idx in ipairs(current) do has[idx] = true end
  end
  local addedThisTick = 0
  for _, want in ipairs(desiredMatIndices) do
    if not has[want] then
      api.addMaterialIdx(want)
      addedThisTick = addedThisTick + 1
    end
  end
  if addedThisTick == 0 then
    matBindingsStable = true
    log('I', logTag, string.format(
      "material bindings stable: desired=%d  current=%d",
      #desiredMatIndices, type(current) == "table" and #current or 0))
    if not seedDone then
      restoreFactoryMR()
      M.addPaintFill()
      seedDone = true
    end
  end
end

local function trySetup()
  if ready then return true end
  local veh = getPlayerVehicle(0)
  if not veh then return false end
  local jbeam = veh.JBeam or veh.jbeam
  if not jbeam then return false end
  local vid = veh:getId()
  if vid == skippedVid then pendingSetup = false; return false end

  local part = currentPaintDesignPart()
  if part == nil then return false end -- config not readable yet; retry next tick
  if not adapterModule then adapterModule = dofile("/lua/ge/extensions/scratches/bodyAdapter.lua") end
  if adapterModule.wants(veh, part) then
    if adapterModule.editorActive() then
      editorPaused=true; pendingSetup=false; skippedVid=vid; return false
    end
    if not adapter then
      local ok, result = pcall(adapterModule.create, veh, part)
      if not ok then
        log('E',logTag,"body material adapter failed on " .. jbeam .. ": " .. tostring(result))
        pendingSetup=false; skippedVid=vid; return false
      end
      if not result then
        pendingSetup=false
        if adapterReloaded[vid] then skippedVid=vid; log('W',logTag,"body material adapter unavailable on " .. jbeam .. "; leaving original paint"); return false end
        adapterReloaded[vid]=true
        adapterModule.invalidateConstructionCache()
        veh:reload()
        return false
      end
      adapter = result
    end
    api = adapter.api
  elseif not ensureApiLoaded() or not ensureSkin(jbeam, vid) then
    -- ensureSkin distinguishes transient from permanent failures internally and
    -- clears pendingSetup itself if the vehicle is unsupported. Just bail.
    return false
  end

  -- (K) Make sure ui_imgui is loaded so the debug panel can render the
  -- first time M.toggleUI is called. Idempotent.
  if not ui_imgui then extensions.load("ui_imgui") end

  -- Refresh only after the preservation check; the callback binds textures.
  if api and api.onVehicleSwitched then api.onVehicleSwitched() end
  -- Initialize the API
  api.setup()
  if not api.ready then
    -- api.setup() may need another frame for the projection shape to be available
    log('I', logTag, "api.setup() returned but api.ready is false; will retry next tick")
    return false
  end

  -- The auto-per-frame projectDynamicDecals(playerCam, projM) renders a "live
  -- preview" decal at screen-center every frame using the most recently set
  -- brush/color — looks like an actual stamp that follows the camera. Disable
  -- it. combineTextures() (the actual composite of baked layers into the
  -- output texture set) runs every frame regardless of this flag.
  -- (The earlier theory that disabling this broke visibility on pigeon was
  -- wrong — that was the brush channel-layout bug masking the truth.)
  api.setProjectDynamicDecalsState(false)
  ready = true
  rebindDirty = true
  pendingSetup = false
  log('I', logTag, "decals API initialized for " .. jbeam .. " (layers=" .. tostring(api.getLayerCount and api.getLayerCount() or "?") .. ")")

  -- Discover which materials on this vehicle have a .skin.dynamicTextures
  -- variant. Don't bind them here — BeamNG's coroutine job will run later
  -- with setMaterialIdx (singular) and overwrite us. ensureDesiredMaterialsBound
  -- additively re-applies our desired set each frame until it sticks, then
  -- fires the canvas seed so it lands on every dynamic-textures material.
  desiredMatIndices = computeDesiredMaterials()
  matBindingsStable = false
  seedDone          = false
  log('I', logTag, string.format(
    "discovered %d dynamicTextures material(s) on %s — stabilizing bindings",
    #desiredMatIndices, jbeam))
  return true
end

-- Parse the BeamNG getVehicleColor() string ("r,g,b,a" with floats 0..1) into
-- numeric RGB. Tolerant of either commas or whitespace as separators and of
-- nil / non-string returns (some vehicles or transient states don't expose a
-- color). Returns nil if it can't extract three numbers.
local function parseVehicleColor(s)
  if type(s) ~= "string" or s == "" then return nil end
  local r, g, b = s:match("([%-%d%.]+)[,%s]+([%-%d%.]+)[,%s]+([%-%d%.]+)")
  r, g, b = tonumber(r), tonumber(g), tonumber(b)
  if not (r and g and b) then return nil end
  return r, g, b
end

-- Seed the dynamic-decals canvas with a uniform baseColor.
--
-- metallic + roughness were repointed to the car's factory maps by
-- restoreFactoryMR(), so they aren't on this canvas — that means we don't
-- need (and CAN'T cleanly produce, since projected decals leave silhouette
-- seams) any M/R seeding. The only channel this writes is baseColor, and the
-- projection-free `fill` layer paints every UV texel uniformly (verified —
-- dynamicDecals.lua:301‑306).
--
-- Cost: 1 bake at vehicle spawn, once. Zero per-frame work. Re-runs after
-- clearStamps to repaint baseColor (which clearBakedTextures wipes).
M.addPaintFill = function()
  if adapter then
    local r,g,b=parseVehicleColor(getVehicleColor and getVehicleColor() or nil)
    adapter:damageTone(r and (0.2126*r+0.7152*g+0.0722*b) or nil)
    adapter:clear(); combineDirty=true; return
  end
  if not ready then log('W', logTag, "addPaintFill: not ready"); return end
  if not resolveDecalProjection() then return end
  local veh = getPlayerVehicle(0)
  if not veh then return end

  if not PAINT_SEED_COLOR then
    log('I', logTag, "paint seed: PAINT_SEED_COLOR off — fill skipped (debug)")
    return
  end

  -- Resolve the paint color and paint every UV texel uniformly. M/R is
  -- rendered from the factory maps (see restoreFactoryMR), so a fill is all
  -- the seed needs.
  local r, g, b = 0.5, 0.5, 0.5
  local pr, pg, pb = parseVehicleColor(getVehicleColor and getVehicleColor() or nil)
  if pr then
    r, g, b = pr, pg, pb
    paintLum = math.max(0, math.min(1, 0.2126 * r + 0.7152 * g + 0.0722 * b))
  else
    log('W', logTag, "addPaintFill: getVehicleColor unavailable; using mid-grey fallback")
  end

  decalProjection:bakeLayers({ {
    name              = "scratches_base_color",
    type              = (api.layerTypes and api.layerTypes.fill) or 1,
    blendMode         = (api.blendModesMap and api.blendModesMap.Normal) or 1,
    color             = Point4F(r, g, b, 1),
    colorPaletteMapId = 0,
    enabled           = true,
    locked            = false,
    uid               = string.format("scr-fill-%08x", math.random(0, 0x7fffffff)),
    parentUid         = nil,
    children          = {},
  } }, veh.JBeam or veh.jbeam)
  combineDirty = true

  log('I', logTag, string.format(
    "paint seed: baseColor fill rgb=(%.2f,%.2f,%.2f) (M/R from factory maps)",
    r, g, b))
end

-- PAINT_SEED_COLOR is the only paint-seed tunable now (M/R are factory).
M.setPaintSeedColor = function(b)
  PAINT_SEED_COLOR = b and true or false
end
M.getPaintSeedColor  = function() return PAINT_SEED_COLOR end

-- ---- per-frame ----
-- Forward declarations so onUpdate can call them; the function bodies are
-- defined further down (alongside stampAtLocal for flushPendingStamps;
-- alongside the K probes for drawUI).
local hasPendingBakeRef
local flushPendingStampsRef
local bakePendingRef
local hasPendingWorkRef
local drawUIRef

-- Run the API's per-frame update: re-bind the vehicle's texture set, refresh
-- the projection shape/transforms, and composite the canvas into the
-- vehicle's textures. Gated by onUpdate — see combineDirty.
local function syncAndCombine()
  if api and api.onUpdate_ then api.onUpdate_() end
  combineDirty       = false
  rebindDirty        = false
  sinceCombine       = 0
  framesSinceCombine = 0
  stampStats.combinesRun = stampStats.combinesRun + 1
  stampStats.rebinds     = stampStats.rebinds + 1
end

-- The API keeps its texture-set holder as a module-local; pluck it from the
-- onUpdate_ closure the same way decalProjection is resolved.
local function resolveApiApp()
  if apiApp then return apiApp end
  if not (api and api.onUpdate_) then return nil end
  local i = 1
  while true do
    local name, val = debug.getupvalue(api.onUpdate_, i)
    if not name then break end
    if name == "app" then apiApp = val; return val end
    i = i + 1
  end
  return nil
end

-- What api.onUpdate_ does minus the texture-set re-bind: refresh the
-- projection shape (it deforms in a crash) and the car's transforms.
local function syncShape(veh)
  decalProjection:setShape(veh:getDecalProjectionShape())
  local m = veh:getRefNodeMatrix()
  decalProjection:setWorldTransform(m)
  decalProjection:setTransform(m:copy():setPosition(vec3(0, 0, 0)):inverse())
end

-- Composite the canvas into the car's textures, re-binding only if needed.
local function composite()
  local veh = getPlayerVehicle(0)
  local app = resolveApiApp()
  if rebindDirty or fullRateCombine or not (veh and app and app.textureSet
      and decalProjection and veh.getDecalProjectionShape) then
    syncAndCombine()
    return
  end
  syncShape(veh)
  decalProjection:combineTextures(app.textureSet)
  combineDirty       = false
  sinceCombine       = 0
  framesSinceCombine = 0
  stampStats.combinesRun = stampStats.combinesRun + 1
end

-- Washable exposure state is deliberately separate from irreversible baked
-- decals. Never clear the scratch canvas to simulate washing.
local surfaceState = {mud=0, dirt=0, snow=0, wetness=0, deposits=0, waterSupported=false}
local surfaceWaterAge = 1
local soilRemaining, waterFraction = 1, 0
local surfaceSpots = {}
local function resetSurfaceState()
  surfaceState = {mud=0, dirt=0, snow=0, wetness=0, deposits=0, waterSupported=false}
  surfaceSpots, surfaceWaterAge = {}, 1
  soilRemaining, waterFraction = 1, 0
end
M.getSurfaceState = function()
  local out = {}
  for k,v in pairs(surfaceState) do out[k] = v end
  out.soilRemaining = soilRemaining
  out.waterFraction = waterFraction
  out.visualCleaningSupported = adapter ~= nil
  out.visualWetnessSupported = adapter ~= nil
  return out
end
local function updateSurface(dt)
  dt = math.max(0, math.min(0.25, tonumber(dt) or 0))
  surfaceWaterAge = surfaceWaterAge + dt
  if surfaceWaterAge <= 0.5 then
    surfaceState.wetness = math.min(1, surfaceState.wetness + dt * 0.8 * waterFraction)
    if adapter and surfaceState.deposits > 0 then
      soilRemaining = math.max(0,soilRemaining-dt*waterFraction/8)
      if soilRemaining == 0 then
        adapter:clearSoil()
        surfaceSpots = {}
        surfaceState.deposits = 0
        soilRemaining = 1
      end
    end
    for _, k in ipairs({"mud","dirt","snow"}) do
      surfaceState[k] = math.max(0, surfaceState[k] - dt * 0.15)
    end
  else
    waterFraction = 0
    surfaceState.wetness = math.max(0, surfaceState.wetness - dt / 20)
  end
  if adapter then adapter:appearance(surfaceState.wetness,soilRemaining) end
end

local materialCleanupPending = true
local function onUpdate(dtReal, dtSim, dtRaw)
  if groundPaint then pcall(groundPaint.update, dtSim) end
  if materialCleanupPending and adapterModule then
    materialCleanupPending = not adapterModule.collectUnusedMaterials()
  end
  if editorPaused and adapterModule and not adapterModule.editorActive() then
    editorPaused=false; skippedVid=nil; pendingSetup=true; setupAttemptTimer=SETUP_RETRY
  end
  if adapter and adapterModule.editorActive() then
    adapter:detach(); adapter=nil; api=nil
    resetSurfaceState()
    ready=false; pendingSetup=false; editorPaused=true
    local veh=getPlayerVehicle(0)
    skippedVid=veh and veh:getId()
    pendingStampInputs={}; M._dropQueuedJobs()
    decalProjection=nil; apiApp=nil
    return
  end
  if ready then
    local t0 = clockhp()
    updateSurface(dtSim)
    stampStats.framesTicked = stampStats.framesTicked + 1
    sinceCombine       = sinceCombine + (dtReal or 0)
    framesSinceCombine = framesSinceCombine + 1
    -- Stabilize material bindings before stamps. BeamNG's coroutine job lands
    -- a frame or two after setup; this re-applies our desired set until it
    -- sticks, then fires the deferred canvas seed. Cheap once stable (one
    -- early-return on the latch).
    ensureDesiredMaterialsBound()
    -- Drain queued work BEFORE the combine so the composite picks up the
    -- freshly baked layers and new marks render this frame. If the API hasn't
    -- synced the vehicle's shape/transforms since before last frame (idle
    -- skip), sync first so the projections don't use a stale pose.
    sinceFlush = sinceFlush + (dtReal or 0)
    wear.now = wear.now + math.max(0, math.min(0.5, dtReal or 0))
    if wear.on and wear.pump then wear.pump() end
    local projected = false
    -- Drain captured layers before another batch. A slow native projection
    -- can exceed the interval; without backpressure it can starve baking.
    if hasPendingWorkRef and hasPendingWorkRef() and (sinceFlush >= FLUSH_INTERVAL or wear.kick)
      and not (hasPendingBakeRef and hasPendingBakeRef()) then
      sinceFlush = 0
      wear.kick = false
      projected = true
      -- Project against the car's current (possibly deforming) shape.
      local veh = getPlayerVehicle(0)
      if rebindDirty or fullRateCombine then
        syncAndCombine()
      elseif veh and decalProjection and veh.getDecalProjectionShape then
        syncShape(veh)
      end
      if flushPendingStampsRef then
        local tf = clockhp()
        flushPendingStampsRef()
        local ms = (clockhp() - tf) * 1000
        perfStats.flushMsTotal = perfStats.flushMsTotal + ms
        if ms > perfStats.flushMsMax then perfStats.flushMsMax = ms end
      end
    end
    -- Bake on the frames between projection batches, a chunk at a time.
    if not projected and bakePendingRef then bakePendingRef() end
    -- Composite only when something changed, while setup is still settling,
    -- or on the heartbeat that keeps the texture-set binding fresh.
    if combineDirty or rebindDirty or fullRateCombine or not seedDone then
      local tc = clockhp()
      composite()
      local ms = (clockhp() - tc) * 1000
      perfStats.combineMsTotal = perfStats.combineMsTotal + ms
      if ms > perfStats.combineMsMax then perfStats.combineMsMax = ms end
    end
    local ms = (clockhp() - t0) * 1000
    perfStats.frames = perfStats.frames + 1
    perfStats.lastMs = ms
    perfStats.msTotal = perfStats.msTotal + ms
    if ms > perfStats.msMax then perfStats.msMax = ms end
    if ms > 1 then perfStats.framesOver1ms = perfStats.framesOver1ms + 1 end
    if ms > 4 then perfStats.framesOver4ms = perfStats.framesOver4ms + 1 end
    -- (K) Draw the IMGUI debug panel after the combine so its frame state
    -- is consistent. drawUI is a no-op when uiVisible is false.
    if drawUIRef then drawUIRef() end
    return
  end
  if pendingSetup then
    setupAttemptTimer = setupAttemptTimer + (dtReal or 0)
    if setupAttemptTimer >= SETUP_RETRY then
      setupAttemptTimer = 0
      trySetup()
    end
  end
end

-- ---- vehicle lifecycle ----
local function onVehicleSwitched(oldId, newId, player)
  if adapter then
    adapter:detach()
    adapter=nil; api=nil
  end
  resetSurfaceState()
  -- Player switched cars. Tear down and re-setup against the new vehicle.
  ready = false
  lastSkinJBeam = nil
  pendingSetup = true
  setupAttemptTimer = SETUP_RETRY  -- attempt immediately
  -- Drop any queued stamps/jobs belonging to the previous vehicle.
  pendingStampInputs = {}
  pendingStampsVid   = nil
  if hasPendingWorkRef then M._dropQueuedJobs() end
  combineDirty       = true
  rebindDirty        = true
  apiApp             = nil
  table.clear(spotHits)
  skippedVid         = nil
  -- Drop the previous vehicle's material-binding state so the new vehicle
  -- runs the discover/stabilize cycle from scratch.
  desiredMatIndices = nil
  matBindingsStable = false
  seedDone          = false
  -- Drop the cached decalProjection. It was plucked out of api.bakeLayers as an
  -- upvalue; trySetup calls api.setup() again for the new vehicle, and if that
  -- rebuilds the API's projection our cached handle is a dead object every
  -- subsequent bake would write into. resolveDecalProjection re-plucks it.
  decalProjection = nil
  spawnAabbCache.vid = nil
  spawnAabbCache.box = nil
  -- Defer the API refresh until trySetup has accepted the new paint design.
end

local function onVehicleSpawned(vid)
  -- A respawn of a car we skipped (e.g. its livery was just removed) gets a
  -- fresh look; traffic spawns don't clear the memo.
  if vid == skippedVid then skippedVid = nil end
  -- Our own car respawned under us: re-bind its texture set promptly rather
  -- than waiting for the heartbeat.
  local veh = getPlayerVehicle(0)
  -- Same id, possibly a different part config (body kit, bumper delete):
  -- refetch the spawn AABB the hull-face picker steers by.
  if veh and veh:getId() == vid then
    resetSurfaceState()
    spawnAabbCache.vid = nil
    spawnAabbCache.box = nil
    -- Part changes can introduce a livery without changing the vehicle id.
    -- Re-run the safeguard before any seed, bake, clear or texture binding.
    onVehicleSwitched(vid, vid, 0)
  end
  if not ready then
    pendingSetup = true
    setupAttemptTimer = SETUP_RETRY  -- attempt immediately
  end
end

-- Read-only compatibility probe: does not initialize or modify the canvas.
M.getCompatibility = function()
  local veh = getPlayerVehicle(0)
  local vid = veh and veh:getId()
  return {ready = ready, pending = pendingSetup, part = currentPaintDesignPart(),
          owned = adapter ~= nil or (vid and ownedSkins[vid] ~= nil or false), skipped = vid == skippedVid,
          adapter = adapter and adapter.sourceName or nil, material = adapter and adapter.material:getName() or nil,
          keys = adapter and adapter.keys or nil, stage = adapter and adapter.stage or nil,
          rejected = adapterModule and vid and adapterModule.rejection(vid) or nil}
end

-- ---- public probes ----
M.dumpState = function()
  log('I', logTag, "----- paint state -----")
  log('I', logTag, "ready          = " .. tostring(ready))
  log('I', logTag, "pendingSetup   = " .. tostring(pendingSetup))
  log('I', logTag, "api loaded     = " .. tostring(api ~= nil))
  log('I', logTag, "api.ready      = " .. tostring(api and api.ready))
  log('I', logTag, "lastSkinJBeam  = " .. tostring(lastSkinJBeam))
  if api then
    log('I', logTag, "layer count    = " .. tostring(api.getLayerCount and api.getLayerCount()))
  end
  local veh = getPlayerVehicle(0)
  if veh then
    log('I', logTag, "player jbeam   = " .. tostring(veh.JBeam or veh.jbeam))
    log('I', logTag, "player id      = " .. tostring(veh:getId()))
  else
    log('I', logTag, "no player vehicle")
  end
end

M.kickSetup = function()
  skippedVid = nil
  ready = false
  pendingSetup = true
  setupAttemptTimer = SETUP_RETRY
  trySetup()
end

-- Camera-aimed stamp: uses the current game camera. Aim at a panel and call this.
-- Stamps a circle decal at screen center where the camera ray hits the body.
-- This is the simplest end-to-end verification of the painter pipeline. The
-- synthetic-camera (physics-driven) path comes next.
--
-- Optional args:
--   scale  : decal half-size (default 0.3 ≈ ~30 cm)
--   colorR : red 0..1 (default 0 = black)
--   colorG : green 0..1
--   colorB : blue 0..1
M.testStamp = function(scale, colorR, colorG, colorB)
  if not ready then
    log('W', logTag, "testStamp: not ready (call dumpState to diagnose)")
    return
  end
  if not api or not api.addDecal then
    log('W', logTag, "testStamp: api.addDecal unavailable")
    return
  end

  scale  = scale  or 0.3
  -- Default to RED so the stamp is visible against the black background that
  -- the dynamic-decals skin produces before any base color is set.
  colorR = colorR or 1
  colorG = colorG or 0
  colorB = colorB or 0

  -- Configure the stamp style.
  api.setDecalTexturePath("color", "/art/dynamicDecals/textures/shape_circle.png")
  api.setDecalTexturePath("alpha", "/art/dynamicDecals/textures/_one.png")
  api.setDecalColor(Point4F(colorR, colorG, colorB, 1))
  api.setDecalScale(vec3(scale, 1, scale))
  api.setDecalRotation(0)
  api.setUseSurfaceNormal(true)

  -- The setCursorPosition path doesn't work — the C++ binding silently ignores
  -- our writes (Point2F __newindex no-ops). Use the engine's UseMousePos
  -- setting instead: when enabled, the cursor follows the actual mouse pointer.
  -- Move your mouse over a body panel before calling testStamp.
  if api.isUseMousePos and not api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
    log('I', logTag, "enabled UseMousePos (move mouse over a panel before testStamp)")
  end

  local decal = api.addDecal()
  if decal then
    log('I', logTag, string.format(
      "stamp added: uid=%s layers=%d  (call scratches_paint.dumpLastDecal() for full data)",
      tostring(decal.uid),
      api.getLayerCount and api.getLayerCount() or -1))
    M._lastDecal = decal
    combineDirty = true
  else
    log('W', logTag, "addDecal returned nil (camera may not be aimed at a body panel)")
  end
  return decal
end

-- Dump full decal data so we can see what addDecal actually returned.
-- decal.decalPos may be a userdata that doesn't print well via string.format;
-- dump() unpacks it.
M.dumpLastDecal = function()
  if not M._lastDecal then log('I', logTag, "no last decal"); return end
  log('I', logTag, "----- last decal -----")
  dump(M._lastDecal)
end

-- Probe what unit decalProjection.cursorPosition actually uses by setting it
-- different ways and reading back. The output tells us whether it's pixels,
-- normalized UV, or something else.
M.probeCursor = function()
  if not ready then log('W', logTag, "not ready"); return end
  log('I', logTag, "----- cursor probe -----")
  log('I', logTag, "Point2F type: " .. tostring(type(Point2F)))
  log('I', logTag, "current: " .. dumps(api.getCursorPosition()))

  api.setCursorPosition(Point2F(0.5, 0.5))
  log('I', logTag, "after set(0.5, 0.5): " .. dumps(api.getCursorPosition()))

  api.setCursorPosition(Point2F(1920, 1080))
  log('I', logTag, "after set(1920, 1080): " .. dumps(api.getCursorPosition()))

  api.setCursorPosition(Point2F(100, 200))
  log('I', logTag, "after set(100, 200): " .. dumps(api.getCursorPosition()))
end

-- Try a stamp with PIXEL-coordinate cursor (assuming the C++ uses pixels).
-- screenW/screenH default to a 4K viewport — adjust if your window is different.
M.testStampPx = function(screenW, screenH, scale, colorR, colorG, colorB)
  if not ready then log('W', logTag, "not ready"); return end
  screenW = screenW or 3840
  screenH = screenH or 2160
  scale  = scale  or 0.3
  colorR = colorR or 1
  colorG = colorG or 0
  colorB = colorB or 0

  api.setDecalTexturePath("color", "/art/dynamicDecals/textures/shape_circle.png")
  api.setDecalTexturePath("alpha", "/art/dynamicDecals/textures/_one.png")
  api.setDecalColor(Point4F(colorR, colorG, colorB, 1))
  api.setDecalScale(vec3(scale, 1, scale))
  api.setDecalRotation(0)
  api.setUseSurfaceNormal(true)

  api.setCursorPosition(Point2F(screenW * 0.5, screenH * 0.5))
  log('I', logTag, string.format("cursor set to pixel (%d, %d)", screenW * 0.5, screenH * 0.5))

  local decal = api.addDecal()
  if decal then
    log('I', logTag, "stamp added: uid=" .. tostring(decal.uid) ..
                     " layers=" .. tostring(api.getLayerCount and api.getLayerCount()))
    M._lastDecal = decal
    combineDirty = true
  else
    log('W', logTag, "addDecal returned nil")
  end
  return decal
end

-- ---- scratch brushes ----
-- Generated by tools/generate_brushes.py: white RGB, shape in alpha, tinted
-- per stamp by setDecalColor. All are drawn along +x.
--   SCRAPE - slide bands of parallel lines; stretched along the slide path.
--   HAZE   - soft scuffed clear coat, laid under scrapes and impacts.
--   CHIPS  - impact paint loss (sharp flakes).
--   GOUGE  - impact dig-in crater with short deep scores.
local TEX = "/art/dynamicDecals/textures/"
local SCRAPE_BRUSHES = { TEX .. "m4_rash_a.png", TEX .. "m4_rash_b.png", TEX .. "m4_rash_c.png", TEX .. "m4_rash_d.png" }
local HAZE_BRUSHES   = { TEX .. "scr_haze_01.png", TEX .. "scr_haze_02.png" }
local CHIP_BRUSHES   = { TEX .. "m4_chip_a.png", TEX .. "m4_chip_b.png", TEX .. "m4_chip_c.png", TEX .. "m4_chip_d.png" }
local GOUGE_BRUSHES  = { TEX .. "m4_gouge_a.png", TEX .. "m4_gouge_b.png" }

-- Contact-patch wear brushes (tools/generate_wear.py), by severity tier. Each
-- entry is a colour brush plus, from tier 2, its metallic and roughness maps.
local WEAR = { slide = {}, chip = {}, score = {} }
do
  local function set(name, letters, pbr)
    local out = {}
    for letter in letters:gmatch(".") do
      local base = TEX .. "w2_" .. name .. "_" .. letter
      out[#out + 1] = { c = base .. ".png", m = pbr and (base .. "_m.png") or nil,
                        r = pbr and (base .. "_r.png") or nil }
    end
    return out
  end
  WEAR.slide = { set("scuff", "ab"), set("scrape", "abc", true), set("gouge", "abc", true) }
  WEAR.chip  = { set("chip", "ab"), set("chip", "cd", true), set("chip", "ef", true) }
  WEAR.score = { set("score", "ab"), set("score", "cd", true), set("score", "ef", true) }
end

-- Long straight slides used to become one large projected rectangle. On roof
-- slides that rectangle could span past the roof edge and mark the rear/side,
-- while visually reading as sparse because it was still a single layer. Chunk
-- by path length so long slides become many short, local scratches.
local STRETCH_MAX_SEGMENT_LEN = 0.35
local STRETCH_MAX_SEGMENTS_PER_STREAM = 40
-- Each stretched segment is drawn this much longer than its path chunk, so
-- neighbours overlap and a slide reads as one continuous band (the brushes
-- fade out at their ends to hide the joins).
local STRETCH_OVERLAP = 1.3
-- Nearby slides share one projection job (see enqueueStreamLocal).
local STREAM_MERGE_RADIUS    = 0.35  -- m between band centres
local STREAM_MERGE_MAX_BANDS = 6

-- One bounded alternate choice prevents consecutive repeats within each family.
local function pickFromSet(set)
  local index = math.random(#set)
  -- Family-keyed history survives intervening haze/chip selections.
  local b = set[index]
  if #set > 1 and b == recentBrushes[set] then
    b = set[index % #set + 1]
  end
  recentBrushes[set] = b
  recentBrushes[#recentBrushes + 1] = b
  if #recentBrushes > RECENT_BRUSH_MAX then table.remove(recentBrushes, 1) end
  return b
end

local function pickBrush() return pickFromSet(SCRAPE_BRUSHES) end

-- Damage tone, layered like real paint: clear coat scuffs to a translucent
-- haze, deeper damage exposes primer, the deepest bare metal. On light paint
-- the same damage reads darker than the paint, so the palette blends toward a
-- darker set as the car's paint luminance rises. Returns r, g, b, a.
--   layer: "haze" | "primer" | "metal"
local function damageTone(layer)
  local t = math.max(0, math.min(1, (paintLum - 0.35) / 0.3))  -- 0 dark paint .. 1 light paint
  local function mix(dark, light) return dark + (light - dark) * t end
  local j = (math.random() - 0.5) * 0.08
  if layer == "haze" then
    local v = mix(0.86, paintLum * 0.72) + j * 0.5
    return v, v, math.min(1, v + 0.015), 0.05 + math.random() * 0.04
  elseif layer == "metal" then
    local v = mix(0.86, 0.62) + j
    return v - 0.01, v, math.min(1, v + 0.03), 1
  end
  local v = mix(0.66, 0.45) + j                   -- primer: neutral, faintly warm
  return math.min(1, v + 0.012), v, math.max(0, v - 0.02), 0.95
end

-- Depth-colored brush tint and severity-dependent opacity (severity 0..1).
local function lineTone(severity)
  -- Depth-colored brushes carry primer, dark coating and exposed highlights.
  -- Restrained neutral tint; never turn every scrape into bright silver.
  local v = 0.72 + math.random() * 0.08
  return v, v, v, 0.72 + 0.16 * (severity or 0)
end

-- Scale wobble + per-brush bias. baseScale is the caller-supplied scale
-- (or stampAtLocal's default 0.10). Returns final scale.
local function pickStampScale(baseScale, brushPath)
  local wobble = 0.75 + math.random() * 0.5  -- 0.75..1.25
  local bias   = BRUSH_SCALE_BIAS[brushPath] or 1.0
  return baseScale * wobble * bias
end

-- Roughness jitter (only affects the canvas's M/R channels, which the car
-- currently renders from its factory maps).
local function pickRoughness()
  return 0.55 + math.random() * 0.20
end

-- ---- synthetic-camera stamping (Phase 3 step 1) ----
--
-- The api keeps `decalProjection` and `app` as module-locals (line 16-17 of
-- editor/api/dynamicDecals.lua). M.addDecal hardcodes `app:getCameraM()` (the
-- player camera) and offers no override hook, so to stamp at an arbitrary
-- world point we have to call `decalProjection:getDecalData(camM, projM)` with
-- our own camera. We pluck decalProjection out via the bakeLayers closure;
-- BeamNG's own code uses debug.getupvalue (devUtils, powertrain, ai), so the
-- facility is sandbox-permitted.

-- decalProjection and resolveDecalProjection are forward-declared at the top
-- of the file so the paint-fill helper near trySetup can reach them.

resolveDecalProjection = function()
  if decalProjection then return decalProjection end
  if not (api and api.bakeLayers) then return nil end
  local i = 1
  while true do
    local name, val = debug.getupvalue(api.bakeLayers, i)
    if not name then break end
    if name == "decalProjection" then
      decalProjection = val
      log('I', logTag, "resolved decalProjection via api.bakeLayers upvalue")
      return val
    end
    i = i + 1
  end
  log('E', logTag, "could not find decalProjection upvalue on api.bakeLayers")
  return nil
end

local function vecLen(v)
  if not v then return 0 end
  return math.sqrt((v.x or 0) * (v.x or 0) + (v.y or 0) * (v.y or 0) + (v.z or 0) * (v.z or 0))
end

local function axisVec(axis, sign)
  if axis == "x" then return vec3(sign, 0, 0) end
  if axis == "y" then return vec3(0, sign, 0) end
  return vec3(0, 0, sign)
end

-- The spawn-local AABB never changes for a given vehicle, but chooseHullOutward
-- asks for it once per cluster per frame (plus once per slide stream), so the
-- uncached version was a pcall + engine call on every stamp batch. Cache it
-- (spawnAabbCache, declared at the top) against the vehicle id; a switch
-- resets it and a different id refills it.
local function getSpawnAabb()
  local veh = getPlayerVehicle(0)
  if not veh then return nil end
  local vid = veh:getId()
  if spawnAabbCache.vid == vid then return spawnAabbCache.box end
  local ok, box = pcall(function() return veh:getSpawnLocalAABB() end)
  if not ok or not box or not box.minExtents or not box.maxExtents then return nil end
  spawnAabbCache.vid = vid
  spawnAabbCache.box = box
  return box
end

-- Pick the exterior hull face that owns a local contact point. The detector's
-- collision normal is useful for axis selection (roof/floor vs side/front),
-- but its sign can point from the world surface into the vehicle depending on
-- pose, so the sign comes from the point's position in the vehicle AABB.
-- This matters most for roof slides: the old radial camera aimed diagonally
-- outward on rear/side roof contacts and could see the trunk/doors; a roof
-- contact now gets a roof-normal camera.
local function chooseHullOutward(localPos, localNormal)
  local box = getSpawnAabb()
  if box then
    local minE, maxE = box.minExtents, box.maxExtents
    local cx = (minE.x + maxE.x) * 0.5
    local cy = (minE.y + maxE.y) * 0.5
    local cz = (minE.z + maxE.z) * 0.5
    local hx = math.max(0.001, (maxE.x - minE.x) * 0.5)
    local hy = math.max(0.001, (maxE.y - minE.y) * 0.5)
    local hz = math.max(0.001, (maxE.z - minE.z) * 0.5)

    if localNormal and vecLen(localNormal) > 1e-3 then
      local ax, ay, az = math.abs(localNormal.x), math.abs(localNormal.y), math.abs(localNormal.z)
      local axis = "x"
      if ay > ax and ay >= az then axis = "y" end
      if az > ax and az > ay then axis = "z" end
      if axis == "x" then return axisVec(axis, localPos.x >= cx and 1 or -1) end
      if axis == "y" then return axisVec(axis, localPos.y >= cy and 1 or -1) end
      return axisVec(axis, localPos.z >= cz and 1 or -1)
    end

    local sx = (localPos.x - cx) / hx
    local sy = (localPos.y - cy) / hy
    local sz = (localPos.z - cz) / hz
    local asx, asy, asz = math.abs(sx), math.abs(sy), math.abs(sz)

    -- Roof/floor panels are broad and easy to pollute through an oblique
    -- rear/side radial camera. Give Z a slight bias once the point is plainly
    -- in the upper/lower shell; otherwise use the nearest normalized face.
    if asz >= 0.45 and asz + 0.15 >= math.max(asx, asy) then
      return vec3(0, 0, sz >= 0 and 1 or -1)
    end
    if asx >= asy and asx >= asz then return vec3(sx >= 0 and 1 or -1, 0, 0) end
    if asy >= asz then return vec3(0, sy >= 0 and 1 or -1, 0) end
    return vec3(0, 0, sz >= 0 and 1 or -1)
  end

  local outward = localPos:normalized()
  if outward:length() < 1e-3 then outward = vec3(0, 0, 1) end
  return outward
end

local function averageNormals(samples)
  local sx, sy, sz, n = 0, 0, 0, 0
  for _, s in ipairs(samples) do
    local ln = s.localNormal
    if ln and vecLen(ln) > 1e-3 then
      sx = sx + ln.x; sy = sy + ln.y; sz = sz + ln.z; n = n + 1
    end
  end
  if n == 0 then return nil end
  return vec3(sx / n, sy / n, sz / n)
end

setScratchProjectionFence = function(_enabled)
  -- BeamNG exposes a depth-lock flag for authored decal editing, but in the
  -- free-standing bake path it can produce layers that project successfully
  -- yet write no visible pixels. Keep automated scratch bakes unfenced and
  -- rely on hull-face camera aiming plus tighter clustering for panel locality.
  if api and api.setLockDepth then api.setLockDepth(false) end
end

-- Build a 4x4 camera transform (camera -> vehicle-local) for a synthetic
-- view that's OUTSIDE the owning hull face at `localPos` looking IN.
-- BeamNG/Torque convention: col0=right(+X), col1=forward(+Y), col2=up(+Z),
-- col3=position. (Verified in lua/ge/spawn.lua lines 98-101.)
local function buildSyntheticCameraLocal(localPos, localNormal, dist)
  dist = dist or 0.5
  local outward = chooseHullOutward(localPos, localNormal)

  local fwd = -outward                  -- camera looks inward toward impact
  local camPos = localPos + outward * dist  -- camera placed outside the body

  -- Pick an up that isn't parallel to forward.
  local upHint = vec3(0, 0, 1)
  if math.abs(fwd:dot(upHint)) > 0.95 then upHint = vec3(0, 1, 0) end

  local right = upHint:cross(fwd):normalized()
  local up    = fwd:cross(right):normalized()

  local m = MatrixF(true)
  m:setColumn(0, right)
  m:setColumn(1, fwd)
  m:setColumn(2, up)
  m:setColumn(3, camPos)
  return m
end

-- Anchor normal for a synthetic layer: the detector's contact normal with its
-- sign resolved against the owning hull face (the collision normal can point
-- into the car), or that face's axis when the contact normal is missing or
-- grazes the face by more than ~70 degrees.
local function anchorNormal(localPos, localNormal)
  local outward = chooseHullOutward(localPos, localNormal)
  if localNormal and vecLen(localNormal) > 1e-3 then
    local n = localNormal:normalized()
    local d = n:dot(outward)
    if d < 0 then n = -n; d = -d end
    if d >= 0.35 then return n end
  end
  return outward
end

-- Replace the projection readback with the known contact point/normal. The
-- bake tolerates the node-to-mesh offset: anchors moved +-15 cm along the
-- normal painted identical marks in game (investigation 12).
local syntheticAnchorCount = 0
local function anchorLayer(layer, pos, normal)
  layer.decalPos = vec3(pos.x, pos.y, pos.z)
  layer.decalNorm = vec3(normal.x, normal.y, normal.z)
  layer.surfaceNormal = vec3(normal.x, normal.y, normal.z)
  syntheticAnchorCount = syntheticAnchorCount + 1
end

-- ---- projection job queue ----
-- Every visible mark is produced by a "job": ONE synthetic-camera projection
-- pass plus one or more layers captured under that camera. Discrete stamps
-- become one job per spatial cluster (clustered once per frame); every slide
-- stream is one job. onUpdate drains the queue under a per-frame projection
-- budget and every layer produced in a frame goes into ONE bakeLayers call,
-- so a big crash is spread across a few frames instead of landing as a single
-- long hitch. Positions are vehicle-local, so a job deferred a frame or two
-- still lands on the right panel.
local cosmeticGeneration = 0
local panelGrouping = false
-- Projection-free anchoring (milestone 5 stall fix). A captured layer bakes
-- where its camera ray meets the plane (decalPos, decalNorm). The native
-- projectDynamicDecals pass exists only to read that anchor back from a
-- rendered position buffer, and it is the call measured at 30 ms idle and up
-- to 508 ms under load. The detector already knows each contact point and
-- normal, so synthetic anchors supply them directly and skip the pass.
-- false restores the legacy projected anchors for comparison.
local syntheticAnchors = true
local coverage -- optional; explicit representative policy, independent of soil
local coverageModule
local jobQueue               = {}
-- Captured decal layers waiting to be baked. Baking costs ~0.85 ms per layer
-- and has no per-frame toll of its own, so it runs on the frames between
-- projection batches, BAKE_LAYERS_PER_FRAME at a time, instead of piling onto
-- the projection frame. Layers are car-local, so a short delay is harmless.
local bakeQueue              = {}
hasPendingBakeRef = function() return #bakeQueue > 0 end
local BAKE_LAYERS_PER_FRAME  = 6
local jobQueueVid            = nil  -- vehicle the queued jobs belong to
local MAX_PROJECTS_PER_FRAME = 6    -- projection passes per flush: ~14 ms toll + ~1.4 ms each (tunable)
local MAX_LAYERS_PER_FLUSH   = 24   -- layers captured per flush; baked later (tunable)
local MAX_QUEUED_JOBS        = 64   -- backlog bound; further jobs drop

-- Layer uids only need to be unique; a per-load salt plus a counter is cheaper
-- than formatting a fresh 32-bit random per layer and can't collide.
local layerUidSalt = math.random(0, 0xffffff)
local layerUidSeq  = 0
local function nextLayerUid(prefix)
  layerUidSeq = layerUidSeq + 1
  return string.format("%s-%06x-%x", prefix or "scr", layerUidSalt, layerUidSeq)
end

local function enqueueJob(job, vid)
  if jobQueueVid ~= vid then
    table.clear(jobQueue)
    jobQueueVid = vid
  end
  -- Preserve every layer while sharing a projection across nearby queued work.
  if panelGrouping and not job.stream then
    local normal=averageNormals(job.members)
    for _,q in ipairs(jobQueue) do
      if not q.stream and #q.members+#job.members<=MAX_LAYERS_PER_FLUSH then
        local dx,dy,dz=q.cx-job.cx,q.cy-job.cy,q.cz-job.cz
        if dx*dx+dy*dy+dz*dz<=1.2*1.2 and averageNormals(q.members):dot(normal)>=.9 then
          local a,b=#q.members,#job.members
          q.cx=(q.cx*a+job.cx*b)/(a+b);q.cy=(q.cy*a+job.cy*b)/(a+b);q.cz=(q.cz*a+job.cz*b)/(a+b)
          for _,s in ipairs(job.members) do q.members[#q.members+1]=s end
          q.queuedAt=math.min(q.queuedAt or clockhp(),job.queuedAt or clockhp())
          stampStats.clusterJobsMerged=stampStats.clusterJobsMerged+1
          return true
        end
      end
    end
  end
  if #jobQueue >= MAX_QUEUED_JOBS then
    stampStats.jobsDropped = stampStats.jobsDropped + 1
    if coverage then for _,s in ipairs(job.members or {}) do coverage:fail(s.coverageRecord) end end
    return false
  end
  job.queuedAt = job.queuedAt or clockhp()
  jobQueue[#jobQueue + 1] = job
  return true
end

local function hasPendingWork()
  return #pendingStampInputs > 0 or #jobQueue > 0
end
hasPendingWorkRef = hasPendingWork

-- Drop every queued projection job (vehicle switch, clear).
M._dropQueuedJobs = function()
  cosmeticGeneration=cosmeticGeneration+1
  table.clear(jobQueue)
  table.clear(bakeQueue)
  wear.agg:clear()
  if coverage then coverage=coverageModule.new(clockhp) end
  jobQueueVid = nil
end

-- Record one discrete stamp for vehicle `vid` (vehicle-local inputs). No api
-- calls, no projection: flushPendingStamps clusters the frame's stamps into
-- jobs. Callers have already checked readiness.
local function enqueueStamp(localPos, localNormal, opts, vid)
  opts = opts or {}

  -- Apply small positional jitter so repeated events at the same node don't
  -- perfectly stack into a single point. Body nodes have fixed body-relative
  -- positions, so without jitter a 1-second drag against a wall produces N
  -- stamps at exactly the same point; with jitter they spread into a small
  -- cluster that reads as scratch coverage.
  if not opts.noJitter then
    local jitter = 0.008  -- ±3 cm
    localPos = vec3(
      localPos.x + (math.random() - 0.5) * 2 * jitter,
      localPos.y + (math.random() - 0.5) * 2 * jitter,
      localPos.z + (math.random() - 0.5) * 2 * jitter)
  end

  -- Pick per-stamp style. opts overrides (used by probeBrushes / impact
  -- branch) win over the jitter helpers. No api state is set here — the job
  -- replays the style on each stamp's getDecalData call.
  local baseScale = opts.scale or 0.10
  local brush     = opts.colorTex or pickBrush()
  local scale     = opts.noJitter and baseScale or pickStampScale(baseScale, brush)
  -- setDecalRotation takes radians (editor/api/dynamicDecals.lua setDecalRotation).
  local rot       = opts.rot or math.random() * 2 * math.pi
  local r, g, b, a
  if opts.r or opts.g or opts.b then
    r, g, b, a = opts.r or 0.7, opts.g or 0.7, opts.b or 0.7, opts.a or 1
  else
    r, g, b, a = lineTone(opts.severity)
    a = opts.a or a
  end
  local roughness = opts.skipMetal and 0.5 or pickRoughness()

  stampStats.stampsAttempted = stampStats.stampsAttempted + 1

  if pendingStampsVid ~= vid then
    pendingStampInputs = {}
    pendingStampsVid = vid
  end

  local input = {
    queuedAt    = clockhp(), severity = opts.severity,
    -- Procedural variants may share a representative; explicit debug/user style
    -- overrides must not be silently replaced by a differently styled mark.
    styleKey = table.concat({tostring(opts.r),tostring(opts.g),tostring(opts.b),
      tostring(opts.a),tostring(opts.alphaTex),tostring(opts.rot),tostring(opts.skipMetal)},","),
    localPos    = localPos,
    localNormal = localNormal,
    soil        = opts.soil,
    brush       = brush,
    alpha       = opts.alphaTex or "/art/dynamicDecals/textures/_one.png",
    r = r, g = g, b = b, a = a,
    scale       = scale,
    width       = opts.width,
    depth       = opts.depth,
    flow        = opts.flow,
    rot         = rot,
    roughness   = roughness,
    skipMetal   = opts.skipMetal and true or false,
    dist        = opts.dist,
    wear        = opts.wear, warm = opts.warm,
    metalTex    = opts.metalTex, roughTex = opts.roughTex,
    flipX       = opts.flipX, flipY = opts.flipY,
  }
  if coverage and not input.soil then
    local rec,needed=coverage:admit(input)
    if not needed then return end
    input.coverageRecord=rec
  end
  if #pendingStampInputs >= AGGREGATE_PER_FRAME_CAP then
    stampStats.aggregateDropped = stampStats.aggregateDropped + 1
    if coverage then coverage:fail(input.coverageRecord) end
    return
  end
  pendingStampInputs[#pendingStampInputs+1]=input
  stampStats.stampsEnqueued = stampStats.stampsEnqueued + 1
end

-- Vehicle-local entry point. Stamps a decal at `localPos` (vehicle-local
-- vec3) with surface aim along `localNormal` (vehicle-local vec3).
-- The world wrapper M.stampAt converts world -> local then calls this.
-- Queued, not immediate: the stamp is projected and baked by onUpdate.
M.stampAtLocal = function(localPos, localNormal, opts)
  if not ready then log('W', logTag, "stampAtLocal: not ready"); return end
  if not resolveDecalProjection() then return end
  local veh = getPlayerVehicle(0)
  if not veh then return end
  enqueueStamp(localPos, localNormal, opts, veh:getId())
end


-- Greedy spatial clustering of pending inputs. O(N*K) where K is cluster
-- count; with N <= 24 and most rolls producing K=1, this is trivial.
local function buildClusters(inputs)
  local clusters = {}
  for i = 1, #inputs do
    local s = inputs[i]
    local placed = false
    for j = 1, #clusters do
      local c = clusters[j]
      local dx = s.localPos.x - c.cx
      local dy = s.localPos.y - c.cy
      local dz = s.localPos.z - c.cz
      local radius=panelGrouping and math.max(CLUSTER_RADIUS,1.2) or CLUSTER_RADIUS
      if (dx*dx + dy*dy + dz*dz) < radius*radius and
        (not panelGrouping or (#c.members<MAX_LAYERS_PER_FLUSH and averageNormals(c.members):dot(s.localNormal)>=.9)) then
        local k = #c.members
        c.cx = (c.cx * k + s.localPos.x) / (k + 1)
        c.cy = (c.cy * k + s.localPos.y) / (k + 1)
        c.cz = (c.cz * k + s.localPos.z) / (k + 1)
        c.queuedAt = math.min(c.queuedAt,s.queuedAt or clockhp())
        c.members[k + 1] = s
        placed = true
        break
      end
    end
    if not placed then
      clusters[#clusters + 1] = {
        cx = s.localPos.x, cy = s.localPos.y, cz = s.localPos.z,
        members = {s}, queuedAt = s.queuedAt or clockhp(),
      }
    end
  end
  return clusters
end

-- (H) Curvature-based segmentation. Walk the path, accumulate turning angles
-- at interior points, decide on 1/2/3 segments, and split at the largest
-- turn(s). Returns a list of {firstIdx, lastIdx} index ranges (inclusive).
-- Adjacent splits are forbidden so each segment has at least 2 points.
local function buildStretchSegments(localPos)
  local n = #localPos
  if n <= 2 then return {{firstIdx = 1, lastIdx = n}} end

  -- Turn angle at each interior point i (i = 2..n-1).
  local turnAngles = {}
  local totalTurn  = 0
  for i = 2, n - 1 do
    local ax = localPos[i].x   - localPos[i-1].x
    local ay = localPos[i].y   - localPos[i-1].y
    local az = localPos[i].z   - localPos[i-1].z
    local bx = localPos[i+1].x - localPos[i].x
    local by = localPos[i+1].y - localPos[i].y
    local bz = localPos[i+1].z - localPos[i].z
    local amag = math.sqrt(ax*ax + ay*ay + az*az)
    local bmag = math.sqrt(bx*bx + by*by + bz*bz)
    if amag > 1e-6 and bmag > 1e-6 then
      local dot = (ax*bx + ay*by + az*bz) / (amag * bmag)
      if dot < -1 then dot = -1 elseif dot > 1 then dot = 1 end
      local ang = math.acos(dot)
      turnAngles[i] = ang
      totalTurn = totalTurn + ang
    else
      turnAngles[i] = 0
    end
  end

  local segCount
  if totalTurn < math.rad(25) then segCount = 1
  elseif totalTurn < math.rad(55) then segCount = 2
  else segCount = 3 end

  -- Need at least 2 points per segment, so cap segCount accordingly.
  if segCount > math.floor(n / 2) then segCount = math.floor(n / 2) end
  if segCount < 1 then segCount = 1 end
  if segCount == 1 then return {{firstIdx = 1, lastIdx = n}} end

  -- Pick top-K interior indices by turn angle, with the no-adjacent constraint
  -- (so each segment ends up with ≥2 points).
  local sorted = {}
  for i = 2, n - 1 do sorted[#sorted + 1] = {idx = i, ang = turnAngles[i]} end
  table.sort(sorted, function(a, b) return a.ang > b.ang end)

  local splits = {}
  local needed = segCount - 1
  for i = 1, #sorted do
    if needed == 0 then break end
    local cand = sorted[i].idx
    local ok = true
    for _, s in ipairs(splits) do
      if math.abs(cand - s) < 2 then ok = false; break end
    end
    if ok then
      splits[#splits + 1] = cand
      needed = needed - 1
    end
  end
  table.sort(splits)

  local segments = {}
  local startIdx = 1
  for _, s in ipairs(splits) do
    segments[#segments + 1] = {firstIdx = startIdx, lastIdx = s}
    startIdx = s
  end
  segments[#segments + 1] = {firstIdx = startIdx, lastIdx = n}
  return segments
end

local function distLocal(a, b)
  local dx = b.x - a.x
  local dy = b.y - a.y
  local dz = b.z - a.z
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

local function chunkStretchSegments(localPos, rawSegments)
  local chunks = {}
  for _, r in ipairs(rawSegments) do
    local startIdx = r.firstIdx
    local accum = 0
    for i = r.firstIdx + 1, r.lastIdx do
      accum = accum + distLocal(localPos[i - 1], localPos[i])
      if accum >= STRETCH_MAX_SEGMENT_LEN and i > startIdx then
        chunks[#chunks + 1] = {firstIdx = startIdx, lastIdx = i}
        if #chunks >= STRETCH_MAX_SEGMENTS_PER_STREAM then return chunks end
        startIdx = i
        accum = 0
      end
    end
    if r.lastIdx > startIdx then
      chunks[#chunks + 1] = {firstIdx = startIdx, lastIdx = r.lastIdx}
      if #chunks >= STRETCH_MAX_SEGMENTS_PER_STREAM then return chunks end
    end
  end
  if #chunks == 0 and #localPos >= 2 then
    chunks[1] = {firstIdx = 1, lastIdx = #localPos}
  end
  return chunks
end

-- Turn a stream's vehicle-local path into a queued job. The path is first
-- split by curvature, then any long straight section is chopped by length so
-- one roof slide cannot stamp a giant rectangle across roof/rear/side at once.
local function enqueueStreamLocal(localPos, localNormals, vid, severity)
  local rawSegments = chunkStretchSegments(localPos, buildStretchSegments(localPos))

  -- Materialize each segment's geometry (start/end/center/length/width).
  -- Drop any segment shorter than 0.05m as degenerate (jittered noise).
  local segments = {}
  for _, r in ipairs(rawSegments) do
    local sP = localPos[r.firstIdx]
    local eP = localPos[r.lastIdx]
    local dx = eP.x - sP.x
    local dy = eP.y - sP.y
    local dz = eP.z - sP.z
    local len = math.sqrt(dx*dx + dy*dy + dz*dz)
    if len >= 0.05 then
      segments[#segments + 1] = {
        startP = sP,
        endP   = eP,
        center = vec3((sP.x + eP.x) * 0.5, (sP.y + eP.y) * 0.5, (sP.z + eP.z) * 0.5),
        length = len,
      }
    end
  end
  if #segments == 0 then return end

  -- Centroid of segment centers for the shared camera
  local cx, cy, cz = 0, 0, 0
  for _, s in ipairs(segments) do
    cx = cx + s.center.x; cy = cy + s.center.y; cz = cz + s.center.z
  end
  local normalSamples = {}
  for _, ln in ipairs(localNormals) do
    normalSamples[#normalSamples + 1] = {localNormal = ln}
  end
  local centroid = vec3(cx / #segments, cy / #segments, cz / #segments)
  local normal   = averageNormals(normalSamples)
  local band     = { segments = segments, severity = severity }
  -- Share a queued job's projection if it's close by on a panel facing the
  -- same way (each projecting frame costs a ~14 ms toll; see FLUSH_INTERVAL).
  if jobQueueVid == vid then
    for i = #jobQueue, 1, -1 do
      local j = jobQueue[i]
      if j.stream and #j.bands < (panelGrouping and 6 or STREAM_MERGE_MAX_BANDS)
         and (not panelGrouping or #j.segments+#j.bands+#segments+1<=MAX_LAYERS_PER_FLUSH)
         and distLocal(j.centroid, centroid) <= (panelGrouping and .65 or STREAM_MERGE_RADIUS)
         and j.normal:dot(normal) >= 0.8 then
        local k = #j.bands
        j.bands[k + 1] = band
        for _, sg in ipairs(segments) do j.segments[#j.segments + 1] = sg end
        j.centroid = (j.centroid * k + centroid) * (1 / (k + 1))
        stampStats.streamsMerged = stampStats.streamsMerged + 1
        return
      end
    end
  end
  -- Keep the first band's path separate from the aggregate budget list.
  -- Appending later bands to an aliased table repeated their segments in band 1
  -- and stretched its haze over unrelated paths.
  local allSegments = {}
  for i, sg in ipairs(segments) do allSegments[i] = sg end
  enqueueJob({
    stream   = true,
    bands    = { band },
    segments = allSegments,  -- all bands' segments, for layer budgeting
    centroid = centroid,
    normal   = normal,
  }, vid)
end

-- Run one stream job: one projection for the whole stream, then per segment
-- set the style -> getDecalData (snapshots into a fresh layer) ->
-- setDecalLocalPos to the segment center. Layers append to bakeList.
local function runStreamJob(job, projM, bakeList)
  -- Back the camera off far enough to see every band (at 0.5 m it covers only
  -- ~+-0.3 m, which clipped the ends of a single long band). Even at 1.6 m the
  -- projection is far finer than the paint canvas stores.
  local extent = 0
  for _, sg in ipairs(job.segments) do
    extent = math.max(extent, distLocal(job.centroid, sg.startP), distLocal(job.centroid, sg.endP))
  end
  local camLocal = buildSyntheticCameraLocal(job.centroid, job.normal,
                                             math.max(0.5, math.min(panelGrouping and 3 or 1.6, (extent + 0.05) * 2.2)))
  setScratchProjectionFence(true)
  if not syntheticAnchors then
    local tp = clockhp()
    decalProjection:projectDynamicDecals(camLocal, projM)
    perfAdd(tp, "projectMsTotal", "projectMsMax", "projectCalls")
  end

  -- Helper layer used only to compute screen-UV for start/end points (cheap;
  -- we mutate cursor and read it back without baking). Does NOT enter the
  -- bake list — we get a fresh styled layer per segment below.
  local probe = decalProjection:getDecalData(camLocal, projM)
  if not (probe and probe.cursorPosScreenUv) then
    setScratchProjectionFence(false)
    log('W', logTag, "stream job: getDecalData returned nil")
    return
  end

  local function addLayer(tex, r, g, b, a, center, halfLen, halfWidth, angle, name)
    api.setDecalTexturePath("color", tex)
    api.setDecalTexturePath("alpha", "/art/dynamicDecals/textures/_one.png")
    api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_zero.png")
    api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
    api.setMetallicIntensity(1.0)
    api.setRoughnessIntensity(pickRoughness())
    api.setDecalColor(Point4F(r, g, b, a))
    -- Asymmetric scale: long along travel, thin across. Both are half-sizes.
    api.setDecalScale(vec3(halfLen, 1, halfWidth))
    api.setDecalRotation(angle)
    api.setUseSurfaceNormal(true)
    local tl = clockhp()
    local layer = decalProjection:getDecalData(camLocal, projM)
    if layer then
      api.setDecalLocalPos(layer, center)
      if syntheticAnchors then anchorLayer(layer, center, anchorNormal(center, job.normal)) end
    end
    perfAdd(tl, "layerMsTotal", nil, "layerCalls")
    if not layer then return end
    -- Frustum sanity (out-of-frustum stamps wouldn't paint correctly).
    local cuv = layer.cursorPosScreenUv
    if cuv and cuv.x >= 0 and cuv.x <= 1 and cuv.y >= 0 and cuv.y <= 1 then
      layer.uid       = nextLayerUid()
      layer.name      = name
      layer.enabled   = true
      layer.locked    = false
      layer.parentUid = nil
      layer.children  = {}
      bakeList[#bakeList + 1] = layer
    end
  end

  -- Screen-space angle of a car-local segment under this job's camera.
  local function angleOf(p0, p1)
    api.setDecalLocalPos(probe, p0)
    local aUx, aUy = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
    api.setDecalLocalPos(probe, p1)
    local bUx, bUy = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
    return (math.abs(bUx - aUx) + math.abs(bUy - aUy)) > 1e-5
      and math.atan2(bUy - aUy, bUx - aUx) or (math.random() * 2 * math.pi)
  end

  local before = #bakeList
  for bi, band in ipairs(job.bands) do
    -- One look per scrape: a single brush, width and tone for the whole band
    -- (with slight per-segment variation), so it reads as one continuous
    -- band rather than a string of unrelated marks.
    local brush     = pickFromSet(SCRAPE_BRUSHES)
    local hazeBrush = pickFromSet(HAZE_BRUSHES)
    local width     = 0.055 + math.random() * 0.055          -- 5.5..11 cm band
    local lr, lg, lb, la = lineTone(band.severity or 0.3)
    local hr, hg, hb, ha = damageTone("haze")
    local segs = band.segments
    local s1, sn = segs[1], segs[#segs]
    local total, cx, cy, cz = 0, 0, 0, 0
    for _, sg in ipairs(segs) do
      total = total + sg.length
      cx, cy, cz = cx + sg.center.x, cy + sg.center.y, cz + sg.center.z
    end
    -- One haze underlay for the whole band, under its scrape segments.
    addLayer(hazeBrush, hr, hg, hb, ha, vec3(cx / #segs, cy / #segs, cz / #segs),
             total * 0.5 * STRETCH_OVERLAP, width * 0.95, angleOf(s1.startP, sn.endP),
             "scrape-haze-" .. bi)
    for si, seg in ipairs(segs) do
      local w = width * (0.9 + math.random() * 0.2)
      local v = (math.random() - 0.5) * 0.04
      addLayer(brush, lr + v, lg + v, lb + v, la, seg.center, seg.length * 0.5 * STRETCH_OVERLAP,
               w * 0.5, angleOf(seg.startP, seg.endP), "scrape-" .. bi .. "-" .. si)
    end
  end
  setScratchProjectionFence(false)

  local added = #bakeList - before
  if added > 0 then
    stampStats.streamsBaked          = stampStats.streamsBaked + 1
    stampStats.streamSubstrokesTotal = stampStats.streamSubstrokesTotal + added
    if stampVerbose then
      log('I', logTag, string.format("stream job: %d stretched segments", added))
    end
  end
end

-- Run one discrete-stamp cluster job: ONE projection for the cluster, then a
-- per-stamp styled getDecalData under the shared cam with the cursor moved to
-- the stamp's own position. Layers append to bakeList.
local function runClusterJob(cluster, projM, bakeList)
  local centroid = vec3(cluster.cx, cluster.cy, cluster.cz)
  -- (I) Use the max requested dist among cluster members. Heavy-impact
  -- stamps need a further-back camera so the projection ray grazes the
  -- deformed panel from the side instead of plunging into the dent's
  -- cavity. Lighter stamps in the same cluster are fine with a slightly
  -- further camera — just lower projection resolution.
  local clusterDist = nil
  for _, s in ipairs(cluster.members) do
    if s.dist and (not clusterDist or s.dist > clusterDist) then
      clusterDist = s.dist
    end
  end
  if panelGrouping then
    local extent=0
    for _,s in ipairs(cluster.members) do extent=math.max(extent,distLocal(centroid,s.localPos)+s.scale) end
    clusterDist=math.max(clusterDist or .5,(extent+.05)*2.2)
  end
  local camLocal = buildSyntheticCameraLocal(centroid, averageNormals(cluster.members), clusterDist)
  setScratchProjectionFence(true)
  if not syntheticAnchors then
    local tp = clockhp()
    decalProjection:projectDynamicDecals(camLocal, projM)
    perfAdd(tp, "projectMsTotal", "projectMsMax", "projectCalls")
  end

  local skipped = 0
  for _, s in ipairs(cluster.members) do
    -- Per-stamp style — getDecalData below snapshots api state into the layer.
    api.setDecalTexturePath("color", s.brush)
    api.setDecalTexturePath("alpha", s.alpha)
    if s.skipMetal then
      api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_zero.png")
      api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
      api.setMetallicIntensity(0)
      api.setRoughnessIntensity(0.5)
    elseif s.wear then
      -- Per-pixel metal and roughness from the brush's own maps.
      api.setDecalTexturePath("metallic",  s.metalTex or "/art/dynamicDecals/textures/_zero.png")
      api.setDecalTexturePath("roughness", s.roughTex or "/art/dynamicDecals/textures/_one.png")
      api.setMetallicIntensity(1.0)
      api.setRoughnessIntensity(s.roughTex and 1.0 or 0.5)
    else
      api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_zero.png")
      api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
      api.setMetallicIntensity(1.0)
      api.setRoughnessIntensity(s.roughness)
    end
    -- Mirror the brush for variety; set for every stamp so it never leaks.
    if api.setDecalUv and Point2F then api.setDecalUv(Point2F(s.flipX or 1, s.flipY or 1)) end
    api.setDecalColor(Point4F(s.r, s.g, s.b, s.a or 1))
    api.setDecalScale(vec3(s.scale, s.depth or 1, s.width or s.scale))
    local angle = s.rot
    if s.flow then
      -- Match decal.cs.hlsl's surface-normal basis directly. Screen-space
      -- angles vary with camera perspective; a shared body-space basis keeps
      -- one long splash aligned across all mesh/UV islands it intersects.
      local n = anchorNormal(s.localPos,s.localNormal)
      local right = n:cross(vec3(0,0,1))
      if vecLen(right)>1e-5 then
        right=right:normalized()
        local up=right:cross(n):normalized()
        angle=math.atan2(-s.flow:dot(up),s.flow:dot(right))
      end
    end
    api.setDecalRotation(angle)
    api.setUseSurfaceNormal(true)

    local tl = clockhp()
    local decalData = decalProjection:getDecalData(camLocal, projM)
    if decalData then
      -- Move the layer's cursor from the cluster centroid (where project
      -- placed it) to the actual stamp position. This recomputes
      -- cursorPosScreenUv for s.localPos under the shared cam. decalPos is
      -- NOT re-read: it stays the projection's centroid hit, or the stamp's
      -- own contact point under synthetic anchors.
      api.setDecalLocalPos(decalData, s.localPos)
      if syntheticAnchors then
        anchorLayer(decalData, s.localPos, anchorNormal(s.localPos, s.localNormal))
      end
    end
    perfAdd(tl, "layerMsTotal", nil, "layerCalls")
    if decalData then

      -- Reject stamps whose projection lands outside the camera frustum
      -- (cursor outside [0,1]) — those would paint nothing or paint at the
      -- frustum edge incorrectly.
      local cuv = decalData.cursorPosScreenUv
      if not cuv or cuv.x < 0 or cuv.x > 1 or cuv.y < 0 or cuv.y > 1 then
        skipped = skipped + 1
        if coverage then coverage:fail(s.coverageRecord) end
      else
        decalData._scratchesCoverage = s.coverageRecord
        decalData.uid       = nextLayerUid()
        decalData.name      = s.soil and "soil" or (s.warm and "warm" or "scratch")
        decalData.enabled   = true
        decalData.locked    = false
        decalData.parentUid = nil
        decalData.children  = {}
        bakeList[#bakeList + 1] = decalData

        if stampVerbose then
          log('I', logTag, string.format(
            "stamp: input pos=(%.2f,%.2f,%.2f) | decalPos=(%.2f,%.2f,%.2f) cursor=(%.3f,%.3f) uid=%s",
            s.localPos.x, s.localPos.y, s.localPos.z,
            decalData.decalPos.x, decalData.decalPos.y, decalData.decalPos.z,
            cuv.x, cuv.y, decalData.uid))
        end
      end
    elseif coverage then coverage:fail(s.coverageRecord) end
  end
  setScratchProjectionFence(false)
  if skipped > 0 then
    stampStats.stampsSkippedMissed = stampStats.stampsSkippedMissed + skipped
  end
end

-- Per-frame drain. Cluster this frame's discrete stamps into jobs, run up to
-- MAX_PROJECTS_PER_FRAME jobs from the head of the queue (the rest wait for
-- the next frame), and bake everything they produced in ONE bakeLayers call.
local function flushPendingStamps()
  if not resolveDecalProjection() then
    pendingStampInputs = {}
    table.clear(jobQueue)
    return
  end
  local veh = getPlayerVehicle(0)
  if not veh then
    pendingStampInputs = {}
    table.clear(jobQueue)
    return
  end
  local vid = veh:getId()

  if #pendingStampInputs > 0 then
    if pendingStampsVid == vid then
      local clusters = buildClusters(pendingStampInputs)
      for i = 1, #clusters do enqueueJob(clusters[i], vid) end
    end
    pendingStampInputs = {}
  end
  if jobQueueVid ~= vid then
    table.clear(jobQueue)
    jobQueueVid = vid
    return
  end
  local n = #jobQueue
  if n == 0 then return end

  -- UseMousePos must be OFF so projectDynamicDecals writes the cursor to the
  -- synth camera's screen-center instead of following the actual mouse.
  if api.isUseMousePos and api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
  end

  local projM    = getCameraProjMatrix()
  local bakeList = {}
  -- Take jobs from the head until the pass budget or the layer budget is
  -- reached (bake costs ~1 ms per layer); always at least one job.
  local run, layers = 0, 0
  local maxRun = math.min(n, MAX_PROJECTS_PER_FRAME)
  while run < maxRun do
    local j = jobQueue[run + 1]
    local jl = j.stream and (#j.segments + #j.bands) or #j.members
    if run > 0 and layers + jl > MAX_LAYERS_PER_FLUSH then break end
    run, layers = run + 1, layers + jl
  end
  local clusters = 0
  -- Take this frame's jobs off the queue BEFORE running them: a job that
  -- throws must cost exactly one job, not wedge the head of the queue and
  -- re-throw every frame (which would also abort the composite and the panel).
  local batch = {}
  for i = 1, run do batch[i] = jobQueue[i] end
  -- Shift the unrun tail to the front (FIFO; oldest work goes first).
  for i = run + 1, n do jobQueue[i - run] = jobQueue[i] end
  for i = n - run + 1, n do jobQueue[i] = nil end

  for i = 1, run do
    local job = batch[i]
    local before = #bakeList
    local expectedStreamLayers=job.stream and (#job.segments+#job.bands) or 0
    stampStats.streamLayersExpected=stampStats.streamLayersExpected+expectedStreamLayers
    perfStats.inputToProjectMaxMs = math.max(perfStats.inputToProjectMaxMs,(clockhp()-(job.queuedAt or clockhp()))*1000)
    local ok, err = pcall(job.stream and runStreamJob or runClusterJob, job, projM, bakeList)
    if not ok then
      -- Discard whatever the failed job half-produced.
      for k = #bakeList, before + 1, -1 do bakeList[k] = nil end
      setScratchProjectionFence(false)
      stampStats.jobsFailed = stampStats.jobsFailed + 1
      if coverage then for _,s in ipairs(job.members or {}) do coverage:fail(s.coverageRecord) end end
      log('E', logTag, "projection job failed: " .. tostring(err))
    elseif not job.stream then
      clusters = clusters + 1
    end
    if job.stream then stampStats.streamLayersMissed=stampStats.streamLayersMissed+math.max(0,expectedStreamLayers-(#bakeList-before)) end
    for k=before+1,#bakeList do bakeList[k]._scratchesQueuedAt=job.queuedAt end
  end

  -- Capturing soil on the shared camera leaves a working preview in the
  -- damage projection. Flush only that transient preview, never baked damage.
  -- Synthetic anchors never run the preview pass, so there is nothing to flush.
  if adapter and not syntheticAnchors then decalProjection:flushDynamicTextures() end
  stampStats.projectsIssued = stampStats.projectsIssued + run
  stampStats.clustersTotal  = stampStats.clustersTotal + clusters
  if run < n then stampStats.framesDeferred = stampStats.framesDeferred + 1 end
  for i = 1, #bakeList do bakeQueue[#bakeQueue + 1] = bakeList[i] end
end
flushPendingStampsRef = flushPendingStamps

-- Bake up to BAKE_LAYERS_PER_FRAME queued layers. Returns true if it baked.
local function bakePending()
  local n = #bakeQueue
  if n == 0 then return false end
  local veh = getPlayerVehicle(0)
  if not veh or veh:getId() ~= jobQueueVid or not resolveDecalProjection() then
    table.clear(bakeQueue)
    return false
  end
  local k = math.min(n, BAKE_LAYERS_PER_FRAME)
  local chunk = {}
  for i = 1, k do chunk[i] = bakeQueue[i] end
  for i = k + 1, n do bakeQueue[i - k] = bakeQueue[i] end
  for i = n - k + 1, n do bakeQueue[i] = nil end
  local tb = clockhp()
  local ok,err=pcall(function()
  if adapter then
    local damage,soil = {},{}
    for _,layer in ipairs(chunk) do
      local target=layer.name=="soil" and soil or damage
      target[#target+1]=layer
    end
    if #damage>0 then decalProjection:bakeLayers(damage,veh.JBeam or veh.jbeam) end
    if #soil>0 then adapter:bakeSoil(soil) end
  else
    decalProjection:bakeLayers(chunk, veh.JBeam or veh.jbeam)
  end
  end)
  perfAdd(tb, "bakeMsTotal", "bakeMsMax", "bakeCalls", k)
  if not ok then
    -- A native failure may have partially drawn the batch. Do not retry and
    -- double-composite it, or claim its requests completed. Later work proceeds.
    stampStats.bakeFailures=stampStats.bakeFailures+1
    stampStats.layersLost=stampStats.layersLost+k
    for _,layer in ipairs(chunk) do if coverage then coverage:fail(layer._scratchesCoverage) end end
    combineDirty=true
    log('E',logTag,"native bake batch failed: "..tostring(err))
    return false
  end
  perfStats.bakeLayersTotal = perfStats.bakeLayersTotal + k
  for _,layer in ipairs(chunk) do
    if coverage then coverage:complete(layer._scratchesCoverage) end
    perfStats.inputToBakeMaxMs=math.max(perfStats.inputToBakeMaxMs,(clockhp()-(layer._scratchesQueuedAt or clockhp()))*1000)
  end
  M._lastDecal = chunk[k]
  combineDirty = true
  stampStats.bakesIssued   = stampStats.bakesIssued + 1
  stampStats.framesFlushed = stampStats.framesFlushed + 1
  return true
end
bakePendingRef = bakePending

-- Severity 0..1 from contact force: 0.8 kN (a knock) .. 20.8 kN (a crunch).
local function severityOf(force)
  return math.min(1, math.max(0, ((force or 0) - 800) / 20000))
end

-- Stamp style for one detector event (also stampAt's 'impact' style). Impacts
-- get chipped paint; (I) scale and camera distance both grow with force so a
-- heavy crunch leaves a bigger mark from a more grazing camera instead of
-- dying in the dent's cavity. A 1-point slide fallback is a small square
-- scrape patch.
local function styleForEvent(kind, force)
  local heavy = severityOf(force)
  if kind == "impact" then
    return { scale = 0.045 + heavy * 0.085, dist = 0.7 + heavy * 1.6,   -- 9..26 cm across before wobble
             colorTex = pickFromSet(CHIP_BRUSHES), severity = heavy }
  end
  if (force or 0) > 800 then
    return { dist = 0.7 + heavy * 1.6, scale = 0.06 + heavy * 0.06, severity = heavy }
  end
  return { scale = 0.05 + math.random() * 0.03 }
end

-- An impact lays down chipped paint and, on harder hits, a gouge on top
-- where an edge dug in. (A haze halo here read as a soft white puff.)
local function enqueueImpact(localPos, localNormal, force, vid)
  if not spotTake(localPos, "i", SPOT_MAX_IMPACT) then return end
  local main = styleForEvent("impact", force)
  local heavy = main.severity
  enqueueStamp(localPos, localNormal, main, vid)
  if math.random() < 0.25 + 0.6 * heavy then
    enqueueStamp(localPos, localNormal, { colorTex = pickFromSet(GOUGE_BRUSHES),
      scale = 0.025 + heavy * 0.055, dist = main.dist, severity = math.min(1, heavy + 0.3) }, vid)
  end
end

-- A slide stream is one body point dragged along the ground. Its world
-- samples trace how far the CAR moved, not where the body was scraped - the
-- contact stays at the same body point. (Converting every sample with the
-- current pose used to paint a trail as long as the slide, up to ~3.5 m,
-- smeared back across and off the body.) So the scrape is drawn AT the
-- latest contact, along the slide axis (first->last displacement, which is
-- exact because the ground doesn't move) flattened onto the panel, as long as
-- a contact patch. Neighbouring contact nodes' bands join into the rash.
-- A longer drag scrapes deeper: severity rises with slide distance.
local SLIDE_BAND_MIN, SLIDE_BAND_MAX = 0.18, 0.42   -- band length, m (long enough to join neighbours)
local function enqueueSlide(points, invM, rotOnly, vid)
  local first, last = points[1], points[#points]
  local anchor = invM:mulP3F(vec3(last[1], last[2], last[3]))
  local pass = spotTake(anchor, "s", SPOT_MAX_SLIDE)
  if not pass then return end
  local nx, ny, nz = 0, 0, 0
  for i = 1, #points do
    local p = points[i]
    if p[4] and p[5] and p[6] then nx, ny, nz = nx + p[4], ny + p[5], nz + p[6] end
  end
  local normal = rotOnly:mulP3F(vec3(nx, ny, nz))
  local nlen = normal:length()
  local worldMove = vec3(last[1] - first[1], last[2] - first[2], last[3] - first[3])
  local dist = worldMove:length()
  local dir = rotOnly:mulP3F(worldMove)
  if nlen > 1e-6 then
    normal = normal * (1 / nlen)
    dir = dir - normal * dir:dot(normal)            -- onto the panel's plane
  end
  local dlen = dir:length()
  if dlen < 1e-4 or nlen < 1e-6 then
    -- No usable direction (pressed, not dragged): a small square patch.
    enqueueStamp(anchor, nlen > 1e-6 and normal or vec3(0, 0, 1), styleForEvent(nil, 0), vid)
    return
  end
  dir = dir * (1 / dlen)
  local half = 0.5 * math.min(SLIDE_BAND_MAX, SLIDE_BAND_MIN + 0.12 * dist)
  enqueueStreamLocal({ anchor - dir * half, anchor + dir * half }, { normal }, vid,
                     math.min(1, dist / 3 + (pass - 1) * 0.35))   -- a repeat pass digs deeper
end

-- ---- contact-patch wear ----
-- Paint one patch decal handed out by the aggregator.
local function enqueueWear(e, vid)
  local sets = e.kind == "slide" and WEAR.slide or (e.dir and WEAR.score or WEAR.chip)
  -- The engine keeps only the last couple of brush textures loaded, so reuse
  -- the family's last brush most of the time (mirroring still varies it).
  local set = sets[e.tier]
  local brush = wear.last[set]
  if not brush or wear.hotKey ~= e.key or math.random() < 0.2 then brush = pickFromSet(set) end
  wear.last[set], wear.hotKey = brush, e.key
  local normal = e.normal
  -- The bake builds its basis from cross(normal, +Z); keep it well defined on
  -- the roof and floor, and identical to the rotation computed for `flow`.
  if math.abs(normal.z) > 0.999 then normal = (normal + vec3(0, 0.03, 0)):normalized() end
  local tint = 1 - math.random() * 0.03
  local opts = { wear = true, colorTex = brush.c, metalTex = brush.m, roughTex = brush.r,
    r = 1, g = tint, b = tint - math.random() * 0.03, a = 1, noJitter = true,
    severity = (e.tier - 1) * 0.5, flipX = math.random() < 0.5 and -1 or 1,
    flipY = math.random() < 0.5 and -1 or 1 }
  if e.kind == "slide" then
    opts.scale, opts.width, opts.flow = e.length, e.width, e.dir
    opts.depth = math.max(0.16, math.min(0.34, e.width * 0.6 + 0.10))
  else
    opts.scale, opts.width = e.size, e.size
    opts.depth = math.max(0.16, math.min(0.34, e.size * 0.6))
    if e.dir then opts.flow = e.dir else opts.rot = math.random() * 2 * math.pi end
  end
  wear.painted = wear.painted + 1
  enqueueStamp(e.centre, normal, opts, vid)
end

-- Load one brush set with an invisible stamp inside the cabin, so a crash
-- never pays the first-use texture load. One set per call.
local function warmOne(vid)
  if not wear.warm then
    wear.warm = {}
    for _, family in pairs(WEAR) do
      for _, tier in ipairs(family) do
        for _, brush in ipairs(tier) do
          if not wear.warmed[brush.c] then
            wear.warmed[brush.c] = true
            wear.warm[#wear.warm + 1] = brush
          end
        end
      end
    end
  end
  local brush = table.remove(wear.warm)
  if not brush then return false end
  local box = getSpawnAabb()
  local centre = box and (box.minExtents + box.maxExtents) * 0.5 or vec3(0, 0, 0.5)
  wear.warmedCount = wear.warmedCount + 1
  enqueueStamp(vec3(centre.x, centre.y, centre.z), vec3(1, 0, 0), { wear = true, warm = true,
    colorTex = brush.c, metalTex = brush.m, roughTex = brush.r, r = 1, g = 1, b = 1, a = 0.004,
    scale = 0.02, width = 0.02, depth = 0.02, rot = 0, noJitter = true }, vid)
  return true
end

-- Once per frame: when the painter is idle, paint the next due patch, or
-- failing that warm one brush set (every few frames, after setup settles).
wear.pump = function()
  wear.frame = wear.frame + 1
  if hasPendingWork() or #bakeQueue > 0 then return end
  local veh = getPlayerVehicle(0)
  if not veh then return end
  local e = wear.agg:next(wear.now, wear.hotKey)
  if e then
    enqueueWear(e, veh:getId())
    wear.kick = true
  elseif seedDone and wear.frame % 3 == 0 and (not wear.warm or #wear.warm > 0) then
    wear.kick = warmOne(veh:getId())
  end
end

-- Detector batch -> patches. Impacts carry an optional world slip velocity.
local function ingestWear(events, streams, invM, rotOnly)
  local agg, now = wear.agg, wear.now
  for i = 1, events and #events or 0 do
    local e = events[i]
    local lp = invM:mulP3F(vec3(e[1], e[2], e[3]))
    local n = anchorNormal(lp, rotOnly:mulP3F(vec3(e[4], e[5], e[6])))
    if e[7] == "i" then
      local slip = e[9] and rotOnly:mulP3F(vec3(e[9], e[10], e[11])) or nil
      if slip then slip = slip - n * slip:dot(n) end
      agg:addImpact(lp, n, severityOf(e[8]), slip, now)
    elseif (e[8] or 0) >= 400 then
      -- Pressed, barely dragged: a faint chip, no direction.
      agg:addImpact(lp, n, severityOf(e[8]) * 0.5, nil, now)
    end
  end
  for si = 1, streams and #streams or 0 do
    local points = streams[si]
    if points and #points >= 2 then
      local first, last = points[1], points[#points]
      local anchor = invM:mulP3F(vec3(last[1], last[2], last[3]))
      local nx, ny, nz = 0, 0, 0
      for k = 1, #points do
        local p = points[k]
        if p[4] and p[5] and p[6] then nx, ny, nz = nx + p[4], ny + p[5], nz + p[6] end
      end
      local n = anchorNormal(anchor, rotOnly:mulP3F(vec3(nx, ny, nz)))
      local move = vec3(last[1] - first[1], last[2] - first[2], last[3] - first[3])
      local dist = move:length()
      local dir = rotOnly:mulP3F(move)
      dir = dir - n * dir:dot(n)
      local dlen = dir:length()
      if dlen > 1e-4 then
        agg:addSlide(anchor, n, dir * (1 / dlen), math.min(dist, 4), now)
      else
        agg:addImpact(anchor, n, 0, nil, now)
      end
    end
  end
end

-- (G) Single per-frame entry point from scratches_detect. The vehicle sends
-- its id, the frame's discrete events and every slide stream that ended this
-- frame in ONE call. World -> vehicle-local conversion happens here, once per
-- batch (one matrix inverse per frame instead of one per event).
--   events  : list of {x,y,z,nx,ny,nz,kind,sev}
--             kind "i" = collision impact, "s" = 1-point slide fallback;
--             sev = normalForce in N.
--   streams : list of point lists, each {{x,y,z,nx,ny,nz}, ...} (>= 2 points)
-- A batch from any vehicle other than the current player car is dropped —
-- it would be converted with the wrong car's matrix.
M.ingest = function(vid, events, streams)
  if not ready then return end
  local veh = getPlayerVehicle(0)
  if not veh or veh:getId() ~= vid then
    stampStats.foreignDropped = stampStats.foreignDropped + 1
    return
  end
  if not resolveDecalProjection() then return end
  -- World-space contacts, before they are converted to the car's frame: what
  -- scraped the road leaves paint on it.
  if groundPaint then pcall(groundPaint.ingestWorld, veh, events, streams) end

  local invM    = veh:getRefNodeMatrix():fullInverse()
  local rotOnly = invM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))
  if wear.on then
    local ti = clockhp()
    ingestWear(events, streams, invM, rotOnly)
    perfAdd(ti, "ingestMsTotal", "ingestMsMax", "ingestCalls")
    return
  end

  if events then
    for i = 1, #events do
      local e = events[i]
      local lp = invM:mulP3F(vec3(e[1], e[2], e[3]))
      local ln = rotOnly:mulP3F(vec3(e[4], e[5], e[6]))
      if e[7] == "i" then
        enqueueImpact(lp, ln, e[8], vid)
      else
        enqueueStamp(lp, ln, styleForEvent(nil, e[8]), vid)
      end
    end
  end

  if streams then
    for si = 1, #streams do
      local points = streams[si]
      if points and #points >= 2 then enqueueSlide(points, invM, rotOnly, vid) end
    end
  end
end

-- Wheel fling throw angles, degrees above horizontal, one per deposit in turn.
local FLING_LIFT = { 70, 35, 52, 84, 24, 60 }

-- Contact positions are a conservative splash proxy, not a fluid simulation.
-- Existing projection/hull aiming and all scheduler budgets remain in use.
M.ingestSurface = function(vid, samples, wet, supported, fraction)
  local veh = getPlayerVehicle(0)
  if not ready or not veh or veh:getId() ~= vid then return end
  surfaceState.waterSupported = supported == true
  if wet == true and supported == true then surfaceWaterAge = 0; waterFraction=math.max(0,math.min(1,tonumber(fraction) or 1)); return end
  local kinds = {mud=true,dirt=true,snow=true}
  local inv = veh:getRefNodeMatrix():fullInverse()
  local rot = inv:copy(); rot:setColumn(3,vec3(0,0,0))
  for i=1,math.min(3, type(samples) == "table" and #samples or 0) do
    local e = samples[i]
    local valid = type(e) == "table" and kinds[e[1]] == true
    for j=2,7 do
      local n = type(e) == "table" and e[j]
      if type(n) ~= "number" or n ~= n or math.abs(n) > 1e7 then valid=false end
    end
    if valid then
      surfaceState[e[1]] = math.min(1, surfaceState[e[1]] + 0.025)
      local worldPos=vec3(e[2],e[3],e[4])
      local p = inv:mulP3F(worldPos)
      local normal = rot:mulP3F(vec3(e[5],e[6],e[7]))
      local flow, spraySpeed, trailLength, projectionDepth
      if e[8] == 1 then
        if e[1] ~= "snow" then
          local velocity = veh:getVelocity()
          local localVelocity = rot:mulP3F(velocity)
          -- Fling: the tread throws soil up and back. Successive deposits
          -- step through a fan of throw angles, so a wheel builds a rooster
          -- tail rather than one stripe; faster travel flattens and lengthens
          -- it. A placement rule, not a fluid simulation.
          spraySpeed = math.abs(localVelocity.y)
          if spraySpeed > 0.5 then
            local phase = surfaceState.deposits % 6
            local lift = math.rad(math.max(16, FLING_LIFT[phase + 1] - spraySpeed * 1.1))
            flow = vec3(0, (localVelocity.y > 0 and -1 or 1) * math.cos(lift), math.sin(lift))
            trailLength = math.min(1.45, 0.6 + spraySpeed * 0.05) * (0.85 + 0.05 * (phase % 4))
          end
        end
        local box = getSpawnAabb()
        if box then
          local lo, hi = box.minExtents, box.maxExtents
          local side = p.x >= (lo.x+hi.x)*0.5 and 1 or -1
          -- The spawn box includes mirrors. Reach the recessed quarter/body
          -- from its outer face, but keep the slab short of the centerline
          -- (half-depth < half-width), so it cannot paint the opposite flank.
          projectionDepth=math.min(1.8,(hi.x-lo.x)*0.9)
          -- Lift wheel-ground samples onto the lower exterior flank, with
          -- bounded deterministic spread; never aim upward through the floor.
          local phase = surfaceState.deposits % 8
          p.x = side > 0 and hi.x or lo.x
          if flow then
            -- The fan's source is 7 % in from the brush's left edge
            -- (tools/generate_fling.py). Put it at the back of the tyre, just
            -- above the ground, and let the throw cross panel seams freely.
            local back = flow.y > 0 and 1 or -1
            p.y = p.y + back * 0.18 + flow.y * trailLength * 0.43
            p.z = lo.z + 0.18 + flow.z * trailLength * 0.43
          else
            local inward=p.y>(lo.y+hi.y)*0.5 and -0.65 or 0.65
            p.y=math.max(lo.y+0.3,math.min(hi.y-0.3,p.y+inward+(phase%4-1.5)*0.24))
            p.z=lo.z+(hi.z-lo.z)*(0.38+math.floor(phase/4)*0.10)
          end
          normal = vec3(side,0,0)
        end
      end
      surfaceState.lastSample = {kind=e[1],wheel=e[8],x=p.x,y=p.y,z=p.z,
        flowY=flow and flow.y,flowZ=flow and flow.z,trailLength=trailLength,depth=projectionDepth}
      local key = e[1]..":"..math.floor(p.x*3)..":"..math.floor(p.y*3)..":"..math.floor(p.z*3)
      if surfaceState.deposits < 96 and (surfaceSpots[key] or 0) < 12
          and surfaceWaterAge > 0.5 then
        local c,source,material,texture=soilColor.resolve(e[1],worldPos)
        surfaceState.lastSample.color=c
        surfaceState.lastSample.colorSource=source
        surfaceState.lastSample.terrainMaterial=material
        surfaceState.lastSample.terrainTexture=texture
        surfaceSpots[key] = (surfaceSpots[key] or 0)+1
        surfaceState.deposits = surfaceState.deposits+1
        enqueueStamp(p, normal, {
          soil=true,r=c[1],g=c[2],b=c[3],a=0.95,
          scale=trailLength or 0.65,
          width=flow and trailLength*0.5 or nil,flow=flow,skipMetal=true,noJitter=true,
          depth=projectionDepth,
          dist=flow and trailLength*2.2 or nil,
          flipY=flow and (surfaceState.deposits%2==0 and 1 or -1) or nil,
          colorTex="/art/dynamicDecals/textures/soil_"..e[1]..
            (flow and ("_fling_"..(surfaceState.deposits%(e[1]=="mud" and 3 or 2)+1)..".png") or "_coverage.png"),
          rot=flow and 0 or (surfaceState.deposits%4)*math.pi/2},vid)
      end
    end
  end
end

-- Console / legacy entry points, routed through ingest so they share the
-- player-vehicle check and the per-frame pipeline.
M.stampBatch = function(events)
  local veh = getPlayerVehicle(0)
  if veh then M.ingest(veh:getId(), events, nil) end
end

M.stampStream = function(points)
  if not points or #points < 2 then
    log('W', logTag, string.format("stampStream: need >=2 points, got %d",
      points and #points or 0))
    return
  end
  local veh = getPlayerVehicle(0)
  if veh then M.ingest(veh:getId(), nil, { points }) end
end

-- World-space stamp. Third arg is either a string kind ('impact' -> impact
-- style), an opts table passed through unchanged, or nil (slide style).
M.stampAt = function(worldPos, worldNormal, kindOrOpts, force)
  if not ready then log('W', logTag, "stampAt: not ready"); return end
  if not resolveDecalProjection() then return end
  local veh = getPlayerVehicle(0)
  if not veh then log('W', logTag, "stampAt: no player vehicle"); return end

  local invM    = veh:getRefNodeMatrix():fullInverse()
  local rotOnly = invM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))
  local opts = type(kindOrOpts) == "table" and kindOrOpts or styleForEvent(kindOrOpts, force)
  enqueueStamp(invM:mulP3F(worldPos), rotOnly:mulP3F(worldNormal), opts, veh:getId())
end


-- Test driver: stamps at a vehicle-local position we know lands on the body.
-- Defaults are taken from the testStamp dump (decalPos≈(1.16,0.14,0.36),
-- normal pointing roughly along -X — driver-side door of the sunburst).
-- Pass three args (or six) to override.
M.testStampAt = function(lx, ly, lz, nx, ny, nz)
  local localPos    = vec3(lx or 1.16, ly or 0.14, lz or 0.36)
  local localNormal = vec3(nx or -1,   ny or 0,    nz or 0)
  return M.stampAtLocal(localPos, localNormal)
end

-- Probe each brush texture with a distinct color at a row of vehicle-local
-- positions. Lets us tell at-a-glance which brushes actually load:
--   red dot only    -> only the vanilla shape_circle.png is loading
--                      (our brush PNGs aren't being picked up by BeamNG's vfs
--                      — typically means the texture cache hasn't seen them
--                      yet; full game restart usually fixes)
--   all colors      -> brushes load fine; the "nothing visible" was something
--                      else (lighting, position, etc.)
--   some colors     -> specific PNGs are malformed
M.probeBrushes = function()
  if not ready then log('W', logTag, "probeBrushes: not ready"); return end
  local brushes = {
    {tex = "/art/dynamicDecals/textures/shape_circle.png",  rgb = {1.0, 0.0, 0.0}, name = "vanilla shape_circle (RED)"},
    {tex = "/art/dynamicDecals/textures/scr_scrape_01.png", rgb = {0.0, 1.0, 0.0}, name = "scrape_01 (GREEN)"},
    {tex = "/art/dynamicDecals/textures/scr_scrape_02.png", rgb = {0.0, 1.0, 1.0}, name = "scrape_02 (CYAN)"},
    {tex = "/art/dynamicDecals/textures/scr_scrape_03.png", rgb = {1.0, 1.0, 0.0}, name = "scrape_03 (YELLOW)"},
    {tex = "/art/dynamicDecals/textures/scr_haze_01.png",   rgb = {1.0, 0.0, 1.0}, name = "haze_01 (MAGENTA)"},
    {tex = "/art/dynamicDecals/textures/scr_chips_01.png",  rgb = {0.5, 1.0, 0.5}, name = "chips_01 (LIGHT GREEN)"},
    {tex = "/art/dynamicDecals/textures/scr_chips_02.png",  rgb = {0.5, 0.5, 1.0}, name = "chips_02 (LIGHT BLUE)"},
    {tex = "/art/dynamicDecals/textures/scr_gouge_01.png",  rgb = {1.0, 0.5, 0.0}, name = "gouge_01 (ORANGE)"},
    {tex = "/art/dynamicDecals/textures/scr_gouge_02.png",  rgb = {1.0, 0.0, 0.5}, name = "gouge_02 (PINK)"},
  }
  -- 9 brushes at 0.05 m spacing → ±0.20 m Y spread, stays on body for small
  -- vehicles too. X=1.0 / Z=0.4 is a right-door-ish point known to hit pigeon
  -- (verified from impact events) and well within bounds for larger vehicles.
  for i, brush in ipairs(brushes) do
    local y = -0.20 + (i - 1) * 0.05
    log('I', logTag, string.format("probe %d: %s at local (%.2f, %.2f, %.2f)", i, brush.name, 1.0, y, 0.4))
    M.stampAtLocal(vec3(1.0, y, 0.4), vec3(1, 0, 0), {
      colorTex = brush.tex,
      r = brush.rgb[1], g = brush.rgb[2], b = brush.rgb[3],
      scale = 0.15,
      rot = 0,
      noJitter = true,
      skipMetal = true,  -- want raw color tint visible, not metal-shaded
    })
  end
  log('I', logTag, "probeBrushes done. Check the right side of the vehicle.")
end

-- Round-trip test for the world-coord wrapper M.stampAt:
-- takes vehicle-LOCAL args, converts to WORLD via veh:getRefNodeMatrix(),
-- calls M.stampAt (which internally converts back to local). If our
-- world<->local plumbing is symmetric, the result decalPos should equal
-- the original vehicle-local input. Defaults to the same spot as testStampAt
-- so you can call them back-to-back and expect identical decalPos.
M.testStampAtWorld = function(lx, ly, lz, nx, ny, nz)
  local veh = getPlayerVehicle(0)
  if not veh then log('W', logTag, "no player vehicle"); return end

  local localPos    = vec3(lx or 1.16, ly or 0.14, lz or 0.36)
  local localNormal = vec3(nx or -1,   ny or 0,    nz or 0)

  local refM    = veh:getRefNodeMatrix()
  local rotOnly = refM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))
  local worldPos    = refM:mulP3F(localPos)
  local worldNormal = rotOnly:mulP3F(localNormal)

  log('I', logTag, string.format(
    "testStampAtWorld: localIn=(%.2f,%.2f,%.2f) -> worldPos=(%.2f,%.2f,%.2f) worldNorm=(%.2f,%.2f,%.2f)",
    localPos.x, localPos.y, localPos.z,
    worldPos.x, worldPos.y, worldPos.z,
    worldNormal.x, worldNormal.y, worldNormal.z))
  return M.stampAt(worldPos, worldNormal)
end

-- Wipe all stamps (clears the layer stack and re-bakes empty texture), then
-- re-seed the paint canvas so metallic/roughness baseline is restored.
--
-- Why we don't just call api.clearLayerStack: that path goes through the
-- editor's history machinery (history:commitAction at dynamicDecals.lua:1638),
-- which dedups identical actions (history.lua:149). Repeated clears with the
-- same layer-stack snapshot get skipped — the Redo (which is what actually
-- calls clearBakedTextures) never runs and the visible scratches survive.
-- We still call api.clearLayerStack to keep the Lua-side layerStack tracking
-- in sync, but the actual texture wipe is done directly: clearBakedTextures()
-- erases the baked scratches (the same primitive BeamNG's reprojectLayers and
-- clearLayerStack_Redo use), then flushDynamicTextures + combineTextures
-- clears the working stage and pushes the blank into the vehicle's texture set
-- immediately. No history, no dedup.
M.clearStamps = function()
  resetSurfaceState()
  local veh = getPlayerVehicle(0)
  if ready and (not veh or currentPaintDesignPart() ~= (adapter and adapter.part or (veh.JBeam or veh.jbeam) .. "_skin_dynamicTextures")) then
    if veh then onVehicleSwitched(veh:getId(), veh:getId(), 0) end
    return
  end
  if not ready then log('W', logTag, "clearStamps: not ready"); return end
  if not resolveDecalProjection() then return end
  -- (2.1) Diagnostic: how many layers are about to be wiped. On a vehicle
  -- whose livery is editor-painted (dynamic-decal layers), a high count here
  -- means the wipe is destroying the player's livery, not just our scratches.
  local preClearLayers = (api and api.getLayerCount and api.getLayerCount()) or "?"
  -- Drop any pending stamps before clearing — otherwise the next onUpdate
  -- flushes them into the freshly-cleared layer stack and the wipe is
  -- partially undone.
  pendingStampInputs = {}
  pendingStampsVid   = nil
  M._dropQueuedJobs()
  -- (a) Reset Lua-side layerStack tracking so the api's layer count and our
  --     visible state agree. pcall-guarded because the history call can
  --     short-circuit on dedup, which would otherwise propagate as nil.
  if api and api.clearLayerStack then
    pcall(api.clearLayerStack)
  end
  -- (b) Direct texture wipe. Skips history entirely.
  --   clearBakedTextures() is what actually erases the scratches: the mod
  --   bakes stamps additively into the BAKED textures, and this is the
  --   primitive BeamNG's own reprojectLayers / clearLayerStack_Redo use to
  --   wipe baked content. The old code only called flushDynamicTextures,
  --   which resets the working/dynamic stage — baked scratches survived
  --   untouched, which is exactly why Ctrl+R never cleared them.
  if decalProjection.clearBakedTextures then
    decalProjection:clearBakedTextures()
  end
  --   flush resets the dynamic/working textures; combine pushes the cleared
  --   content into the vehicle's texture set so the wipe shows immediately
  --   (otherwise it only appears on the next per-frame combine).
  if decalProjection.flushDynamicTextures then
    decalProjection:flushDynamicTextures()
    if decalProjection.combineTextures and api and api.getTextureSet then
      local ts = api.getTextureSet()
      if ts then decalProjection:combineTextures(ts) end
    end
  end
  combineDirty = true
  rebindDirty  = true
  table.clear(spotHits)
  log('I', logTag, "cleared all stamps (textures flushed); layers before clear=" ..
    tostring(preClearLayers))
  -- Re-point metallic/roughness at the static factory maps before re-seeding.
  -- restoreFactoryMR otherwise runs exactly once, from the binding stabilizer
  -- at setup — but a respawn (the Ctrl+R path that gets us here) can rebuild
  -- the .skin.dynamicTextures materials, which puts M/R back on the dynamic
  -- canvas we just wiped. That is precisely the matte-body symptom Phase 3.3
  -- chased. Idempotent and cheap at clear frequency, so just re-assert it.
  restoreFactoryMR()
  -- Re-seed the baseColor channel. clearBakedTextures zeroed it; the fill
  -- layer repaints every texel uniformly.
  M.addPaintFill()
end

-- Convenience: dump the current decal config (helpful when iterating).
-- Comprehensive diagnostic of the projection/material binding state. If
-- getDecalData is returning garbage, this is where we find out why.
M.deepProbe = function()
  if not ready then log('W', logTag, "not ready"); return end
  log('I', logTag, "----- deep probe -----")

  -- Vehicle side
  local veh = getPlayerVehicle(0)
  log('I', logTag, "veh: " .. tostring(veh) .. ", id=" .. tostring(veh and veh:getId()))
  if veh then
    local ok, shape = pcall(function() return veh:getDecalProjectionShape() end)
    log('I', logTag, "veh:getDecalProjectionShape() ok=" .. tostring(ok) .. " shape=" .. tostring(shape))
    local ok2, refM = pcall(function() return veh:getRefNodeMatrix() end)
    log('I', logTag, "veh:getRefNodeMatrix() ok=" .. tostring(ok2) .. " m=" .. tostring(refM))
    local box = getSpawnAabb()
    if box then
      log('I', logTag, "spawn AABB min=" .. tostring(box.minExtents) .. " max=" .. tostring(box.maxExtents))
    end
  end

  -- API state
  log('I', logTag, "api.ready = " .. tostring(api.ready))
  log('I', logTag, "api.projectDynamicDecals = " .. tostring(api.projectDynamicDecals))
  log('I', logTag, "api.lockDepth = " .. tostring(api.getLockDepth and api.getLockDepth()))
  log('I', logTag, "api.isUseMousePos = " .. tostring(api.isUseMousePos and api.isUseMousePos()))
  log('I', logTag, "api.layerCount = " .. tostring(api.getLayerCount and api.getLayerCount()))
  log('I', logTag, "api.getMeshObjectCount = " .. tostring(api.getMeshObjectCount and api.getMeshObjectCount()))

  -- Material binding
  if api.getMaterialIndices then
    local ok, idx = pcall(api.getMaterialIndices)
    log('I', logTag, "getMaterialIndices ok=" .. tostring(ok) .. " result=" .. dumps(idx))
  end
  if api.getShapeMaterialNames then
    local ok, names = pcall(api.getShapeMaterialNames)
    log('I', logTag, "getShapeMaterialNames ok=" .. tostring(ok) .. " (count=" ..
        tostring(names and #names) .. ")")
    if ok and names then
      for i = 1, math.min(20, #names) do
        log('I', logTag, "  [" .. i .. "] " .. tostring(names[i]))
      end
    end
  end

  -- Texture state
  if api.getTextureResolution then
    local ok, res = pcall(api.getTextureResolution)
    log('I', logTag, "textureResolution ok=" .. tostring(ok) .. " " .. tostring(res))
  end
end

-- Toggle the per-stamp log line in stampAtLocal/stampStream. Default off
-- (the log wall a roll produces is huge and the per-event info is mostly
-- only useful for debugging projection misses).
M.setStampVerbose = function(b)
  stampVerbose = b and true or false
  log('I', logTag, "stampVerbose = " .. tostring(stampVerbose))
end

-- Per-frame bake-queue cap. Raise on a fast machine, lower if frames hitch
-- during spectacular rolls.
M.setAggregateCap = function(n)
  AGGREGATE_PER_FRAME_CAP = math.max(1, math.floor(tonumber(n) or 160))
  log('I', logTag, "AGGREGATE_PER_FRAME_CAP = " .. tostring(AGGREGATE_PER_FRAME_CAP))
end

-- Aggregate paint-side counters since extension load. Replaces the visibility
-- the per-stamp log provided when stampVerbose is off.
M.dumpPaintStats = function()
  log('I', logTag, "----- paint stats -----")
  log('I', logTag, string.format("stampsAttempted        = %d", stampStats.stampsAttempted))
  log('I', logTag, string.format("stampsEnqueued         = %d", stampStats.stampsEnqueued))
  log('I', logTag, string.format("stampsSkippedMissed    = %d  (out-of-frustum at flush)",
    stampStats.stampsSkippedMissed))
  log('I', logTag, string.format("aggregateDropped       = %d  (cap=%d/frame)",
    stampStats.aggregateDropped, AGGREGATE_PER_FRAME_CAP))
  log('I', logTag, string.format("framesFlushed          = %d", stampStats.framesFlushed))
  log('I', logTag, string.format("bakesIssued (discrete) = %d", stampStats.bakesIssued))
  log('I', logTag, string.format("projectsIssued         = %d  (clusterRadius=%.2fm)",
    stampStats.projectsIssued, CLUSTER_RADIUS))
  log('I', logTag, string.format("clustersTotal          = %d", stampStats.clustersTotal))
  log('I', logTag, string.format("streamsBaked           = %d", stampStats.streamsBaked))
  log('I', logTag, string.format("streamSubstrokesTotal  = %d  (avg %.2f sub-strokes/stream)",
    stampStats.streamSubstrokesTotal,
    stampStats.streamsBaked > 0 and (stampStats.streamSubstrokesTotal / stampStats.streamsBaked) or 0))
  log('I', logTag, string.format("stretchChunkLen        = %.2fm  (cap=%d segments/stream)",
    STRETCH_MAX_SEGMENT_LEN, STRETCH_MAX_SEGMENTS_PER_STREAM))
  log('I', logTag, string.format("queueLen now           = %d stamps, %d jobs (budget %d/frame)",
    #pendingStampInputs, #jobQueue, MAX_PROJECTS_PER_FRAME))
  log('I', logTag, string.format("jobsDropped            = %d  (backlog cap %d)",
    stampStats.jobsDropped, MAX_QUEUED_JOBS))
  log('I', logTag, string.format("jobsFailed             = %d  (threw; see log)",
    stampStats.jobsFailed))
  log('I', logTag, string.format("framesDeferred         = %d  (hit budget with work left)",
    stampStats.framesDeferred))
  log('I', logTag, string.format("foreignDropped         = %d  (batches from a non-player car)",
    stampStats.foreignDropped))
  log('I', logTag, string.format("combines               = %d / %d frames  (fullRate=%s)",
    stampStats.combinesRun, stampStats.framesTicked, tostring(fullRateCombine)))
  if perfStats.frames > 0 then
    log('I', logTag, string.format("painter cost           = avg %.3f ms/frame, max %.2f ms, >1ms %d, >4ms %d (%d frames)",
      perfStats.msTotal / perfStats.frames, perfStats.msMax,
      perfStats.framesOver1ms, perfStats.framesOver4ms, perfStats.frames))
    log('I', logTag, string.format("  flush (project+bake) = %.1f ms total, max %.2f ms; composite = %.1f ms total, max %.2f ms",
      perfStats.flushMsTotal, perfStats.flushMsMax, perfStats.combineMsTotal, perfStats.combineMsMax))
  end
  if stampStats.stampsAttempted > 0 then
    log('I', logTag, string.format("missed-projection rate = %.1f%%",
      100 * stampStats.stampsSkippedMissed / stampStats.stampsAttempted))
  end
  if stampStats.framesFlushed > 0 then
    log('I', logTag, string.format("avg discrete stamps/bake = %.2f",
      stampStats.stampsEnqueued / stampStats.framesFlushed))
    log('I', logTag, string.format("avg projects/frame       = %.2f  (was 1 per stamp before F)",
      stampStats.projectsIssued / stampStats.framesFlushed))
    log('I', logTag, string.format("avg clusters/frame       = %.2f",
      stampStats.clustersTotal / stampStats.framesFlushed))
  end
end

M.resetPaintStats = function()
  stampStats.stampsAttempted = 0
  stampStats.stampsEnqueued = 0
  stampStats.stampsSkippedMissed = 0
  stampStats.aggregateDropped = 0
  stampStats.framesFlushed = 0
  stampStats.bakesIssued = 0
  stampStats.bakeFailures = 0
  stampStats.layersLost = 0
  stampStats.projectsIssued = 0
  stampStats.clustersTotal = 0
  stampStats.clusterJobsMerged = 0
  stampStats.streamsBaked = 0
  stampStats.streamSubstrokesTotal = 0
  stampStats.streamLayersExpected = 0
  stampStats.streamLayersMissed = 0
  stampStats.jobsDropped = 0
  stampStats.jobsFailed = 0
  stampStats.framesDeferred = 0
  stampStats.foreignDropped = 0
  stampStats.combinesRun = 0
  stampStats.rebinds = 0
  stampStats.spotsSkipped = 0
  stampStats.streamsMerged = 0
  stampStats.framesTicked = 0
  for k in pairs(perfStats) do perfStats[k] = 0 end
  syntheticAnchorCount = 0
  wear.painted = 0
  for k in pairs(wear.agg.counts) do wear.agg.counts[k] = 0 end
  table.clear(nativeEvents)
  for _,p in pairs(nativeProfiles) do table.clear(p.bins);p.count=0;p.maxMs=0 end
  log('I', logTag, "paint stats reset")
end

M.getNativeTimingProfile = function()
  local out={}
  for name,p in pairs(nativeProfiles) do
    local row={calls=p.count,maxMs=p.maxMs,overflowCalls=p.bins[1901] or 0}
    for _,q in ipairs({95,99}) do
      local count,target=0,math.ceil(p.count*q/100)
      if p.count>0 then
        for i=1,1901 do
          count=count+(p.bins[i] or 0)
          if count>=target then
            row["p"..q]=i==1901 and {aboveMs=1000} or {upperMs=i<=1000 and i/10 or i-900}
            break
          end
        end
      end
    end
    out[name]=row
  end
  return out
end

-- Machine-readable snapshot of every counter, for tools/bench.py and anything
-- else that wants numbers rather than log lines. Copies, so callers can keep it.
M.getStats = function()
  local stamp, perf, events = {}, {}, {}
  for i,v in ipairs(nativeEvents) do events[i]=v end
  for k, v in pairs(stampStats) do stamp[k] = v end
  for k, v in pairs(perfStats) do perf[k] = v end
  local oldest
  for _,q in ipairs({pendingStampInputs,jobQueue,bakeQueue}) do
    for _,v in ipairs(q) do
      local born=v.queuedAt or v._scratchesQueuedAt
      if born then oldest=oldest and math.min(oldest,born) or born end
    end
  end
  return {
    generation=cosmeticGeneration, nativeEvents=events,
    coverage = coverage and coverage:snapshot() or {enabled=false},
    latency = {oldestMs=oldest and (clockhp()-oldest)*1000 or 0},
    ready  = ready,
    stamp  = stamp,
    perf   = perf,
    detect = lastDetectStats,
    queue  = { stamps = #pendingStampInputs, jobs = #jobQueue, bake = #bakeQueue,
               patches = wear.agg:pending() and 1 or 0 },
    config = { contactPatches = wear.on, patchInterval = wear.agg.interval, aggregateCap = AGGREGATE_PER_FRAME_CAP, clusterRadius = CLUSTER_RADIUS,
               projBudget = MAX_PROJECTS_PER_FRAME, flushInterval = FLUSH_INTERVAL,
               layerBudget = MAX_LAYERS_PER_FLUSH, bakeBudget = BAKE_LAYERS_PER_FRAME,
               damageWidth = adapter and adapter:getDamageWidth() or 0, coverageCoalescing=coverage~=nil, panelGrouping=panelGrouping,
               fullRateCombine = fullRateCombine, syntheticAnchors = syntheticAnchors },
    anchors = { synthesized = syntheticAnchorCount },
    ground = groundPaint and groundPaint.getStats() or { enabled = false, alive = 0, submitted = 0, dropped = 0 },
    wear = { enabled = wear.on, painted = wear.painted, warmed = wear.warmedCount,
             warmPending = wear.warm and #wear.warm or -1, pending = wear.agg:pending(),
             patches = wear.agg:stats() },
  }
end

-- The painter's cost on the most recent ready frame (ms); bench samples it.
M.getLastFrameMs = function() return perfStats.lastMs end

-- Projection passes allowed per frame. Lower = flatter frame times during a
-- big crash (marks trickle in over a few frames); higher = marks land sooner.
-- Changing quality clears cosmetics explicitly; only our private damage target changes.
M.setDamageResolution = function(width)
  width=tonumber(width)
  assert(adapter and ready, "private body material adapter required")
  assert(width==4096 or width==2048 or width==1024, "use 4096, 2048 or 1024")
  if adapter:getDamageWidth()==width then return end
  M.clearStamps()
  adapter:setDamageWidth(width)
  combineDirty=true; rebindDirty=true
end
M.setCoverageCoalescing = function(enabled)
  if (coverage~=nil)==(enabled and true or false) then return end
  M.clearStamps()
  if enabled then
    coverageModule=coverageModule or dofile("/lua/ge/extensions/scratches/coverage.lua")
    coverage=coverageModule.new(clockhp)
  else coverage=nil end
end
M.setPanelGrouping = function(enabled) panelGrouping=enabled and true or false end
-- true (default): contacts fold into patches, one rich decal per patch, at
-- most one bake per `interval` seconds. false: the legacy one-decal-per-contact
-- pipeline (kept for comparison and for the scheduler checks).
M.setContactPatches = function(enabled, interval)
  wear.on = enabled and true or false
  wear.agg = patchModule.new({ interval = tonumber(interval) })
end
-- true (default): projection-free anchors from the detector's contact points.
-- false: legacy native projection per job. Applies to work captured afterwards.
-- Paint and rubber left on the road (groundPaint.lua). Off also forgets the
-- marks already laid. clearGroundPaint wipes them without switching it off.
M.setGroundPaint = function(enabled) if groundPaint then groundPaint.setEnabled(enabled) end end
M.clearGroundPaint = function() if groundPaint then groundPaint.clear() end end
M.setSyntheticAnchors = function(enabled) syntheticAnchors=enabled and true or false end
M.setBakeBudget = function(n)
  BAKE_LAYERS_PER_FRAME=math.max(1,math.min(24,math.floor(tonumber(n) or 6)))
end

M.setProjectionBudget = function(n)
  MAX_PROJECTS_PER_FRAME = math.max(1, math.floor(tonumber(n) or 6))
  log('I', logTag, "MAX_PROJECTS_PER_FRAME = " .. tostring(MAX_PROJECTS_PER_FRAME))
end

-- Seconds between projection batches. Longer = fewer frames pay the ~14 ms
-- projection toll (smoother crashes); shorter = marks appear sooner.
-- Decal layers captured per flush (they're baked over the following frames,
-- BAKE_LAYERS_PER_FRAME at a time). Leftover work waits for the next batch.
M.setLayerBudget = function(n)
  MAX_LAYERS_PER_FLUSH = math.max(1, math.floor(tonumber(n) or 24))
  log('I', logTag, "MAX_LAYERS_PER_FLUSH = " .. tostring(MAX_LAYERS_PER_FLUSH))
end

M.setFlushInterval = function(sec)
  FLUSH_INTERVAL = math.max(0, tonumber(sec) or 0.20)
  log('I', logTag, string.format("FLUSH_INTERVAL = %.3fs", FLUSH_INTERVAL))
end

-- Diagnostic escape hatch: true restores the API's every-frame full update
-- (re-bind + composite). Default false: composite only when something
-- changed, re-bind only when the binding can be stale.
M.setFullRateCombine = function(b)
  fullRateCombine = b and true or false
  combineDirty = true
  log('I', logTag, "fullRateCombine = " .. tostring(fullRateCombine))
end

-- Tune the clustering radius. Smaller = more clusters = more projects, but
-- shared cam covers a tighter area (more accurate for off-axis stamps).
M.setClusterRadius = function(meters)
  CLUSTER_RADIUS = math.max(0.1, tonumber(meters) or 0.65)
  log('I', logTag, string.format("CLUSTER_RADIUS = %.2fm", CLUSTER_RADIUS))
end

-- ---- (K) IMGUI debug + tuning panel ----

-- Canonical default values for every tunable the panel exposes. The Reset
-- Defaults button writes these back into the slider pointers and pushes
-- them to the VLUA side. Keep in sync with the matching constants in
-- scratches_detect.lua and the AGGREGATE_PER_FRAME_CAP / CLUSTER_RADIUS
-- definitions further up this file.
local UI_DEFAULTS = {
  slip       = 0.6,
  paintCool  = 0.003,
  impForce   = 800,
  impCool    = 0.025,
  aggCap     = 160,
  clusterRad = 0.65,
  projBudget = 6,
  paintColor = true,
}

-- One-click presets. Each row is a complete tunable set the user can swap
-- between to test how the system feels at different sensitivity levels.
-- Ordered light -> extreme so the buttons read left-to-right on the panel.
--
--   Light    — only obvious hits + fast slides leave marks. Bodywork stays
--              mostly clean. Good for "professional driver" simulations.
--   Default  — current sensible defaults. Realistic damage from real crashes.
--   Heavy    — catches lighter contacts; cars accumulate visible wear faster.
--   Max      — every brush, drag, and bump leaves a mark. Cars look beat-up
--              after one good roll. Costs more CPU+GPU but tractable.
--   Extreme  — sensitivity floor + cap ceiling. Built to push hardware:
--              ~200 samples/sec per sliding node, impact cooldown 50ms,
--              tightest clustering = most depth-pass renders/frame.
local UI_PRESETS = {
  { name = "Light",
    slip = 3.0,  paintCool = 0.05,
    impForce = 7000, impCool = 0.6,
    aggCap = 48,  clusterRad = 1.3,  projBudget = 3,
    desc = "Subtle. Only fast slides + solid hits leave marks.\n" ..
           "Easy on hardware. Realistic 'careful driver' look." },
  { name = "Default",
    slip = 0.6,  paintCool = 0.003,
    impForce = 800, impCool = 0.025,
    aggCap = 160, clusterRad = 0.65, projBudget = 6,
    desc = "Aggressive 10x damage. Long slides build dense scratches;\n" ..
           "light smashes leave visible chip/claw marks." },
  { name = "Heavy",
    slip = 0.45,  paintCool = 0.0025,
    impForce = 650, impCool = 0.020,
    aggCap = 192, clusterRad = 0.55, projBudget = 8,
    desc = "Very aggressive. More contact noise turns into visible wear;\n" ..
           "use when the scene should look heavily abused." },
  { name = "Max",
    slip = 0.35,  paintCool = 0.002,
    impForce = 500, impCool = 0.015,
    aggCap = 224, clusterRad = 0.45, projBudget = 10,
    desc = "Every drag, bump, and dent leaves a mark.\n" ..
           "Banged-up look after one good roll.\n" ..
           "Notable CPU+GPU cost; should still hold steady framerate." },
  { name = "Extreme",
    slip = 0.25,  paintCool = 0.0015,
    impForce = 350,  impCool = 0.010,
    aggCap = 256, clusterRad = 0.35, projBudget = 16,
    desc = "Built to stress hardware. ~200 samples/sec/node, 50ms impact\n" ..
           "cooldown, tightest cluster radius = most depth-pass renders.\n" ..
           "Expect frame hitches on slower GPUs during heavy crashes." },
}

-- Inline tooltip: BeamNG ImGui's IsItemHovered + SetTooltip on the line
-- right after the widget. Tooltip wraps automatically; multi-line content
-- separated by \n.
local function uiTooltip(text)
  local im = ui_imgui
  if im and im.IsItemHovered and im.IsItemHovered() then
    im.SetTooltip(text)
  end
end

-- Receiver for the periodic stats snapshot pushed by scratches_detect. The
-- detect side has no way to read its own state from GE, so it sends one
-- table-literal per ~0.25s; we just store the latest.
M.recordDetectStats = function(s) lastDetectStats = s or {} end

-- (1.2) Receiver for vehicle-side (VLUA) log lines. The detector mirrors its
-- log lines into a ring and ships new ones piggybacked on the stats push; we
-- merge them into the same GE log ring tagged src='VEH' so the panel and the
-- copy-report show one unified, labeled timeline. `lines` is an array of
-- {level, message} pairs.
M.recordDetectLog = function(lines)
  if type(lines) ~= 'table' then return end
  for i = 1, #lines do
    local e = lines[i]
    if type(e) == 'table' then
      ringPush(e[1] or 'I', 'VEH', tostring(e[2]))
    end
  end
end

-- (M) Receiver for the on-demand full dump pushed by scratches_detect when
-- the user clicks "Dump Stats" in the IMGUI panel. The text is rendered
-- inline below the button row so the whole state fits in one screenshot.
local lastFullDump = ""
M.recordFullDump = function(text) lastFullDump = text or "" end

-- Toggle visibility of the debug window. Idempotent. Lazy-creates ImGui
-- pointers on first show.
M.toggleUI = function()
  uiVisible = not uiVisible
  log('I', logTag, "UI " .. (uiVisible and "shown" or "hidden"))
end

-- Build slider-backing ImGui pointer values once. Initial values match the
-- current code defaults; the periodic snapshot from detect.lua refreshes
-- the slide/impact ones to whatever the VLUA side actually has.
local function ensureUIPointers()
  if uiPtrs then return true end
  local im = ui_imgui
  if not im then return false end
  uiPtrs = {
    slip       = im.FloatPtr(UI_DEFAULTS.slip),
    paintCool  = im.FloatPtr(UI_DEFAULTS.paintCool),
    impForce   = im.FloatPtr(UI_DEFAULTS.impForce),
    impCool    = im.FloatPtr(UI_DEFAULTS.impCool),
    aggCap     = im.IntPtr(AGGREGATE_PER_FRAME_CAP),
    clusterRad = im.FloatPtr(CLUSTER_RADIUS),
    projBudget = im.IntPtr(MAX_PROJECTS_PER_FRAME),
    fullRate   = im.BoolPtr(fullRateCombine),
    paintColor = im.BoolPtr(PAINT_SEED_COLOR),
    logWErr    = im.BoolPtr(false),  -- log pane: warnings & errors only
  }
  uiClosePtr = im.BoolPtr(true)
  return true
end

-- Sync slider pointers from the latest VLUA snapshot so they reflect ground
-- truth (e.g. if someone called setThresholds from console). Only updates
-- pointers the user isn't actively dragging — ImGui's item-active query
-- avoids fighting the user's input.
local function syncUIPointersFromSnapshot()
  if not (uiPtrs and lastDetectStats) then return end
  local im = ui_imgui
  if im.IsAnyItemActive and im.IsAnyItemActive() then return end
  if lastDetectStats.slip      then uiPtrs.slip[0]      = lastDetectStats.slip end
  if lastDetectStats.paintCool then uiPtrs.paintCool[0] = lastDetectStats.paintCool end
  if lastDetectStats.impForce  then uiPtrs.impForce[0]  = lastDetectStats.impForce end
  if lastDetectStats.impCool   then uiPtrs.impCool[0]   = lastDetectStats.impCool end
  uiPtrs.aggCap[0]     = AGGREGATE_PER_FRAME_CAP
  uiPtrs.clusterRad[0] = CLUSTER_RADIUS
  uiPtrs.projBudget[0] = MAX_PROJECTS_PER_FRAME
  uiPtrs.fullRate[0]   = fullRateCombine
  uiPtrs.paintColor[0] = PAINT_SEED_COLOR
end

-- Send a tuning command back to the player vehicle's VLUA. detect.lua
-- exposes setThresholds / setImpactParams / setPaintCooldown.
local function sendVehicleCmd(cmd)
  local veh = getPlayerVehicle(0)
  if veh and veh.queueLuaCommand then veh:queueLuaCommand(cmd) end
end

-- Apply a preset row: write the values into the slider pointers, update
-- the GE-only knobs in place, and push the VLUA-side knobs through
-- queueLuaCommand. Logging documents the switch in the console.
local function applyPreset(preset)
  if not (preset and uiPtrs) then return end
  uiPtrs.slip[0]       = preset.slip
  uiPtrs.paintCool[0]  = preset.paintCool
  uiPtrs.impForce[0]   = preset.impForce
  uiPtrs.impCool[0]    = preset.impCool
  uiPtrs.aggCap[0]     = preset.aggCap
  uiPtrs.clusterRad[0] = preset.clusterRad
  uiPtrs.projBudget[0] = preset.projBudget
  AGGREGATE_PER_FRAME_CAP = preset.aggCap
  CLUSTER_RADIUS          = preset.clusterRad
  MAX_PROJECTS_PER_FRAME  = preset.projBudget
  sendVehicleCmd(string.format("scratches_detect.setThresholds(%.3f, nil, nil)",
    preset.slip))
  sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)",
    preset.paintCool))
  sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, %.3f)",
    preset.impForce, preset.impCool))
  log('I', logTag, string.format("preset applied: %s (slip=%.2f cool=%.4f force=%.0f impCool=%.2f cap=%d radius=%.2f budget=%d)",
    preset.name, preset.slip, preset.paintCool, preset.impForce, preset.impCool,
    preset.aggCap, preset.clusterRad, preset.projBudget))
end

-- Live debug + tuning panel. Two columns of read-only counters at the top,
-- then grouped slider sections for slide / impact tunables, then action
-- buttons. Sliders with visible value labels via SliderFloat.
-- ---- (1.3) log pane ----
-- Lazily-built log-level -> colour map. ImVec4 needs ui_imgui loaded, which
-- isn't guaranteed at module-load time, so build it on first use.
local uiLogColors = nil
local function logLevelColor(lvl)
  local im = ui_imgui
  if not uiLogColors then
    uiLogColors = {
      E  = im.ImVec4(1.00, 0.42, 0.42, 1.0),  -- error      - red
      W  = im.ImVec4(1.00, 0.84, 0.36, 1.0),  -- warn       - amber
      I  = im.ImVec4(0.82, 0.84, 0.88, 1.0),  -- info       - light grey
      D  = im.ImVec4(0.55, 0.58, 0.63, 1.0),  -- debug      - dim grey
      OK = im.ImVec4(0.45, 0.86, 0.50, 1.0),  -- status ok  - green
    }
  end
  return uiLogColors[lvl] or uiLogColors.I
end

-- Left pane: the merged GE+VEH log ring. A header row (count, filter, clear)
-- above a scrolling, colour-coded, [SRC]-tagged, word-wrapped list that pins
-- to the bottom only while the user is already scrolled there. TextColored is
-- safe for arbitrary log text here — passed as the single fmt arg, the imgui
-- binding skips string.format when no extra args follow.
local function drawLogPane()
  local im = ui_imgui
  im.Text(string.format("Log  (%d lines)", #logRing))
  im.SameLine()
  im.Checkbox("W/E only", uiPtrs.logWErr)
  uiTooltip("Show only warnings and errors here.\n" ..
            "Info/debug lines stay captured and still go into the copied report.")
  im.SameLine()
  if im.Button("Clear log") then table.clear(logRing) end
  uiTooltip("Drop every captured log line. Does not touch baked decals or stats.")
  im.Separator()

  local weOnly = uiPtrs.logWErr[0]
  im.BeginChild1("scratchesLogScroll", im.ImVec2(0, 0), false)
  im.PushTextWrapPos(0)
  for i = 1, #logRing do
    local e = logRing[i]
    if (not weOnly) or e.lvl == 'W' or e.lvl == 'E' then
      im.TextColored(logLevelColor(e.lvl),
        "[" .. (e.src or '?') .. "] " .. (e.msg or ''))
    end
  end
  im.PopTextWrapPos()
  -- Auto-scroll only when the user is already at the bottom — don't yank them
  -- down while they're scrolled up reading.
  if im.GetScrollY() >= im.GetScrollMaxY() then im.SetScrollHereY(1.0) end
  im.EndChild()
end

-- ---- (1.4) debug report ----
-- Assemble a compact, paste-ready report: environment + a one-line stats and
-- tunables summary + log lines that matter (every warning/error plus recent
-- context for ordering), each [GE]/[VEH]-tagged. Curated on purpose — not a
-- full ring dump. The "Copy debug report" button drops the result onto the
-- clipboard; M.buildDebugReport exposes it for the console.
local REPORT_RECENT_LINES = 50   -- always keep this many most-recent lines
local REPORT_MAX_LINES    = 140  -- hard cap on log lines in the report

local function buildDebugReport()
  local veh   = getPlayerVehicle(0)
  local jbeam = veh and (veh.JBeam or veh.jbeam) or "(no vehicle)"
  local layerCount = (api and api.getLayerCount and api.getLayerCount()) or "?"
  local ds    = lastDetectStats or {}
  local out   = {}
  local function w(s) out[#out + 1] = s end

  w("## scratches_mod debug report")
  w("time: " .. os.date("%Y-%m-%d %H:%M:%S"))
  w("")
  w("### environment")
  w("- vehicle jbeam: " .. tostring(jbeam))
  w("- painter ready: " .. tostring(ready) .. "   pendingSetup: " .. tostring(pendingSetup))
  w("- lastSkinJBeam: " .. tostring(lastSkinJBeam))
  w("- matBindingsStable: " .. tostring(matBindingsStable) .. "   seedDone: " .. tostring(seedDone))
  w("- layer count: " .. tostring(layerCount))
  w("- paint seed color: " .. tostring(PAINT_SEED_COLOR))
  w("")
  w("### stats")
  w(string.format("- GE  : enqueued=%d skippedMissed=%d dropped=%d bakes=%d streams=%d framesFlushed=%d",
    stampStats.stampsEnqueued, stampStats.stampsSkippedMissed, stampStats.aggregateDropped,
    stampStats.bakesIssued, stampStats.streamsBaked, stampStats.framesFlushed))
  w(string.format("- VEH : total=%s filtered=%s impacts=%s streams=%s maxForce=%s",
    tostring(ds.totalCalls), tostring(ds.filteredCalls), tostring(ds.impactEvents),
    tostring(ds.streamsFlushed), tostring(ds.maxNormalForce)))
  w("")
  w("### tunables")
  w(string.format("- slip=%s perp=%s minForce=%s impForce=%s impCool=%s paintCool=%s",
    tostring(ds.slip), tostring(ds.perp), tostring(ds.minForce),
    tostring(ds.impForce), tostring(ds.impCool), tostring(ds.paintCool)))
  w(string.format("- aggregateCap=%d clusterRadius=%.2f projBudget=%d fullRateCombine=%s",
    AGGREGATE_PER_FRAME_CAP, CLUSTER_RADIUS, MAX_PROJECTS_PER_FRAME, tostring(fullRateCombine)))
  w(string.format("- pipeline: backlog=%d deferredFrames=%d jobsDropped=%d jobsFailed=%d foreignDropped=%d composites=%d/%d frames",
    #jobQueue, stampStats.framesDeferred, stampStats.jobsDropped, stampStats.jobsFailed, stampStats.foreignDropped,
    stampStats.combinesRun, stampStats.framesTicked))
  if perfStats.frames > 0 then
    w(string.format("- cost: painter avg %.3f ms/frame, max %.2f ms, frames >4ms %d (flush max %.2f ms, composite max %.2f ms)",
      perfStats.msTotal / perfStats.frames, perfStats.msMax, perfStats.framesOver4ms,
      perfStats.flushMsMax, perfStats.combineMsMax))
  end
  w("")
  w("### log  (warnings/errors + recent context; [GE]=painter [VEH]=detector)")
  local n = #logRing
  local firstRecent = math.max(1, n - REPORT_RECENT_LINES + 1)
  local picked = {}
  for i = 1, n do
    local e = logRing[i]
    if e.lvl == 'W' or e.lvl == 'E' or i >= firstRecent then
      picked[#picked + 1] = string.format("%s [%s] %s", e.lvl or 'I', e.src or '?', e.msg or '')
    end
  end
  -- Cap from the front so the most recent lines always survive.
  local startAt = math.max(1, #picked - REPORT_MAX_LINES + 1)
  if startAt > 1 then w("(" .. (startAt - 1) .. " older lines omitted)") end
  for i = startAt, #picked do w(picked[i]) end

  return table.concat(out, "\n")
end
M.buildDebugReport = buildDebugReport

local function drawUI()
  if not uiVisible then return end
  local im = ui_imgui
  if not im then return end
  if not ensureUIPointers() then return end
  syncUIPointersFromSnapshot()

  -- The window's close button writes to uiClosePtr[0]; mirror to uiVisible.
  uiClosePtr[0] = true
  im.SetNextWindowSize(im.ImVec2(820, 560), im.Cond_FirstUseEver)
  if not im.Begin("Scratches Debug", uiClosePtr, 0) then
    im.End()
    if not uiClosePtr[0] then uiVisible = false end
    return
  end
  if not uiClosePtr[0] then uiVisible = false end

  -- (1.3) Two-pane layout: scrolling log pane on the left, controls on the
  -- right. The log column is bordered so the split reads clearly.
  local avail = im.GetContentRegionAvail()
  local logW = math.max(300, math.floor((avail.x or 800) * 0.42))
  im.BeginChild1("scratchesLogCol", im.ImVec2(logW, 0), true)
  drawLogPane()
  im.EndChild()
  im.SameLine()
  im.BeginChild1("scratchesCtrlCol", im.ImVec2(0, 0), false)

  -- (1.4) One-click debug report. Top of the column so it's the obvious
  -- action: reproduce a bug, click, paste the clipboard into a report.
  if im.Button("Copy debug report") then
    im.SetClipboardText(buildDebugReport())
    log('I', logTag, "debug report copied to clipboard")
  end
  uiTooltip("Copy a compact, paste-ready report to the clipboard:\n" ..
            "environment + stats + tunables + relevant log lines.\n" ..
            "Reproduce a bug, click this, paste it straight into a report.")

  -- (1.5) Status header — at-a-glance painter health, so one look (or one
  -- screenshot) tells you whether the controls below will actually do
  -- anything. The paint-canvas controls grey out when the painter isn't
  -- ready; everything else degrades safely on its own.
  do
    local veh = getPlayerVehicle(0)
    local jbeam = veh and (veh.JBeam or veh.jbeam)
    if ready then
      im.TextColored(logLevelColor('OK'), "Painter: READY")
    else
      im.TextColored(logLevelColor('E'),
        pendingSetup and "Painter: setting up..." or "Painter: NOT READY")
    end
    im.SameLine()
    if jbeam then
      im.TextColored(logLevelColor('D'), "   vehicle: " .. tostring(jbeam))
    else
      im.TextColored(logLevelColor('W'), "   no player vehicle")
    end
  end
  im.Separator()

  im.Text("--- Presets ---  (one click swaps every slider below)")
  for idx, preset in ipairs(UI_PRESETS) do
    if idx > 1 then im.SameLine() end
    if im.Button(preset.name) then
      applyPreset(preset)
    end
    uiTooltip(preset.desc)
  end

  im.Separator()
  im.Text("--- Live counters ---  (hover any line for details)")

  im.Text(string.format("Collision impacts:    %d",
    lastDetectStats.impactEvents or 0))
  uiTooltip(
    "Hard hits that cleared the impact-force threshold.\n" ..
    "One per qualifying contact, gated by the per-node Cooldown.\n" ..
    "Each fires a discrete stamp (chip/claw brush) at the contact point.")

  im.Text(string.format("Streams baked:        %d",
    stampStats.streamsBaked))
  uiTooltip(
    "Slide events committed as stretched-decal scrape marks.\n" ..
    "Each stream becomes 1-3 elongated decals depending on path curvature.\n" ..
    "Cheap — one bake per stream, regardless of sample count.")

  im.Text(string.format("Discrete stamps:      %d (queued) / %d (skipped)",
    stampStats.stampsEnqueued, stampStats.stampsSkippedMissed))
  uiTooltip(
    "Impact + 1-point-fallback stamps reaching the GE bake queue.\n" ..
    "'Skipped' = projection landed outside the synth-camera frustum at flush\n" ..
    "(the cluster centroid couldn't see that point); the stamp is dropped.\n" ..
    "Skip rate over a few percent suggests tightening Cluster radius.")

  im.Text(string.format("Filtered / total:     %d / %d",
    lastDetectStats.filteredCalls or 0, lastDetectStats.totalCalls or 0))
  uiTooltip(
    "FILTERED = events that passed material/part/threshold gates and reached\n" ..
    "  the impact or slide branches.\n" ..
    "TOTAL = every onNodeCollision call BeamNG fired at us, INCLUDING wheel\n" ..
    "  contacts. A parked car still racks up TOTAL because the wheels are\n" ..
    "  always touching the ground; those are rejected at the wheel check\n" ..
    "  (counted in stats.rejWheel) so FILTERED stays 0.\n" ..
    "Useful as a sanity check that BeamNG is calling us at all.")

  im.Text(string.format("Bake projects/frame:  %.2f  (clusters/frame %.2f)",
    stampStats.framesFlushed > 0 and stampStats.projectsIssued / stampStats.framesFlushed or 0,
    stampStats.framesFlushed > 0 and stampStats.clustersTotal / stampStats.framesFlushed or 0))
  uiTooltip(
    "Average depth-pass renders per baking frame (each is a real GPU cost).\n" ..
    "Every impact cluster and every slide stream is one projection.\n" ..
    "Capped by 'Projections per frame'; the rest wait for the next frame.")

  im.Text(string.format("Job backlog:          %d  (deferred frames %d, dropped %d)",
    #jobQueue, stampStats.framesDeferred, stampStats.jobsDropped))
  uiTooltip(
    "Projection jobs waiting for a later frame. A crash bigger than the\n" ..
    "per-frame budget spreads over a few frames instead of hitching one.\n" ..
    "'dropped' counts jobs refused because the backlog was full.")

  im.Text(string.format("Canvas composites:    %.1f%% of frames",
    stampStats.framesTicked > 0 and 100 * stampStats.combinesRun / stampStats.framesTicked or 0))
  uiTooltip(
    "How often the full 4096x2048 canvas was re-composited onto the car.\n" ..
    "Only frames that baked or cleared, plus a 0.5 s heartbeat, need it —\n" ..
    "near 0% while driving clean, 100% with 'Full-rate composite' on.")

  im.Text(string.format("Max normalForce:      %.0f N",
    lastDetectStats.maxNormalForce or 0))
  uiTooltip(
    "Largest contact force seen this session (newtons).\n" ..
    "Useful to gauge how heavy the heaviest crash was — drives the\n" ..
    "force-scaled camera distance and stamp size for impacts.")

  im.Separator()
  im.Text("--- Scratches (slides) ---")
  if im.SliderFloat("Slip threshold (m/s)", uiPtrs.slip, 0.5, 5.0, "%.2f") then
    sendVehicleCmd(string.format("scratches_detect.setThresholds(%.3f, nil, nil)", uiPtrs.slip[0]))
  end
  uiTooltip(
    "Minimum slipping velocity (m/s) for a node to count as actively scraping.\n" ..
    "LOWER -> lighter brushes register (slow parking-lot drags get marks).\n" ..
    "HIGHER -> only fast slides register; bodywork stays cleaner.\n" ..
    "Default: 0.60 m/s.\n" ..
    "Performance: lower bumps stream count; cheap thanks to stretched decals.")

  if im.SliderFloat("Sample period (s)", uiPtrs.paintCool, 0.001, 0.10, "%.3f") then
    sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)", uiPtrs.paintCool[0]))
  end
  uiTooltip(
    "How often a sliding node contributes a sample to its active stream.\n" ..
    "LOWER -> denser sample chains, longer streams (rich curve detection).\n" ..
    "HIGHER -> chunkier sampling, lighter CPU cost per slide.\n" ..
    "Default: 0.003 s (~333 samples/second per node).\n" ..
    "Performance: every 30 samples force-flushes a stream; lower = more flushes.")

  im.Separator()
  im.Text("--- Impact marks ---")
  if im.SliderFloat("Force threshold (N)", uiPtrs.impForce, 250, 10000, "%.0f") then
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, nil)", uiPtrs.impForce[0]))
  end
  uiTooltip(
    "Minimum normalForce (newtons) for a contact to fire as an IMPACT stamp.\n" ..
    "LOWER -> light bumps register (door dings, curb rubs).\n" ..
    "HIGHER -> only solid hits leave a mark.\n" ..
    "Default: 800 N.\n" ..
    "Performance: every impact joins the per-frame bake; cap=Aggregate cap.")

  if im.SliderFloat("Cooldown (s)", uiPtrs.impCool, 0.005, 1.5, "%.3f") then
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(nil, %.3f)", uiPtrs.impCool[0]))
  end
  uiTooltip(
    "Minimum seconds between impact stamps on the SAME node.\n" ..
    "LOWER -> sustained collisions leave tighter mark sequences.\n" ..
    "HIGHER -> a single mark per period even if hammering continues.\n" ..
    "Default: 0.025 s.\n" ..
    "Performance: lower = potentially many more impact stamps per crash.")

  im.Separator()
  im.Text("--- Bake limits (GE) ---")
  if im.SliderInt("Aggregate cap (per frame)", uiPtrs.aggCap, 4, 192) then
    AGGREGATE_PER_FRAME_CAP = uiPtrs.aggCap[0]
  end
  uiTooltip(
    "Maximum discrete stamps committed in one render frame.\n" ..
    "Excess events drop (counted in 'aggregateDropped').\n" ..
    "LOWER -> harder cap on bake cost; safer on slower GPUs.\n" ..
    "HIGHER -> no drops during spectacular multi-contact frames.\n" ..
    "Default: 96.\n" ..
    "Performance: each frame composites this many layers in one pass.")

  if im.SliderInt("Projections per frame", uiPtrs.projBudget, 1, 24) then
    MAX_PROJECTS_PER_FRAME = math.max(1, uiPtrs.projBudget[0])
  end
  uiTooltip(
    "Depth-pass projections allowed in one frame (impact clusters + slide streams).\n" ..
    "LOWER -> flatter frame times in big crashes; marks trickle in over a few frames.\n" ..
    "HIGHER -> marks land sooner; heavier single-frame spikes.\n" ..
    "Default: 6.")

  if im.Checkbox("Full-rate composite (debug)", uiPtrs.fullRate) then
    M.setFullRateCombine(uiPtrs.fullRate[0])
  end
  uiTooltip(
    "Re-composite the canvas every frame, like the stock API does.\n" ..
    "Leave OFF: compositing only after a bake is the main idle-cost saving.\n" ..
    "Turn ON only to rule the skip out when diagnosing missing marks.")

  if im.SliderFloat("Cluster radius (m)", uiPtrs.clusterRad, 0.3, 4.0, "%.2f") then
    CLUSTER_RADIUS = uiPtrs.clusterRad[0]
  end
  uiTooltip(
    "How tightly stamps must group to share a synth-camera projection.\n" ..
    "SMALLER -> more clusters = more depth-pass renders, but each cam\n" ..
    "  covers a tighter area (more accurate for off-axis stamps).\n" ..
    "LARGER -> fewer projections, but stamps spread wide may clip.\n" ..
    "Default: 0.65 m.\n" ..
    "Performance: avg projects/frame ~= avg clusters/frame.")

  im.Separator()
  im.Text("--- Paint canvas (baseColor seed) ---")
  -- (1.5) Re-baking the seed needs a bound projection. Grey out instead of
  -- letting clicks silently no-op while the painter is still setting up.
  if not ready then
    im.TextDisabled("painter not ready - these controls are inactive")
  end
  im.BeginDisabled(not ready)
  -- Paint-color seed. On by default: the clear/reset wipe (clearBakedTextures)
  -- zeroes the baseColor channel, so the seed must restore the vehicle's paint
  -- color or the body goes black. metallic/roughness aren't seeded — they
  -- render from the factory maps (see restoreFactoryMR).
  if im.Checkbox("Seed paint color", uiPtrs.paintColor) then
    PAINT_SEED_COLOR = uiPtrs.paintColor[0]
    M.clearStamps()
  end
  uiTooltip(
    "Writes the vehicle's chosen paint color into the canvas baseColor.\n" ..
    "Keep this ON: the clear/reset wipe zeroes baseColor, and without the\n" ..
    "color seed the body renders black. Off is debug-only.")
  im.EndDisabled()  -- paint canvas (ready-gated)

  im.Separator()
  if im.Button("Reset stats") then
    M.resetPaintStats()
    sendVehicleCmd("scratches_detect.resetStats()")
  end
  uiTooltip("Zero out all live counters (GE-side and VLUA-side). Stamps already\nbaked into the texture stay; this only clears the displayed numbers.")

  im.SameLine()
  if im.Button("Reset defaults") then
    uiPtrs.slip[0]       = UI_DEFAULTS.slip
    uiPtrs.paintCool[0]  = UI_DEFAULTS.paintCool
    uiPtrs.impForce[0]   = UI_DEFAULTS.impForce
    uiPtrs.impCool[0]    = UI_DEFAULTS.impCool
    uiPtrs.aggCap[0]     = UI_DEFAULTS.aggCap
    uiPtrs.clusterRad[0] = UI_DEFAULTS.clusterRad
    uiPtrs.projBudget[0] = UI_DEFAULTS.projBudget
    uiPtrs.paintColor[0] = UI_DEFAULTS.paintColor
    AGGREGATE_PER_FRAME_CAP = UI_DEFAULTS.aggCap
    CLUSTER_RADIUS          = UI_DEFAULTS.clusterRad
    MAX_PROJECTS_PER_FRAME  = UI_DEFAULTS.projBudget
    PAINT_SEED_COLOR        = UI_DEFAULTS.paintColor
    sendVehicleCmd(string.format("scratches_detect.setThresholds(%.3f, nil, nil)", UI_DEFAULTS.slip))
    sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)", UI_DEFAULTS.paintCool))
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, %.3f)", UI_DEFAULTS.impForce, UI_DEFAULTS.impCool))
    M.clearStamps()  -- re-seed baseColor with the restored defaults
    log('I', logTag, "UI: reset all tunables to defaults")
  end
  uiTooltip("Restore every slider to its canonical default and push the values to VLUA.")

  im.SameLine()
  im.BeginDisabled(not ready)
  if im.Button("Clear stamps") then
    M.clearStamps()
  end
  im.EndDisabled()
  uiTooltip("Wipe every baked decal off the vehicle (keeps the underlying paint color).\n" ..
            "Disabled until the painter is ready. Keyboard equivalent: Ctrl+R.")

  im.SameLine()
  if im.Button("Dump Stats") then
    sendVehicleCmd("scratches_detect.pushFullDumpToGE()")
  end
  uiTooltip("Pull a one-shot full dump from VLUA (rejection reasons, by-material\n" ..
            "breakdown, top nodes by event count) and render it inline below.\n" ..
            "Lets you screenshot the whole state in a single frame.")

  im.SameLine()
  if im.Button("Hide") then
    uiVisible = false
  end
  uiTooltip("Close this window. Reopen via console: scratches_paint.toggleUI()")

  -- (M) Inline full-dump display. The text comes from VLUA via recordFullDump
  -- after the user clicks Dump Stats. Empty until the first click; refreshed
  -- on each subsequent click.
  if lastFullDump ~= "" then
    im.Separator()
    im.TextUnformatted(lastFullDump)
  end

  im.EndChild()  -- scratchesCtrlCol
  im.End()
end
drawUIRef = drawUI

M.dumpDecalConfig = function()
  if not ready then log('W', logTag, "not ready"); return end
  log('I', logTag, "----- decal config -----")
  log('I', logTag, "color path  = " .. tostring(api.getDecalTexturePath and api.getDecalTexturePath("color")))
  log('I', logTag, "alpha path  = " .. tostring(api.getDecalTexturePath and api.getDecalTexturePath("alpha")))
  log('I', logTag, "scale       = " .. tostring(api.getDecalScale and dumps(api.getDecalScale())))
  log('I', logTag, "rotation    = " .. tostring(api.getDecalRotation and api.getDecalRotation()))
  log('I', logTag, "layer count = " .. tostring(api.getLayerCount and api.getLayerCount()))
end

-- Open the imgui debug viewers built into the Dynamic Decals API.
-- Useful to confirm the dynamic textures exist and are being written.
M.drawTextures = function(maxW)
  if not ready then log('W', logTag, "not ready"); return end
  -- These need to be called from within an imgui frame to actually render. Logging
  -- here is just for confirmation that the api responds.
  log('I', logTag, "drawTextures: drawing requires an imgui frame; use the editor's Dynamic Decals tool window for visual inspection")
  log('I', logTag, "or call from console: ui_imgui.Begin('test'); api.drawDynamicTextures(" .. tostring(maxW or 256) .. "); ui_imgui.End()")
end

-- ---- lifecycle ----
local function onExtensionLoaded()
  log('I', logTag, "loaded. probes: scratches_paint.{dumpState,kickSetup,testStamp,testStampAt,testStampAtWorld,probeBrushes,stampAt,stampAtLocal,stampStream,stampBatch,clearStamps,addPaintFill,dumpDecalConfig,drawTextures,setStampVerbose,setAggregateCap,setClusterRadius,setProjectionBudget,setFullRateCombine,dumpPaintStats,resetPaintStats,toggleUI,buildDebugReport}")
  pendingSetup = true
  setupAttemptTimer = SETUP_RETRY  -- try immediately
  trySetup()
end

local function onExtensionUnloaded()
  if groundPaint then pcall(groundPaint.clear) end
  if adapterModule then adapterModule.disableAll() end
  if adapter then adapter:detach(); adapter=nil end
  resetSurfaceState()
  ready = false
  api = nil
  -- The projection was resolved from an upvalue of the api module we are
  -- dropping; holding it past unload would keep a stale handle alive.
  decalProjection = nil
  apiApp = nil
  table.clear(spotHits)
  spawnAabbCache.vid = nil
  spawnAabbCache.box = nil
  pendingStampInputs = {}
  M._dropQueuedJobs()
  lastSkinJBeam = nil
  log('I', logTag, "unloaded")
end

M.onExtensionLoaded   = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onUpdate            = onUpdate
M.onVehicleSwitched   = onVehicleSwitched
M.onVehicleSpawned    = onVehicleSpawned
-- Ground marks belong to the level: gone when it is. A vehicle reset keeps
-- them (the car is repaired, the road is not).
M.onClientEndMission   = function() if groundPaint then pcall(groundPaint.clear) end end
M.onClientStartMission = function() if groundPaint then pcall(groundPaint.clear) end end
M.onSpawnCCallback = function(vid)
  local veh=scenetree.findObjectById(vid)
  if not veh then return end
  if not adapterModule then adapterModule=dofile("/lua/ge/extensions/scratches/bodyAdapter.lua") end
  if not adapterModule.modelSupported(veh.JBeam) then return end
  if not adapterModule.editorActive() then
    adapterModule.invalidateConstructionCache()
    adapterReloaded[vid]=nil
  end
end
M.onJbeamLoadingPhase2 = function(...)
  if not adapterModule then adapterModule = dofile("/lua/ge/extensions/scratches/bodyAdapter.lua") end
  adapterModule.prepare(...)
end
M.onVehicleDestroyed  = function(vid)
  ownedSkins[vid] = nil
  adapterReloaded[vid] = nil
  materialCleanupPending = true -- after destruction, never during mesh teardown
end
-- A reset can rebuild the car's materials; re-bind on the next composite.
M.onVehicleResetted   = function(vid)
  local veh = getPlayerVehicle(0)
  if ready and veh and veh:getId() == vid then rebindDirty = true end
end

return M
