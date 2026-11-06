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
local api               = nil    -- editor_api_dynamicDecals module
local ready             = false  -- decals projection bound, skin set, ready to bake
local pendingSetup      = false  -- want setup but haven't succeeded yet
local setupAttemptTimer = 0      -- seconds since last attempt
local SETUP_RETRY       = 1.0    -- seconds between retry attempts
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
-- Ring buffer of recently picked brushes. pickFromSet() re-rolls once if it lands
-- on a recent pick. Cheap fix for "two identical chip_cluster brushes adjacent".
local recentBrushes    = {}
local RECENT_BRUSH_MAX = 3

-- Style randomness (brush picks, jitter, tones) comes from the painter's own
-- generator (Park-Miller), so a seeded run - tools/bench.py gallery - paints
-- the same marks every time without reseeding the game's shared rand.
local rngState = (os.time() % 2147483646) + 1
local function rand(a, b)
  rngState = (rngState * 16807) % 2147483647
  local u = (rngState - 1) / 2147483646
  if a == nil then return u end
  if b == nil then return math.floor(u * a) + 1 end
  return a + math.floor(u * (b - a + 1))
end
M.seedRandom = function(seed)
  rngState = (math.floor(tonumber(seed) or 1) % 2147483646) + 1
  -- Brush recency steers re-rolls, so a seeded run must start without it.
  table.clear(recentBrushes)
end

-- The current car's paint colour and its luminance (0..1), set when the base
-- fill is seeded. Damage tones are mixed from it: a scuff is the paint a
-- little greyer and lighter, and exposed layers read light on dark paint and
-- darker on light paint.
local paintRGB = { 0.5, 0.5, 0.5 }
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
  projectsIssued      = 0,  -- (F) shared-camera projects/frame; was N
  clustersTotal       = 0,  -- (F) total clusters across flushed frames
  streamsBaked        = 0,
  streamSubstrokesTotal = 0,
  jobsDropped         = 0,  -- projection jobs refused because the backlog was full
  jobsFailed          = 0,  -- projection jobs that threw (logged, then skipped)
  framesDeferred      = 0,  -- frames that hit the projection budget with work left over
  foreignDropped      = 0,  -- batches from a vehicle that isn't the player car
  combinesRun         = 0,  -- composites actually run (light or full)
  rebinds             = 0,  -- of those, full api.onUpdate_ texture-set re-binds
  spotsSkipped        = 0,  -- marks skipped: that spot was already painted enough
  streamsMerged       = 0,  -- slides that shared another slide's projection
  framesTicked        = 0,  -- ready frames seen (combinesRun / framesTicked = combine rate)
  stampsSkippedGap    = 0,  -- impact stamps whose ray overshot the contact by more than GAP.max
  stampsGapDeepened   = 0,  -- impact stamps whose box was laid along the camera axis to reach the contact
  stampsUnmeasured    = 0,  -- impact stamps captured without a reading at their own contact
  reaims              = 0,  -- projections re-aimed from the nearest hull face after a hole reading
  reaimsHelped        = 0,  -- of those, re-aims that found the skin
  marksRetracted      = 0,  -- impact marks taken back because none of their stamps baked
  -- How far impact rays overshot the contact (per stamp position): in front
  -- (visible skin over the node), under 5/10/18/25 cm, and past GAP.max.
  gapFront = 0, gapUnder5 = 0, gapUnder10 = 0, gapUnder18 = 0, gapUnder25 = 0, gapHole = 0,
}
-- The painter's own CPU cost per ready frame, in ms (os.clockhp). Cheap enough
-- to leave on: two clock reads per frame, a few more while there is work. The
-- debug panel's imgui draw is excluded so opening the panel doesn't skew it.
local clockhp = os.clockhp or os.clock
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
  cvcMsTotal = 0, cvcMsMax = 0, cvcProbes = 0, -- car-on-car contact probes
}

-- Add the time since t0 (os.clockhp seconds) to perfStats[totalKey], track
-- the max in perfStats[maxKey] if given, bump perfStats[countKey] if given.
local function perfAdd(t0, totalKey, maxKey, countKey)
  local ms = (clockhp() - t0) * 1000
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
--     combineTextures), which is what keeps a crash from stuttering.
-- fullRateCombine restores the API's every-frame full update for diagnosis.
local combineDirty         = true
local rebindDirty          = true
local fullRateCombine      = false
local sinceCombine         = 0      -- seconds since the last composite
local framesSinceCombine   = 0
local apiApp               = nil    -- the API's private `app` (texture set holder)

-- Projection cost is per FRAME, not per pass: the first projectDynamicDecals
-- in a frame costs ~14 ms (an engine-side sync; physics paused or not), each
-- further one ~1.2 ms. So work is batched: new marks accumulate and are
-- flushed every FLUSH_INTERVAL, running up to MAX_PROJECTS_PER_FRAME passes in
-- that one frame. The first mark after an idle spell flushes immediately.
local FLUSH_INTERVAL       = 0.20   -- seconds between projection batches (tunable)
local sinceFlush           = math.huge

-- Recently painted spots, in a coarse vehicle-local grid. A slide keeps the
-- same body point on the ground and the detector re-sends it every 0.25 s, so
-- a 4.5 s slide used to repaint each contact spot ~18 times: ~1 ms of bake per
-- layer each time, with nothing visible changing after the first couple of
-- passes. Each spot takes a few passes (later ones scrape deeper), then
-- further marks there are skipped until the canvas is cleared.
local SPOT = { cell = 0.08, maxSlide = 2, maxImpact = 2 }  -- cell in m; passes per spot
local spotHits        = {}
-- Peek/commit form, for a mark that only claims its spots once it knows it
-- will paint something (an empty composition must not use up the budget).
local function spotKey(p, kind, cell)
  cell = cell or SPOT.cell
  return kind .. math.floor(p.x / cell) .. ":" .. math.floor(p.y / cell) .. ":" .. math.floor(p.z / cell)
end
local function spotFree(key, maxHits) return (spotHits[key] or 0) < maxHits end
local function spotCommit(key) spotHits[key] = (spotHits[key] or 0) + 1 end

-- Where marks were laid since the last clear: vehicle-local position, outward
-- normal, kind ("i" impact, "s" slide), depth (the deepest look laid, see
-- damageLook), radius (m) and slide direction (car-local unit vector, or 0s),
-- newest last. Tooling reads it to look at the damage (tools/bench.py aims
-- its close-up photos here); the painter reads it to keep a later scuff from
-- repainting a deeper mark (deepMarkNear) and to give neighbouring hits one
-- direction (dirNear).
local MARK_LOG_MAX = 400
local markLog      = {}
local markGen      = 0   -- bumped whenever spots and marks are cleared: older claims are void
local function logMark(p, n, kind, depth, radius, dir)
  if #markLog >= MARK_LOG_MAX then table.remove(markLog, 1) end
  local m = { p.x, p.y, p.z, n.x, n.y, n.z, kind, depth or 0, radius or 0,
              dir and dir.x or 0, dir and dir.y or 0, dir and dir.z or 0 }
  markLog[#markLog + 1] = m
  return m
end

-- True if a mark at least `depth` deep overlaps a footprint of `radius`
-- around p. The canvas blends roughness/metallic by plain lerp, so a later
-- haze would lift an earlier gouge or primer streak back toward "intact".
local function deepMarkNear(p, radius, depth)
  for i = #markLog, 1, -1 do
    local m = markLog[i]
    if m[8] >= depth then
      local dx, dy, dz = m[1] - p.x, m[2] - p.y, m[3] - p.z
      local r = radius + m[9]
      if dx * dx + dy * dy + dz * dz <= r * r then return true end
    end
  end
  return false
end

-- Slide direction of the newest directed mark within `radius` of p, or nil.
-- Neighbouring nodes of one crumpling panel report noisy directions; sharing
-- one keeps their streaks parallel instead of crossing into a star.
local function dirNear(p, radius)
  local r2 = radius * radius
  for i = #markLog, 1, -1 do
    local m = markLog[i]
    if m[10] ~= 0 or m[11] ~= 0 or m[12] ~= 0 then
      local dx, dy, dz = m[1] - p.x, m[2] - p.y, m[3] - p.z
      if dx * dx + dy * dy + dz * dz <= r2 then return vec3(m[10], m[11], m[12]) end
    end
  end
  return nil
end

-- An impact or a slide band claims its spots and logs its mark when it is
-- composed, before projection. Its pending pieces - an impact's stamps, a
-- band's captured layers - carry a handle (`mark`) to that claim and settle it
-- once each: painted when the layer bakes, lost when it is dropped first (a
-- refused or dropped job, a projection miss, a ray through a hole, a failed
-- job or bake). When the last piece settles the claim is reconciled with what
-- reached the canvas: the mark keeps only the depth and size that baked, a
-- piece that never baked frees its own spot, and a claim with nothing baked
-- is taken back whole - so a phantom mark can't block later marks there, bend
-- their direction, or draw the bench's close-ups to bare paint. A cleared
-- canvas has already dropped the claim (`gen`).
local function newClaim(keys)
  return { keys = keys or {}, live = 0, gen = markGen, painted = false, bakedDepth = 0, bakedRadius = 0 }
end
local function claimDone(mk)
  if mk.done or mk.gen ~= markGen then return end
  mk.done = true
  local idx = nil
  for i = #markLog, 1, -1 do
    if markLog[i] == mk.entry then
      idx = i
      break
    end
  end
  if mk.painted then
    if idx then
      markLog[idx][8] = mk.bakedDepth
      if mk.bakedRadius > 0 then markLog[idx][9] = mk.bakedRadius end
    end
    return
  end
  if idx then table.remove(markLog, idx) end
  -- (A full log may have evicted the entry already; the spots are still ours.)
  for _, k in ipairs(mk.keys) do spotHits[k] = math.max(0, (spotHits[k] or 1) - 1) end
  stampStats.marksRetracted = stampStats.marksRetracted + 1
end
local function stampSettled(st, painted)
  local mk = st.mark
  if not mk or st.settled then return end
  st.settled = true
  if mk.gen ~= markGen then return end
  if painted then
    mk.painted = true
    mk.bakedDepth = math.max(mk.bakedDepth, st.look and st.look.depth or 0)
    mk.bakedRadius = math.max(mk.bakedRadius, st.radius or 0)
  elseif st.key then
    spotHits[st.key] = math.max(0, (spotHits[st.key] or 1) - 1)   -- its own cell (a haze, a streak) is free again
  end
  mk.live = mk.live - 1
  if mk.live <= 0 then claimDone(mk) end
end
-- Captured layer -> its stamp, until the layer bakes (kept off the layer
-- table itself, which goes to the engine).
local layerStamp = setmetatable({}, { __mode = "k" })

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
  -- Already swapped this vehicle on an earlier tick — nothing to do. (Also
  -- avoids re-calling setSkin, which respawns the vehicle.)
  if lastSkinJBeam == jbeam then return true end

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
  if prevPart == skinPart then
    -- Our skin is already in the slot (persisted from a prior session).
    log('I', logTag, "dynamicTextures skin already active on " .. jbeam)
    lastSkinJBeam = jbeam
    return true
  end
  if prevPart ~= "" then
    log('W', logTag, "vehicle '" .. jbeam .. "' has livery '" .. tostring(prevPart) ..
      "' in the paint_design slot — SKIPPING to preserve it. No scratches on " ..
      "this car (livery+scratches compositing is a planned future feature).")
    pendingSetup = false  -- intentional, permanent skip for this vehicle
    skippedVid   = vid
    return false
  end

  -- Slot is empty: safe to claim it for the dynamic-decals canvas.
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
-- The damage layer's identity (see setupDamageLayer below): the stage above
-- the canvas paint stage fades on the canvas roughness channel.
local DMG_TEX    = "/art/dynamicDecals/textures/"
local DMG_MARKER = "@DynamicTextureRoughness"

-- Stage index whose baseColor comes from the canvas, or nil.
local function paintStageOf(mat)
  for stage = 0, 3 do
    if mat:getField("baseColorMap", stage) == "@DynamicTextureBaseColor" then return stage end
  end
  return nil
end

local function isDamageLayerDone(mat)
  local p = paintStageOf(mat)
  return p ~= nil and p < 3 and mat:getField("opacityMap", p + 1) == DMG_MARKER
end

-- Re-point one material's canvas metallic/roughness stages at the static
-- factory maps. Returns true if it changed (and was reloaded).
local function staticMR(skinMat)
  local function isDynamic(value)
    return type(value) == "string" and value:sub(1, 15) == "@DynamicTexture"
  end
  local changed = false
  for stage = 0, 3 do
    if isDynamic(skinMat:getField("metallicMap", stage)) then
      skinMat:setField("metallicMap", stage, DMG_TEX .. "_zero.png")
      changed = true
    end
    if isDynamic(skinMat:getField("roughnessMap", stage)) then
      skinMat:setField("roughnessMap", stage, DMG_TEX .. "_paint_roughness.png")
      changed = true
    end
  end
  if changed then
    -- Live-update pattern: setField, then flush() to mark dirty, then
    -- reload() to apply. Both, in that order — reload alone re-reads
    -- the stale state.
    if skinMat.flush  then pcall(function() skinMat:flush()  end) end
    if skinMat.reload then pcall(function() skinMat:reload() end) end
  end
  return changed
end

local function restoreFactoryMR()
  if not api or not api.getShapeMaterialNames then return false end
  if not scenetree or not scenetree.findObject then return false end
  local ok, names = pcall(api.getShapeMaterialNames)
  if not ok or type(names) ~= "table" then return false end

  local restored = 0
  for _, matName in pairs(names) do
    if type(matName) == "string" then
      local skinMat = scenetree.findObject(matName .. ".skin.dynamicTextures")
      -- A damage-layer material keeps metallic on the canvas on purpose.
      if skinMat and not isDamageLayerDone(skinMat) and staticMR(skinMat) then
        restored = restored + 1
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

-- ---- damage layer (gloss loss) ----
-- Real paint damage reads mostly through gloss: abraded clear coat goes
-- satin, primer is matte, scraped metal is satin-shiny. The dynamic-textures
-- skin paints the body in one stage (canvas baseColor under a glossy clear
-- coat), so a mark could only ever be a colour under glass. setupDamageLayer
-- splits that stage in two:
--   stage p    the exposed surface: canvas baseColor, no clear coat, its
--              roughness read from the canvas METALLIC channel, plus tiling
--              micro-scratch detail maps finer than the canvas can resolve.
--   stage p+1  the factory paint, a copy of the original stage with static
--              metallic/roughness maps, drawn over it with
--              opacity = canvas ROUGHNESS (UV1) * paint mask (UV0)
--              (shaders/common/material/shadergen/defaultMat.hlsl processLayers
--              lerps every property, clear coat included, by it).
-- So the canvas roughness channel means "paint intact" and the metallic
-- channel means "roughness of what's exposed". BeamNG binds @DynamicTexture*
-- maps in main map slots (opacityMap, roughnessMap...) but not in detail
-- slots, and both channels clear and fill to 1 (measured with
-- exportTextures): an untouched car is all factory paint, with no seed and no
-- projection seams. A mark writes roughness below 1 where paint came off
-- (0 = fully exposed) and metallic = the exposed surface's roughness. There is
-- no bare-metal metallic: scraped steel reads as a light, smoother grey.
-- Cars whose paint stage has no free stage above it keep the old colour-only
-- behaviour (restoreFactoryMR).
--
-- The skin material is shared and outlives respawns, so setup is idempotent:
-- the factory stage's opacityMap marks a material as done.
local DMG_DETAIL_DIR     = "/art/scratches/"
local DMG_DETAIL_SCALE   = "96 48" -- micro-scratch tiles across the 2:1 canvas UV (~43 canvas texels a tile)
-- Every per-stage material field (editor/materialEditor.lua's layer list),
-- copied verbatim so the pristine stage renders exactly like the original.
local STAGE_FIELDS = {
  "diffuseColor", "instanceDiffuse", "instanceEmissive", "instanceOpacity", "diffuseMap", "paletteBaseColor",
  "paletteMetallic", "paletteRoughness", "paletteClearCoat", "paletteClearCoatRoughness", "diffuseMapUseUV",
  "overlayMapUseUV", "detailMapUseUV", "normalMapUseUV", "normalDetailMapUseUV", "opacityMapUseUV",
  "colorPaletteMapUseUV", "specularMapUseUV", "reflectivityMapUseUV", "roughnessMapUseUV", "metallicMapUseUV",
  "clearCoatMapUseUV", "ambientOcclusionMapUseUV", "emissiveMapUseUV", "colorMap", "normalMap",
  "normalMapStrength", "detailBaseColorMapStrength", "roughnessFactor", "specularPower", "baseColorMap",
  "baseColorFactor", "opacityFactor", "metallicMap", "metallicFactor", "metallicDetailMap",
  "detailMetallicMapStrength", "roughnessMap", "roughnessDetailMap", "detailRoughnessMapStrength",
  "ambientOcclusionMap", "ambientOcclusionDetailMap", "detailAoMapStrength", "emissiveFactor",
  "emissiveIntensityNits", "emissiveIgnoreExposure", "emissiveMap", "retroreflectivity", "retroreflectiveColor",
  "clearCoatMap", "clearCoatFactor", "clearCoatRoughnessFactor", "clearCoatBottomNormalMap",
  "clearCoatBottomNormalMapStrength", "specularityMap", "clearCoatRoughnessMap", "overlayMap", "opacityMap",
  "opacityDetailMap", "detailOpacityMapStrength", "opacityDetailMapUseUV", "colorPaletteMap", "lightMap",
  "detailMap", "detailScale", "detailNormalMap", "detailNormalMapStrength", "specularMap", "envMap",
  "reflectivityMap", "reflectivityMapFactor", "specular", "pixelSpecular", "annotationMap", "parallaxScale",
  "useAnisotropic", "useAnisotropicFilter", "vertLit", "vertColor", "vertColorEmissive", "minnaertConstant",
  "subSurface",
}

-- Original fields of every material we split, by material name, so unloading
-- the painter can put the car's skin back exactly as it was.
local dmgOriginals = {}

-- Detail slots the split would clobber: the exposed stage takes its own detail
-- maps and the factory stage's detailScale becomes 1 1 for the paint mask.
local DETAIL_FIELDS = { "detailMap", "detailNormalMap", "roughnessDetailMap", "metallicDetailMap",
                        "ambientOcclusionDetailMap", "opacityDetailMap" }

local function snapshotStages(mat, p)
  local snap = { active = mat:getField("activeLayers", 0), stages = {} }
  for _, st in ipairs({ p, p + 1 }) do
    local t = {}
    for _, f in ipairs(STAGE_FIELDS) do t[f] = mat:getField(f, st) end
    snap.stages[st] = t
  end
  return snap
end

local function applyMaterial(mat)
  local ok1 = not mat.flush or pcall(function() mat:flush() end)
  local ok2 = not mat.reload or pcall(function() mat:reload() end)
  return ok1 and ok2
end

local function restoreStages(mat, snap)
  for st, t in pairs(snap.stages) do
    for f, v in pairs(t) do mat:setField(f, st, v) end
  end
  mat:setField("activeLayers", 0, snap.active)
  applyMaterial(mat)
end

-- Returns true if `mat` now has (or already had) the damage layer. Layouts it
-- can't split without losing something (paint stage not on top, or already
-- using detail maps) are left alone, as is a material whose split didn't
-- stick - the caller falls back to colour-only marks.
local function setupMaterialDamageLayer(mat, name)
  if isDamageLayerDone(mat) then return true end
  local p = paintStageOf(mat)
  if not p then return false end
  local active = tonumber(mat:getField("activeLayers", 0)) or 1
  if p + 1 > 3 or active ~= p + 1 then return false end
  for _, f in ipairs(DETAIL_FIELDS) do
    if mat:getField(f, p) ~= "" then return false end
  end
  local snap = snapshotStages(mat, p)

  local function set(f, st, v) mat:setField(f, st, tostring(v)) end
  for _, f in ipairs(STAGE_FIELDS) do set(f, p + 1, mat:getField(f, p)) end

  -- p+1: factory paint over the damage, faded out where the canvas says so.
  -- The original paint mask (which keeps paint off trim) moves to the opacity
  -- detail slot, with full strength so it multiplies: saturate(2 * mask).
  local mask, maskUV = mat:getField("opacityMap", p), mat:getField("opacityMapUseUV", p)
  set("metallicMap", p + 1, DMG_TEX .. "_zero.png")
  set("roughnessMap", p + 1, DMG_TEX .. "_paint_roughness.png")
  set("opacityMap", p + 1, DMG_MARKER)
  set("opacityMapUseUV", p + 1, 1)
  set("opacityDetailMap", p + 1, mask)
  set("opacityDetailMapUseUV", p + 1, maskUV ~= "" and maskUV or 0)
  set("detailOpacityMapStrength", p + 1, 1)
  set("detailScale", p + 1, "1 1")

  -- p: the exposed surface. Roughness comes from the canvas metallic channel.
  set("metallicMap", p, DMG_TEX .. "_zero.png")
  set("metallicFactor", p, 0)
  set("roughnessMap", p, "@DynamicTextureMetallic")
  set("roughnessMapUseUV", p, 1)
  set("roughnessFactor", p, 1)
  set("clearCoatFactor", p, 0)
  set("clearCoatMap", p, "")
  -- Micro-scratches, tiled on the canvas UV: faintly lighter fine lines,
  -- rougher grooves, and relief that catches the light.
  set("detailMap", p, DMG_DETAIL_DIR .. "scratch_detail_b.data.png")
  set("detailBaseColorMapStrength", p, 0.03)
  set("roughnessDetailMap", p, DMG_DETAIL_DIR .. "scratch_detail_r.data.png")
  set("detailRoughnessMapStrength", p, 0.15)
  set("detailNormalMap", p, DMG_DETAIL_DIR .. "scratch_detail_n.normal.png")
  set("detailNormalMapStrength", p, 0.12)
  set("detailMapUseUV", p, 1)
  set("normalDetailMapUseUV", p, 1)
  set("detailScale", p, DMG_DETAIL_SCALE)

  set("activeLayers", 0, p + 2)
  if not (applyMaterial(mat) and isDamageLayerDone(mat)
          and mat:getField("roughnessMap", p) == "@DynamicTextureMetallic"
          and tonumber(mat:getField("activeLayers", 0)) == p + 2) then
    log('W', logTag, "damage layer didn't apply to " .. tostring(name) .. "; restoring it (colour-only marks)")
    restoreStages(mat, snap)
    return false
  end
  dmgOriginals[name] = snap
  return true
end

-- Un-split every material (painter unload) and leave it in the safe
-- colour-only state: the shipped stage reads canvas metallic/roughness, which
-- sit at 1 (a matte-metal body), so restoreFactoryMR re-points them at static
-- factory values whether or not the canvas stays bound.
local function restoreDamageLayers()
  if not (scenetree and scenetree.findObject) then return end
  for name, snap in pairs(dmgOriginals) do
    local mat = scenetree.findObject(name)
    -- Every restored material, whichever car it belongs to.
    if mat then restoreStages(mat, snap); staticMR(mat) end
  end
  table.clear(dmgOriginals)
end

-- Give the factory-paint stage of the current car's split materials its own
-- paint finish (metallic flake, base roughness) instead of the flat
-- dielectric the static maps give it. Cached so a later re-split (respawn,
-- reset) gets it too.
local lastFinish = nil
local function applyPaintFinish(metallic, roughness)
  metallic = math.max(0, math.min(1, metallic))
  roughness = math.max(0.05, math.min(1, roughness))
  lastFinish = { metallic, roughness }
  if not (scenetree and scenetree.findObject and api and api.getShapeMaterialNames) then return end
  local ok, names = pcall(api.getShapeMaterialNames)
  if not ok or type(names) ~= "table" then return end
  -- Fields read back as float text ("0.850000024"), so compare as numbers.
  local function differs(mat, f, st, v) return math.abs((tonumber(mat:getField(f, st)) or -1) - v) > 1e-4 end
  for _, matName in pairs(names) do
    local mat = type(matName) == "string" and scenetree.findObject(matName .. ".skin.dynamicTextures")
    local p = mat and isDamageLayerDone(mat) and paintStageOf(mat)
    if p and p < 3 and (differs(mat, "metallicFactor", p + 1, metallic) or differs(mat, "roughnessFactor", p + 1, roughness)
                        or mat:getField("metallicMap", p + 1) ~= "") then
      mat:setField("metallicMap", p + 1, "")
      mat:setField("metallicFactor", p + 1, tostring(metallic))
      mat:setField("roughnessMap", p + 1, "")
      mat:setField("roughnessFactor", p + 1, tostring(roughness))
      applyMaterial(mat)
    end
  end
end

-- Give every body material the damage layer; fall back to restoreFactoryMR's
-- static maps for materials that can't take one. Cheap when already done.
local function setupDamageLayer()
  if not api or not api.getShapeMaterialNames then return false end
  if not scenetree or not scenetree.findObject then return false end
  local ok, names = pcall(api.getShapeMaterialNames)
  if not ok or type(names) ~= "table" then return false end
  local added, fallback = 0, 0
  for _, matName in pairs(names) do
    if type(matName) == "string" then
      local mat = scenetree.findObject(matName .. ".skin.dynamicTextures")
      if mat then
        local wasDone = isDamageLayerDone(mat)
        if setupMaterialDamageLayer(mat, matName .. ".skin.dynamicTextures") then
          if not wasDone then added = added + 1 end
        else
          fallback = fallback + 1
        end
      end
    end
  end
  if fallback > 0 then restoreFactoryMR() end
  -- A fresh split starts from the static maps; give it the paint finish back.
  if added > 0 and lastFinish then applyPaintFinish(lastFinish[1], lastFinish[2]) end
  if added > 0 or fallback > 0 then
    log('I', logTag, string.format("damage layer: %d material(s) set up, %d without a free stage (colour only)",
      added, fallback))
  end
  return true
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
      setupDamageLayer()
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
      setupDamageLayer()
      M.addPaintFill()
      seedDone = true
    end
  end
end

local function trySetup()
  if ready then return true end
  if not ensureApiLoaded() then return false end

  local veh = getPlayerVehicle(0)
  if not veh then return false end
  local jbeam = veh.JBeam or veh.jbeam
  if not jbeam then return false end
  local vid = veh:getId()
  if vid == skippedVid then pendingSetup = false; return false end

  if not ensureSkin(jbeam, vid) then
    -- ensureSkin distinguishes transient from permanent failures internally and
    -- clears pendingSetup itself if the vehicle is unsupported. Just bail.
    return false
  end

  -- (K) Make sure ui_imgui is loaded so the debug panel can render the
  -- first time M.toggleUI is called. Idempotent.
  if not ui_imgui then extensions.load("ui_imgui") end

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
  -- The car-on-car probe needs this car's body-node list; after a painter
  -- reload the detector won't send it again on its own.
  veh:queueLuaCommand("if scratches_detect and scratches_detect.resendBodyNodes then scratches_detect.resendBodyNodes() end")
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
-- Also returns the paint's metallic and roughness (fields 5 and 6 of the
-- "r g b a metallic roughness clearcoat clearcoatRoughness" string) when
-- present, else nil for both.
local function parseVehicleColor(s)
  if type(s) ~= "string" or s == "" then return nil end
  local nums = {}
  for v in s:gmatch("[%-%d%.]+") do nums[#nums + 1] = tonumber(v) end
  local r, g, b = nums[1], nums[2], nums[3]
  if not (r and g and b) then return nil end
  return r, g, b, nums[5], nums[6]
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
  local pr, pg, pb, pm, pro = parseVehicleColor(getVehicleColor and getVehicleColor() or nil)
  if pr then
    r, g, b = pr, pg, pb
    paintRGB = { r, g, b }
    paintLum = math.max(0, math.min(1, 0.2126 * r + 0.7152 * g + 0.0722 * b))
    if pm and pro then applyPaintFinish(pm, pro) end
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
local flushPendingStampsRef
local bakePendingRef
local updateCarContactsRef
local resetCarContactsRef
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

local function onUpdate(dtReal, dtSim, dtRaw)
  if ready then
    local t0 = clockhp()
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
    local projected = false
    if hasPendingWorkRef and hasPendingWorkRef() and sinceFlush >= FLUSH_INTERVAL then
      sinceFlush = 0
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
    -- Contacts with other cars are found geometrically (see updateCarContacts).
    if updateCarContactsRef then
      local veh = getPlayerVehicle(0)
      if veh then updateCarContactsRef(dtReal or 0, veh) end
    end
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
  table.clear(markLog)
  markGen = markGen + 1
  if resetCarContactsRef then resetCarContactsRef() end
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
  -- The API has its own onVehicleSwitched that refreshes the projection shape;
  -- forward it.
  if api and api.onVehicleSwitched then api.onVehicleSwitched() end
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
    spawnAabbCache.vid = nil
    spawnAabbCache.box = nil
    if ready then
      combineDirty = true; rebindDirty = true
      -- A respawn (paint or part change) can rebuild the skin material from
      -- its JSON, which would leave the canvas channels read the vanilla way.
      setupDamageLayer()
      -- ...and may have changed the paint the damage tones are mixed from.
      local pr, pg, pb, pm, pro = parseVehicleColor(getVehicleColor and getVehicleColor() or nil)
      if pr then
        paintRGB = { pr, pg, pb }
        paintLum = math.max(0, math.min(1, 0.2126 * pr + 0.7152 * pg + 0.0722 * pb))
        if pm and pro then applyPaintFinish(pm, pro) end
      end
    end
  end
  if not ready then
    pendingSetup = true
    setupAttemptTimer = SETUP_RETRY  -- attempt immediately
  end
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
--   STREAK - a scrape band of primer streaks; stretched along the slide.
--   HAZE   - abraded clear coat: a ragged patch of streaky abrasion.
--   CHIPS  - sharp-edged flakes scattered downstream of a hit.
--   GOUGES - a torn gouge as a pair: the paint rim and the bare core inside it.
--   SMEAR  - transfer: a broken, streaky smudge.
local TEX = "/art/dynamicDecals/textures/"
local STREAK_BRUSHES = { TEX .. "scr_streak_01.png", TEX .. "scr_streak_02.png", TEX .. "scr_streak_03.png",
                         TEX .. "scr_streak_04.png" }
local HAZE_BRUSHES   = { TEX .. "scr_haze_01.png", TEX .. "scr_haze_02.png", TEX .. "scr_haze_03.png" }
local CHIP_BRUSHES   = { TEX .. "scr_chips_01.png", TEX .. "scr_chips_02.png" }
local GOUGES         = { { rim = TEX .. "scr_gouge_01_rim.png", core = TEX .. "scr_gouge_01_core.png" },
                         { rim = TEX .. "scr_gouge_02_rim.png", core = TEX .. "scr_gouge_02_core.png" } }
local SMEAR_BRUSHES  = { TEX .. "scr_smear_01.png", TEX .. "scr_smear_02.png" }
-- An impact's streaks: a short cluster ending inside an oval (a band's
-- streak brush, stamped that small, showed its box).
local DRAG_BRUSHES   = { TEX .. "scr_drag_01.png", TEX .. "scr_drag_02.png", TEX .. "scr_drag_03.png" }

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
local STREAM_MERGE = { radius = 0.35, maxBands = 6 }  -- radius: m between band centres

-- Recency-aware random picker. Avoids the last RECENT_BRUSH_MAX picks if
-- possible. One re-roll max so small brush sets don't loop.
local function pickFromSet(set)
  local b = set[rand(#set)]
  for _, r in ipairs(recentBrushes) do
    if r == b then
      b = set[rand(#set)]
      break
    end
  end
  recentBrushes[#recentBrushes + 1] = b
  if #recentBrushes > RECENT_BRUSH_MAX then table.remove(recentBrushes, 1) end
  return b
end

-- ---- damage looks ----
-- A look is everything one decal layer writes: brush, colour, alpha, and the
-- two damage-layer channels (see setupDamageLayer):
--   intact  how much factory paint survives (canvas roughness): 0 = fully
--           exposed, 1 = untouched. A brush's alpha scales it, so exposure
--           follows the brush shape.
--   rough   roughness of what's exposed (canvas metallic).
-- Colours are mixed from the paint colour, so the alpha that drives the gloss
-- loss doesn't also decide how strong the colour change is.
--   kind: "haze" | "scuff" | "primer" | "metal" | "plastic" | "transfer"
local function mix3(a, b, t)
  return a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t, a[3] + (b[3] - a[3]) * t
end

-- How deep each look cuts, for bake order: shallower layers bake first so a
-- deeper one is never painted back over (the canvas blends by lerp).
local LOOK_DEPTH = { haze = 0, abrasion = 0, transfer = 1, scuff = 2, primer = 3, plastic = 4, metal = 5 }

local function damageLook(kind, tex)
  local light = math.max(0, math.min(1, (paintLum - 0.3) / 0.35))  -- 0 dark paint .. 1 light paint
  local j = (rand() - 0.5) * 0.06
  local r, g, b, intact, rough = 0, 0, 0, 0, 0.75
  if kind == "haze" then
    -- Abraded clear coat is full of micro-fractures that scatter white light:
    -- dark paint greys a little (losing its reflection alone would only
    -- darken it; much more reads as grey clouds); light paint goes dull and a
    -- touch lighter (ref photo 3) - darkening it read as a grey stain. Partly
    -- intact.
    local grey = 0.2126 * paintRGB[1] + 0.7152 * paintRGB[2] + 0.0722 * paintRGB[3]
    local lift = math.min(1, grey * 1.04 + 0.05)
    local target = light < 0.5 and { 0.5, 0.52, 0.55 } or { lift, lift, lift * 1.01 }
    r, g, b = mix3(paintRGB, target, (light < 0.5 and 0.2 or 0.3) + 0.08 * rand())
    intact, rough = 0.45, 0.65
  elseif kind == "abrasion" then
    -- Clear coat rubbed off by a panel sliding over concrete (ref photo 1):
    -- whiter and more matte than a pressed haze - the scuffed area itself
    -- reads, not only its scores.
    local grey = 0.2126 * paintRGB[1] + 0.7152 * paintRGB[2] + 0.0722 * paintRGB[3]
    local lift = math.min(1, grey * 1.06 + 0.07)
    local target = light < 0.5 and { 0.62, 0.64, 0.68 } or { lift, lift, lift * 1.01 }
    r, g, b = mix3(paintRGB, target, 0.34 + 0.08 * rand())
    intact, rough = 0.3, 0.65
  elseif kind == "scuff" then
    -- Light scores through the clear coat into the colour coat: a whitened
    -- paint tone, not primer yet.
    -- (On light paint, a neutral darker grey: tinted by the paint it read
    -- dark blue on silver.)
    local lum = 0.2126 * paintRGB[1] + 0.7152 * paintRGB[2] + 0.0722 * paintRGB[3]
    local target = light < 0.5 and { 0.68, 0.69, 0.71 } or { lum * 0.62, lum * 0.62, lum * 0.62 }
    r, g, b = mix3(paintRGB, target, 0.55 + 0.15 * rand())
    intact, rough = 0.1, 0.6
  elseif kind == "metal" then
    -- Bare steel: no metallic flake here (the canvas metallic channel holds
    -- roughness), so a darker, glossy grey stands in for its reflection - a
    -- light one merged with the primer rim around it into one white blob.
    local v = 0.40 + j
    r, g, b = v - 0.01, v, v + 0.015
    rough = 0.45
  elseif kind == "plastic" then
    -- Bumper plastic under the paint: dark grey.
    local v = 0.13 + j * 0.5
    r, g, b = v, v, v + 0.005
    rough = 0.6
  elseif kind == "chip" then
    -- Primer in small flakes (primer depth): a flake reads whiter than a
    -- streak of the same primer, so on dark paint it's a duller, neutral grey.
    local v = (light < 0.5 and 0.6 or 0.5) + j
    r, g, b = v, v, v
  elseif kind == "transfer" then
    -- Rubber/grime pressed into the paint: dark, not quite black.
    local v = 0.08 + j * 0.5
    r, g, b = v, v, v
    intact, rough = 0.5, 0.7
  else
    -- Primer: off-white and faintly warm on dark cars; mid grey on light cars,
    -- where it shows up darker than the paint around it.
    local v = (light < 0.5 and 0.72 or 0.5) + j
    r, g, b = v + 0.012, v, v - 0.02
  end
  return { tex = tex, r = math.max(0, math.min(1, r)), g = math.max(0, math.min(1, g)),
           b = math.max(0, math.min(1, b)), a = 1, intact = intact, rough = rough,
           depth = LOOK_DEPTH[kind] or LOOK_DEPTH.primer }
end

-- Another car's paint smeared on (car-on-car contact): its colour, laid on
-- top of the scuff, still fairly glossy since it is paint on paint.
local function transferLook(rgb, tex)
  local look = damageLook("transfer", tex)
  look.r, look.g, look.b = rgb[1], rgb[2], rgb[3]
  look.intact, look.rough = 0.6, 0.5
  return look
end

-- A decal is a box: the brush maps onto its x/z faces and it paints every
-- surface inside its y (depth) extent (shaders/common/dynamicDecals/
-- decal.ps.hlsl). At the old 1 m depth a mark also smeared down any surface
-- near-parallel to the projection within half a metre - a crumpled lower door,
-- a sill, a pillar - as long streaks. Depth follows the mark's size: deep
-- enough for a curved bumper corner, too shallow to reach a folded panel.
-- Impacts land on crumpled metal, whose skin leaves a thin slab within
-- centimetres of the hit point, so they get a deeper box (`deep`), and
-- runClusterJob deepens it further where the ray overshot the contact.
-- Measured overshoots on crushed panels are 5-18 cm; past this the ray went
-- through a hole (one measured 2.76 m), and a box deep enough to reach back
-- would smear down nearby surfaces (see decalDepth).
local GAP = { max = 0.25, noise = 0.02, borrow = 0.15 }  -- m
-- Re-aimed projections allowed per flush (each is one more ~1.4 ms pass on
-- top of the projection budget).
local reaim = { perFlush = 3, left = 3 }
-- GAP.noise: a smaller overshoot is a node a little off the skin.
-- GAP.borrow: another stamp borrows the aim's compensation only this close to
-- it (the same crushed patch); further off, a deep box on intact skin would
-- smear.
local function decalDepth(lenFull, widthFull, deep)
  local size = math.max(lenFull, widthFull)
  if deep then return math.max(0.25, math.min(0.5, 1.2 * size)) end
  return math.max(0.08, math.min(0.3, 0.4 * size))
end

-- Point the decal API's brush state at a look; getDecalData then snapshots it
-- into the layer it builds.
local function applyLook(look)
  api.setDecalTexturePath("color", look.tex)
  api.setDecalTexturePath("alpha", TEX .. "_one.png")
  api.setDecalTexturePath("metallic", TEX .. "_one.png")
  api.setDecalTexturePath("roughness", TEX .. "_one.png")
  -- The damage layer reads canvas roughness as "paint intact" and canvas
  -- metallic as "roughness of what's exposed".
  api.setRoughnessIntensity(look.intact or 1)
  api.setMetallicIntensity(look.rough or 1)
  api.setDecalColor(Point4F(look.r, look.g, look.b, look.a or 1))
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

-- ---- projection job queue ----
-- Every visible mark is produced by a "job": ONE synthetic-camera projection
-- pass plus one or more layers captured under that camera. Discrete stamps
-- become one job per spatial cluster (clustered once per frame); every slide
-- stream is one job. onUpdate drains the queue under a per-frame projection
-- budget and every layer produced in a frame goes into ONE bakeLayers call,
-- so a big crash is spread across a few frames instead of landing as a single
-- long hitch. Positions are vehicle-local, so a job deferred a frame or two
-- still lands on the right panel.
local jobQueue               = {}
-- Captured decal layers waiting to be baked. Baking costs ~0.85 ms per layer
-- and has no per-frame toll of its own, so it runs on the frames between
-- projection batches, BAKE_LAYERS_PER_FRAME at a time, instead of piling onto
-- the projection frame. Layers are car-local, so a short delay is harmless.
local bakeQueue              = {}
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

-- Settle what a job still owes as lost: it won't run.
local function dropJob(job)
  if job.stream then
    for _, b in ipairs(job.bands) do
      if b.claim and b.claim.live == 0 then claimDone(b.claim) end
    end
  else
    for _, st in ipairs(job.members) do stampSettled(st) end
  end
end
local function dropJobs(list)
  for _, job in ipairs(list) do dropJob(job) end
  table.clear(list)
end

local function enqueueJob(job, vid)
  if jobQueueVid ~= vid then
    dropJobs(jobQueue)
    jobQueueVid = vid
  end
  if #jobQueue >= MAX_QUEUED_JOBS then
    stampStats.jobsDropped = stampStats.jobsDropped + 1
    return false
  end
  jobQueue[#jobQueue + 1] = job
  return true
end

local function hasPendingWork()
  return #pendingStampInputs > 0 or #jobQueue > 0
end
hasPendingWorkRef = hasPendingWork

-- Drop every queued projection job (vehicle switch, clear).
M._dropQueuedJobs = function()
  dropJobs(jobQueue)
  for _, l in ipairs(bakeQueue) do
    local st = layerStamp[l]
    if st then stampSettled(st) end
  end
  table.clear(bakeQueue)
  jobQueueVid = nil
end

-- Stamps the per-flush aggregate can still take for this vehicle.
local function stampRoom(vid)
  if pendingStampsVid ~= vid then return AGGREGATE_PER_FRAME_CAP end
  return AGGREGATE_PER_FRAME_CAP - #pendingStampInputs
end

-- Record one discrete stamp for vehicle `vid` (vehicle-local inputs). No api
-- calls, no projection: flushPendingStamps clusters the frame's stamps into
-- jobs. Callers have already checked readiness. Returns whether it was taken.
local function enqueueStamp(localPos, localNormal, opts, vid)
  opts = opts or {}

  -- Apply small positional jitter so repeated events at the same node don't
  -- perfectly stack into a single point. Body nodes have fixed body-relative
  -- positions, so without jitter a 1-second drag against a wall produces N
  -- stamps at exactly the same point; with jitter they spread into a small
  -- cluster that reads as scratch coverage.
  if not opts.noJitter then
    local jitter = 0.03  -- ±3 cm
    localPos = vec3(
      localPos.x + (rand() - 0.5) * 2 * jitter,
      localPos.y + (rand() - 0.5) * 2 * jitter,
      localPos.z + (rand() - 0.5) * 2 * jitter)
  end

  -- Per-stamp style. No api state is set here - the job replays the look on
  -- each stamp's getDecalData call. opts.look wins; plain opts.r/g/b (console
  -- probes) become a colour-only look; otherwise a primer streak.
  local look = opts.look
  if not look and opts.kind then look = damageLook(opts.kind, opts.colorTex or pickFromSet(HAZE_BRUSHES)) end
  if not look and (opts.r or opts.g or opts.b) then
    look = { tex = opts.colorTex or STREAK_BRUSHES[1], r = opts.r or 0.7, g = opts.g or 0.7, b = opts.b or 0.7,
             a = opts.a or 1, intact = 1, rough = 1 }
  end
  look = look or damageLook("primer", opts.colorTex or pickFromSet(STREAK_BRUSHES))
  local baseScale = opts.scale or 0.10
  local scale     = opts.noJitter and baseScale or baseScale * (0.8 + rand() * 0.4)
  -- setDecalRotation takes radians (editor/api/dynamicDecals.lua setDecalRotation).
  local rot       = opts.rot or rand() * 2 * math.pi

  stampStats.stampsAttempted = stampStats.stampsAttempted + 1

  if pendingStampsVid ~= vid then
    for _, st in ipairs(pendingStampInputs) do stampSettled(st) end
    pendingStampInputs = {}
    pendingStampsVid = vid
  end

  if #pendingStampInputs >= AGGREGATE_PER_FRAME_CAP then
    stampStats.aggregateDropped = stampStats.aggregateDropped + 1
    return false
  end

  pendingStampInputs[#pendingStampInputs + 1] = {
    localPos    = localPos,
    localNormal = localNormal,
    look        = look,
    scale       = scale,
    scaleY      = opts.scaleY and scale * opts.scaleY / baseScale or nil,
    rot         = rot,
    dir         = opts.dir,
    dist        = opts.dist,
    mark        = opts.mark,
    contact     = opts.contact,   -- the unjittered contact point (impacts)
    key         = opts.key,       -- its own spot (released if it never bakes)
    radius      = opts.radius,    -- its footprint, for the mark it bakes into
  }
  if opts.mark then opts.mark.live = opts.mark.live + 1 end
  stampStats.stampsEnqueued = stampStats.stampsEnqueued + 1
  return true
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
-- Stamps share a projection only if they want the same camera: the hull
-- face chooseHullOutward picks for each (one axis can't serve a front face
-- and a side face - at a corner the side one grazed past the front; and two
-- contacts 10 deg apart either side of 45 deg want different axes).
local function buildClusters(inputs)
  local clusters = {}
  for i = 1, #inputs do
    local s = inputs[i]
    local face = chooseHullOutward(s.localPos, s.localNormal)
    local placed = false
    for j = 1, #clusters do
      local c = clusters[j]
      local dx = s.localPos.x - c.cx
      local dy = s.localPos.y - c.cy
      local dz = s.localPos.z - c.cz
      if face:dot(c.face) > 0.99 and (dx*dx + dy*dy + dz*dz) < (CLUSTER_RADIUS * CLUSTER_RADIUS) then
        local k = #c.members
        c.cx = (c.cx * k + s.localPos.x) / (k + 1)
        c.cy = (c.cy * k + s.localPos.y) / (k + 1)
        c.cz = (c.cz * k + s.localPos.z) / (k + 1)
        c.members[k + 1] = s
        placed = true
        break
      end
    end
    if not placed then
      clusters[#clusters + 1] = {
        cx = s.localPos.x, cy = s.localPos.y, cz = s.localPos.z,
        face = face,
        members = {s},
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
-- guard: {noHaze, noLine} - skip the band's haze / streak lines because a
-- deeper earlier mark lies under it (see deepMarkNear). claim: the band's
-- claim (newClaim), settled by its layers. Returns whether the band was
-- admitted (a full queue drops it).
local function enqueueStreamLocal(localPos, localNormals, vid, severity, mat, transfer, guard, claim)
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
  if #segments == 0 then return false end

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
  local band     = { segments = segments, severity = severity, mat = mat, transfer = transfer,
                     noHaze = guard and guard.noHaze, noLine = guard and guard.noLine, claim = claim }
  -- Share a queued job's projection if it's close by on a panel facing the
  -- same way (each projecting frame costs a ~14 ms toll; see FLUSH_INTERVAL).
  if jobQueueVid == vid then
    for i = #jobQueue, 1, -1 do
      local j = jobQueue[i]
      if j.stream and #j.bands < STREAM_MERGE.maxBands
         and distLocal(j.centroid, centroid) <= STREAM_MERGE.radius
         and j.normal:dot(normal) >= 0.8 then
        local k = #j.bands
        j.bands[k + 1] = band
        for _, sg in ipairs(segments) do j.segments[#j.segments + 1] = sg end
        j.centroid = (j.centroid * k + centroid) * (1 / (k + 1))
        stampStats.streamsMerged = stampStats.streamsMerged + 1
        return true
      end
    end
  end
  -- The job's segment list grows as nearby slides merge in; it must be its
  -- own table, or merged segments land in the first band too (which then drew
  -- streaks across every merged contact, angled from one to another).
  local all = {}
  for i = 1, #segments do all[i] = segments[i] end
  return enqueueJob({
    stream   = true,
    bands    = { band },
    segments = all,          -- all bands' segments, for layer budgeting
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
                                             math.max(0.5, math.min(1.6, (extent + 0.05) * 2.2)))
  setScratchProjectionFence(true)
  local tp = clockhp()
  decalProjection:projectDynamicDecals(camLocal, projM)
  perfAdd(tp, "projectMsTotal", "projectMsMax", "projectCalls")

  -- Helper layer used only to compute screen-UV for start/end points (cheap;
  -- we mutate cursor and read it back without baking). Does NOT enter the
  -- bake list — we get a fresh styled layer per segment below.
  local probe = decalProjection:getDecalData(camLocal, projM)
  if not (probe and probe.cursorPosScreenUv) then
    setScratchProjectionFence(false)
    log('W', logTag, "stream job: getDecalData returned nil")
    dropJob(job)
    return
  end

  local function addLayer(look, center, halfLen, halfWidth, angle, name, claim)
    applyLook(look)
    -- Asymmetric scale: long along travel, thin across. setDecalScale takes
    -- the full extent in metres (measured: scale 0.3 paints a ~30 cm brush).
    api.setDecalScale(vec3(2 * halfLen, decalDepth(2 * halfLen, 2 * halfWidth), 2 * halfWidth))
    api.setDecalRotation(angle)
    api.setUseSurfaceNormal(true)
    local tl = clockhp()
    local layer = decalProjection:getDecalData(camLocal, projM)
    if layer then api.setDecalLocalPos(layer, center) end
    perfAdd(tl, "layerMsTotal", nil, "layerCalls")
    if not layer then return end
    -- Frustum sanity (out-of-frustum stamps wouldn't paint correctly).
    local cuv = layer.cursorPosScreenUv
    if cuv and cuv.x >= 0 and cuv.x <= 1 and cuv.y >= 0 and cuv.y <= 1 then
      layer.uid       = nextLayerUid()
      layer.name      = name
      layer.scrDepth  = look.depth or 0
      layer.enabled   = true
      layer.locked    = false
      layer.parentUid = nil
      layer.children  = {}
      bakeList[#bakeList + 1] = layer
      if claim then
        claim.live = claim.live + 1
        layerStamp[layer] = { mark = claim, look = look }   -- settled when it bakes
      end
    end
  end

  -- Screen-space angle of a car-local segment under this job's camera.
  local function angleOf(p0, p1)
    api.setDecalLocalPos(probe, p0)
    local aUx, aUy = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
    api.setDecalLocalPos(probe, p1)
    local bUx, bUy = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
    return (math.abs(bUx - aUx) + math.abs(bUy - aUy)) > 1e-5
      and math.atan2(bUy - aUy, bUx - aUx) or (rand() * 2 * math.pi)
  end

  local before = #bakeList
  for bi, band in ipairs(job.bands) do
    -- One look per scrape: a single brush, width and tone for the whole band
    -- (with slight per-segment variation), so it reads as one continuous
    -- band rather than a string of unrelated marks. Depth by severity:
    --   any       abraded clear coat (haze) under the whole band, with
    --             light scuff streaks along it
    --   >= 0.25   the streaks cut down to primer
    --   >= 0.6    narrower bare cores among them: metal on a steel panel,
    --             dark plastic on a bumper
    local sev       = band.severity or 0.3
    local width     = 0.10 + rand() * 0.10          -- 10..20 cm band
    local hazeLook  = damageLook("haze", pickFromSet(HAZE_BRUSHES))
    local glass     = band.mat == "G"
    local lineLook  = damageLook((sev >= 0.25 and not glass) and "primer" or "scuff", pickFromSet(STREAK_BRUSHES))
    local coreLook  = damageLook(band.mat == "P" and "plastic" or "metal", pickFromSet(STREAK_BRUSHES))
    local segs = band.segments
    local s1, sn = segs[1], segs[#segs]
    local total, cx, cy, cz = 0, 0, 0, 0
    for _, sg in ipairs(segs) do
      total = total + sg.length
      cx, cy, cz = cx + sg.center.x, cy + sg.center.y, cz + sg.center.z
    end
    local mid, along = vec3(cx / #segs, cy / #segs, cz / #segs), angleOf(s1.startP, sn.endP)
    if stampVerbose then
      log('I', logTag, string.format("band: start=(%.2f,%.2f,%.2f) end=(%.2f,%.2f,%.2f) n=(%.2f,%.2f,%.2f) angle=%.0f deg",
        s1.startP.x, s1.startP.y, s1.startP.z, sn.endP.x, sn.endP.y, sn.endP.z, job.normal.x, job.normal.y, job.normal.z,
        math.deg(along)))
    end
    -- The dulled clear coat sits under the scores, no wider than them (a
    -- wider haze read as a soft slab with the lines on top).
    -- (A light band is its scores alone: a haze slab under every band drew
    -- each one's outline.)
    if not band.noHaze and sev >= 0.25 then
      addLayer(hazeLook, mid, total * 0.5 * STRETCH_OVERLAP * 0.95, width * 0.5, along, "scrape-haze-" .. bi,
               band.claim)
    end
    -- Paint transfer: the other car's colour on a car-on-car scrape; otherwise
    -- grime and rubber, which show on light paint (ref: dark marks on silver).
    -- (Both are fairly intact paint, so they too stay off deeper damage.)
    if band.transfer and not band.noHaze then
      addLayer(transferLook(band.transfer, pickFromSet(SMEAR_BRUSHES)), mid, total * 0.5 * STRETCH_OVERLAP,
               width * 0.4, along, "scrape-transfer-" .. bi, band.claim)
    elseif not band.noHaze and paintLum > 0.45 and rand() < 0.2 then
      addLayer(damageLook("transfer", pickFromSet(SMEAR_BRUSHES)), mid, total * 0.5 * STRETCH_OVERLAP,
               width * 0.3, along, "scrape-transfer-" .. bi, band.claim)
    end
    if not band.noLine then
      -- A primer band still has segments that only scored the colour coat;
      -- the mix of the two tones is what keeps it from reading as one block.
      local scoreLook = damageLook("scuff", lineLook.tex)
      for si, seg in ipairs(segs) do
        addLayer((sev >= 0.25 and rand() < 0.35) and scoreLook or lineLook, seg.center,
                 seg.length * 0.5 * STRETCH_OVERLAP, width * (0.45 + rand() * 0.1),
                 angleOf(seg.startP, seg.endP), "scrape-" .. bi .. "-" .. si, band.claim)
      end
    end
    if sev >= 0.6 and not glass then
      addLayer(coreLook, mid, total * 0.5 * STRETCH_OVERLAP * 0.8, width * 0.2, along, "scrape-core-" .. bi,
               band.claim)
    end
    if band.claim and band.claim.live == 0 then claimDone(band.claim) end   -- nothing captured
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
  -- The engine reads back one surface hit per projection pass: the one under
  -- the screen centre (a layer's decalPos; setDecalLocalPos moves its cursor,
  -- not that hit). So the camera is aimed through a real contact, the one
  -- nearest the centroid, rather than the centroid (which can fall in a gap
  -- between panels), and that contact's overshoot is read exactly. (An
  -- impact's stamps are jittered a few cm about their contact; the reading
  -- uses the contact itself.)
  local function contactOf(s) return s.contact or s.localPos end
  local aim, aimD = centroid, math.huge
  for _, s in ipairs(cluster.members) do
    local d = distLocal(contactOf(s), centroid)
    if d < aimD then aim, aimD = contactOf(s), d end
  end
  local camLocal = buildSyntheticCameraLocal(aim, cluster.face or averageNormals(cluster.members), clusterDist)
  setScratchProjectionFence(true)
  local tp = clockhp()
  decalProjection:projectDynamicDecals(camLocal, projM)
  perfAdd(tp, "projectMsTotal", "projectMsMax", "projectCalls")

  -- A stamp with a car-local direction is rotated to run along it as seen
  -- from this job's camera (screen angle of a short step along dir). Stamps
  -- sharing a direction (one impact's scuff, chips and gouge) share a turn.
  local probe = nil
  local dirAngles = {}
  local function angleFor(s)
    if not s.dir then return s.rot end
    if dirAngles[s.dir] then return dirAngles[s.dir] end
    probe = probe or decalProjection:getDecalData(camLocal, projM)
    local a = s.rot
    if probe and probe.cursorPosScreenUv then
      api.setDecalLocalPos(probe, s.localPos)
      local ax, ay = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
      api.setDecalLocalPos(probe, s.localPos + s.dir * 0.05)
      local bx, by = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
      if math.abs(bx - ax) + math.abs(by - ay) > 1e-5 then
        a = math.atan2(by - ay, bx - ax) + (rand() - 0.5) * 0.25
      end
    end
    dirAngles[s.dir] = a
    return a
  end

  -- The projection ray can pass a crumpled panel and stop on structure
  -- behind it (measured on a crushed bumper: 5-18 cm behind the contact, or
  -- through a hole to the far end of the car). The decal box is centred on
  -- that hit, so a stamp whose ray overshot gets a box laid along the camera
  -- axis and deep enough to reach back to the contact, and one that overshot
  -- by more than GAP.max is dropped. A hit in front of the contact is the
  -- visible skin (a fold over the node) and needs nothing. The overshoot is
  -- known only at the aim (above): stamps of that contact are compensated or
  -- dropped by it; other stamps within GAP.borrow of it (the same crushed
  -- patch) borrow the compensation; the rest paint without a reading and are
  -- never dropped on someone else's.
  local camFwd
  local function readAim(at)
    camFwd = camLocal:getColumn(1)
    probe = probe or decalProjection:getDecalData(camLocal, projM)
    local hp = probe and probe.decalPos
    if not hp then return nil end
    return (hp.x - at.x) * camFwd.x + (hp.y - at.y) * camFwd.y + (hp.z - at.z) * camFwd.z
  end
  local aimOver = readAim(aim)
  -- A hole reading gets up to two more looks (a pass each, out of the flush's
  -- reaim budget): the same camera aimed 8 cm in from the contact toward the
  -- car's middle (a node on a panel's edge - a bumper's lower lip - let the
  -- ray slip past it), then the hull face nearest the contact (a post's side
  -- face raking a bumper's front corner aims the camera sideways, past the
  -- front face). The first that finds skin stands for the contact; if neither
  -- does, the pass goes back to the first camera (the cluster's other stamps
  -- paint from it).
  if aimOver and aimOver > GAP.max and reaim.left > 0 then
    local first, firstCam, firstFwd = aimOver, camLocal, camFwd
    local face0 = cluster.face or averageNormals(cluster.members)
    local function tryAim(at, face)
      reaim.left = reaim.left - 1
      stampStats.reaims = stampStats.reaims + 1
      camLocal = buildSyntheticCameraLocal(at, face, clusterDist)
      local tr = clockhp()
      decalProjection:projectDynamicDecals(camLocal, projM)
      perfAdd(tr, "projectMsTotal", "projectMsMax", "projectCalls")
      probe = nil
      local v = readAim(at)
      if v and v <= GAP.max then
        stampStats.reaimsHelped = stampStats.reaimsHelped + 1
        return v
      end
      return nil
    end
    local found = nil
    local box = getSpawnAabb()
    if box then
      local c = vec3((box.minExtents.x + box.maxExtents.x) * 0.5, (box.minExtents.y + box.maxExtents.y) * 0.5,
                     (box.minExtents.z + box.maxExtents.z) * 0.5)
      local toC = c - aim
      toC = toC - firstFwd * toC:dot(firstFwd)
      if toC:length() > 1e-3 then found = tryAim(aim + toC:normalized() * 0.08, face0) end
    end
    if not found and reaim.left > 0 then
      local face = chooseHullOutward(aim, nil)
      if face:dot(-firstFwd) < 0.7 then found = tryAim(aim, face) end
    end
    if found then
      aimOver = found
    elseif camLocal ~= firstCam then
      camLocal = firstCam
      decalProjection:projectDynamicDecals(camLocal, projM)
      probe = nil
      readAim(aim)
      aimOver = first
    end
  end
  if aimOver then
    local bin = aimOver < 0 and "gapFront" or aimOver < 0.05 and "gapUnder5" or aimOver < 0.10 and "gapUnder10"
                or aimOver < 0.18 and "gapUnder18" or aimOver <= GAP.max and "gapUnder25" or "gapHole"
    stampStats[bin] = stampStats[bin] + 1
    if stampVerbose then
      log('I', logTag, string.format("overshoot %.3f m at (%.2f,%.2f,%.2f) (%d stamps) camFwd (%.2f,%.2f,%.2f)",
        aimOver, aim.x, aim.y, aim.z, #cluster.members, camFwd.x, camFwd.y, camFwd.z))
    end
  end
  local borrowed = aimOver and aimOver > 0 and aimOver <= GAP.max and aimOver or nil

  local skipped = 0
  for _, s in ipairs(cluster.members) do
    local rot = angleFor(s)
    -- Per-stamp style — getDecalData below snapshots api state into the layer.
    applyLook(s.look)
    -- s.scale / s.scaleY are half-sizes; setDecalScale takes the full extent.
    local sx, sz = 2 * s.scale, 2 * (s.scaleY or s.scale)
    local depth = decalDepth(sx, sz, true)
    local fromAim = distLocal(contactOf(s), aim)
    local over = nil
    if fromAim < 0.01 then
      over = aimOver
    elseif fromAim <= GAP.borrow then
      over = borrowed
    end
    local decalData = nil
    if over and over > GAP.max then
      stampStats.stampsSkippedGap = stampStats.stampsSkippedGap + 1
    else
      -- A compensating box lies along the camera axis the overshoot was
      -- measured on, whatever its depth: along the surface normal at a
      -- crushed hit (which can point anywhere) a box reaches back only part
      -- of its depth, and edge-on to the camera it smears. (Under GAP.noise
      -- the contact is just a node a little off the skin.)
      local compensate = over and over > GAP.noise
      if compensate then
        depth = math.max(depth, 2 * over + 0.08)
        stampStats.stampsGapDeepened = stampStats.stampsGapDeepened + 1
      end
      api.setDecalRotation(rot)
      api.setUseSurfaceNormal(not compensate)
      api.setDecalScale(vec3(sx, depth, sz))
      local tl = clockhp()
      decalData = decalProjection:getDecalData(camLocal, projM)
      -- Move the layer's cursor from the aim (where project placed it) to the
      -- stamp's own position; the bake places the box on the surface there.
      if decalData then api.setDecalLocalPos(decalData, s.localPos) end
      perfAdd(tl, "layerMsTotal", nil, "layerCalls")
    end
    if not decalData then
      stampSettled(s)
    else
      -- Reject stamps whose projection lands outside the camera frustum
      -- (cursor outside [0,1]) — those would paint nothing or paint at the
      -- frustum edge incorrectly.
      local cuv = decalData.cursorPosScreenUv
      if not cuv or cuv.x < 0 or cuv.x > 1 or cuv.y < 0 or cuv.y > 1 then
        skipped = skipped + 1
        stampSettled(s)
      else
        decalData.uid       = nextLayerUid()
        decalData.name      = "scratch"
        decalData.scrDepth  = s.look.depth or 0
        decalData.enabled   = true
        decalData.locked    = false
        decalData.parentUid = nil
        decalData.children  = {}
        layerStamp[decalData] = s   -- settled when it bakes (bakePending)
        if fromAim >= 0.01 then stampStats.stampsUnmeasured = stampStats.stampsUnmeasured + 1 end
        bakeList[#bakeList + 1] = decalData

        if stampVerbose then
          log('I', logTag, string.format(
            "stamp: input pos=(%.2f,%.2f,%.2f) | decalPos=(%.2f,%.2f,%.2f) cursor=(%.3f,%.3f) uid=%s",
            s.localPos.x, s.localPos.y, s.localPos.z,
            decalData.decalPos.x, decalData.decalPos.y, decalData.decalPos.z,
            cuv.x, cuv.y, decalData.uid))
        end
      end
    end
  end
  api.setUseSurfaceNormal(true)
  setScratchProjectionFence(false)
  if skipped > 0 then
    stampStats.stampsSkippedMissed = stampStats.stampsSkippedMissed + skipped
  end
end

-- Per-frame drain. Cluster this frame's discrete stamps into jobs, run up to
-- MAX_PROJECTS_PER_FRAME jobs from the head of the queue (the rest wait for
-- the next frame), and bake everything they produced in ONE bakeLayers call.
local function flushPendingStamps()
  local veh = resolveDecalProjection() and getPlayerVehicle(0)
  if not veh then
    for _, st in ipairs(pendingStampInputs) do stampSettled(st) end
    pendingStampInputs = {}
    dropJobs(jobQueue)
    return
  end
  local vid = veh:getId()

  if #pendingStampInputs > 0 then
    if pendingStampsVid == vid then
      local clusters = buildClusters(pendingStampInputs)
      for i = 1, #clusters do
        if not enqueueJob(clusters[i], vid) then dropJob(clusters[i]) end
      end
    else
      for _, st in ipairs(pendingStampInputs) do stampSettled(st) end
    end
    pendingStampInputs = {}
  end
  if jobQueueVid ~= vid then
    dropJobs(jobQueue)
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
  reaim.left     = reaim.perFlush
  -- Take jobs from the head until the pass budget or the layer budget is
  -- reached (bake costs ~1 ms per layer); always at least one job.
  local run, layers = 0, 0
  local maxRun = math.min(n, MAX_PROJECTS_PER_FRAME)
  while run < maxRun do
    local j = jobQueue[run + 1]
    local jl = j.stream and (#j.segments + 3 * #j.bands) or #j.members
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
    local ok, err = pcall(job.stream and runStreamJob or runClusterJob, job, projM, bakeList)
    if not ok then
      -- Discard whatever the failed job half-produced.
      for k = #bakeList, before + 1, -1 do
        local st = layerStamp[bakeList[k]]
        if st then stampSettled(st) end
        bakeList[k] = nil
      end
      dropJob(job)
      api.setUseSurfaceNormal(true)
      setScratchProjectionFence(false)
      stampStats.jobsFailed = stampStats.jobsFailed + 1
      log('E', logTag, "projection job failed: " .. tostring(err))
    elseif not job.stream then
      clusters = clusters + 1
    end
  end

  stampStats.projectsIssued = stampStats.projectsIssued + run
  stampStats.clustersTotal  = stampStats.clustersTotal + clusters
  if run < n then stampStats.framesDeferred = stampStats.framesDeferred + 1 end
  -- Shallow before deep (stable): one impact's haze must not land on the
  -- neighbouring impact's gouge just because it was captured later.
  for i = 1, #bakeList do bakeList[i].scrOrder = i end
  table.sort(bakeList, function(a, b)
    local da, db = a.scrDepth or 0, b.scrDepth or 0
    if da ~= db then return da < db end
    return a.scrOrder < b.scrOrder
  end)
  for i = 1, #bakeList do bakeQueue[#bakeQueue + 1] = bakeList[i] end
end
flushPendingStampsRef = flushPendingStamps

-- Bake up to BAKE_LAYERS_PER_FRAME queued layers. Returns true if it baked.
local function bakePending()
  local n = #bakeQueue
  if n == 0 then return false end
  local veh = getPlayerVehicle(0)
  if not veh or veh:getId() ~= jobQueueVid or not resolveDecalProjection() then
    for i = 1, n do
      local st = layerStamp[bakeQueue[i]]
      if st then stampSettled(st) end
    end
    table.clear(bakeQueue)
    return false
  end
  local k = math.min(n, BAKE_LAYERS_PER_FRAME)
  local chunk = {}
  for i = 1, k do chunk[i] = bakeQueue[i] end
  for i = k + 1, n do bakeQueue[i - k] = bakeQueue[i] end
  for i = n - k + 1, n do bakeQueue[i] = nil end
  local tb = clockhp()
  -- (A bake that throws partway may already have put some of the chunk on the
  -- canvas; its pieces settle as lost all the same, so a later mark there may
  -- lift what did land. Rare enough to accept.)
  local ok, err = pcall(decalProjection.bakeLayers, decalProjection, chunk, veh.JBeam or veh.jbeam)
  perfAdd(tb, "bakeMsTotal", "bakeMsMax", "bakeCalls")
  for i = 1, k do
    local st = layerStamp[chunk[i]]
    if st then stampSettled(st, ok) end
  end
  if not ok then
    log('E', logTag, "bake failed: " .. tostring(err))
    return false
  end
  perfStats.bakeLayersTotal = perfStats.bakeLayersTotal + k
  M._lastDecal = chunk[k]
  combineDirty = true
  stampStats.bakesIssued   = stampStats.bakesIssued + 1
  stampStats.framesFlushed = stampStats.framesFlushed + 1
  return true
end
bakePendingRef = bakePending

-- enqueueImpact's opts.
local IMPACT = { plain = {}, onCar = { onCar = true }, brief = { brief = true } }

-- Severity 0..1 from contact force: 0.8 kN (a knock) .. 20.8 kN (a crunch).
local function severityOf(force)
  return math.min(1, math.max(0, ((force or 0) - 800) / 20000))
end

-- Stamp opts for a single console/legacy event (M.stampAt's kind strings and
-- a 1-point slide fallback): a small scuff, chipped if it was pressed hard.
local function styleForEvent(kind, force, mat)
  local heavy = severityOf(force)
  if (kind == "impact" or heavy > 0.3) and mat ~= "G" then
    return { scale = 0.05 + heavy * 0.04, dist = 0.7 + heavy * 1.6,
             look = damageLook("chip", pickFromSet(CHIP_BRUSHES)) }
  end
  return { scale = 0.05 + rand() * 0.03, look = damageLook("haze", pickFromSet(HAZE_BRUSHES)) }
end

-- An impact is composed by how the panel met what it hit:
--   sliding across it (dir, car-local, and tangential speed ts in m/s - by
--     the time BeamNG reports a crash contact the node has mostly stopped, so
--     0.3-2.5 m/s is typical): the clear coat abrades over the patch around
--     the node that reported it (static contacts come per physics node, ~30 cm
--     apart, so one event stands for that area) - a haze patch sized by the
--     slide, at most one per 30 cm cell, with streaks dragged along it on a
--     firmer slide;
--   pressed hard either way (force): small chips, and on a hard glancing hit a
--     gouge - a primer rim with the bare substrate (steel, or a bumper's
--     plastic) inside.
-- A square-on crush leaves the paint mostly glossy (ref photo 5: crushed
-- metal, paint intact between the creases): a hard one dulls a small, ragged
-- patch where it pressed (a big round scuff read as a bubble) and chips it.
-- Glass contacts only scuff. The whole composition is admitted or reduced up
-- front (deep marks first) so the aggregate cap can't keep the haze and drop
-- the gouge. Returns whether anything was admitted. (I) Camera distance grows
-- with force so a heavy crunch is painted from a grazing angle.
local function enqueueImpact(localPos, localNormal, force, vid, mat, dir, ts, transfer, opts)
  -- opts.onCar: another car's smooth panel, not concrete or asphalt.
  -- opts.brief: a slide too brief to trace; its own spots, so a burst of them
  -- can't use up a real impact's.
  opts = opts or IMPACT.plain
  -- No room: drop it whole, before it takes a spot or leaves a mark record.
  if stampRoom(vid) <= 0 then
    stampStats.aggregateDropped = stampStats.aggregateDropped + 1
    return false
  end
  local iKey = spotKey(localPos, opts.brief and "f" or "i")
  if not spotFree(iKey, SPOT.maxImpact) then
    stampStats.spotsSkipped = stampStats.spotsSkipped + 1
    return false
  end
  if dir then
    -- Neighbouring contacts share one direction: strokes of separate marks
    -- crossing at large angles (a comb over a band, an asterisk) never happen
    -- in a real scrape.
    local shared = dirNear(localPos, 0.35)
    if shared then dir = shared:dot(dir) < 0 and -shared or shared end
  end
  local sev = severityOf(force)
  local slide = dir and math.min(1, (ts or 0) / 3) or 0
  local glass = mat == "G"
  local dist = 0.7 + sev * 1.6
  local jitter = 0.03
  local p = vec3(localPos.x + (rand() - 0.5) * 2 * jitter, localPos.y + (rand() - 0.5) * 2 * jitter,
                 localPos.z + (rand() - 0.5) * 2 * jitter)
  local rot = rand() * 2 * math.pi

  -- unit: specs that must be admitted together (a gouge's rim and core);
  -- key: a spot the spec claims if it is kept.
  local specs = {}
  local function add(look, scale, scaleY, unit, key)
    specs[#specs + 1] = { look = look, scale = scale, scaleY = scaleY, unit = unit or #specs + 1,
                          rank = look.depth, key = key }
  end
  -- A gouge needs an edge dragged across the panel, so only glancing hits
  -- get one (a square-on crush leaves chips); and one per spot, since a
  -- second at its own angle reads as an X.
  local gouges = sev >= 0.55 and dir and not glass and not deepMarkNear(p, 0.12, LOOK_DEPTH.plastic)
  if dir then
    local patch = (0.08 + 0.07 * math.max(slide, 0.5 * sev)) * (0.85 + 0.3 * rand())  -- half: 16..30 cm across
    -- (A brief slide uses its own cells: a burst of them left a real impact
    -- there only chips or a gouge.)
    local hKey = spotKey(p, opts.brief and "fh" or "h", 0.3)
    local stKey = spotKey(p, opts.brief and "fst" or "st", 0.3)
    if spotFree(hKey, 1) and not deepMarkNear(p, patch, LOOK_DEPTH.primer) then
      -- Concrete rubs the clear coat off; another car's smooth panel only dulls
      -- it, and around a gouge a light patch read as a halo: the gouge is the
      -- mark there.
      local kind = (opts.onCar or gouges) and "haze" or "abrasion"
      add(damageLook(kind, pickFromSet(HAZE_BRUSHES)), patch, patch * 0.55, nil, hKey)
    end
    -- Streaks would lift an earlier bare core or gouge back to primer/scuff.
    -- Beside this hit's own gouge they are only dulled clear coat: light
    -- streaks (primer or scuffed paint read alike on dark paint) swamped its
    -- primer rim and steel core.
    if (slide > 0.33 or sev >= 0.3) and spotFree(stKey, 1) and not deepMarkNear(p, patch, LOOK_DEPTH.plastic) then
      local kind = gouges and "haze" or (sev >= 0.3 and not glass) and "primer" or "scuff"
      add(damageLook(kind, pickFromSet(DRAG_BRUSHES)), patch * 1.1, patch * 0.38, nil, stKey)
    end
  elseif sev >= (opts.onCar and 0.3 or 0.15) then
    -- A hard crush scuffs the paint it presses on: a small, elongated,
    -- ragged patch of dulled clear coat (a big round one read as a bubble).
    -- Concrete or asphalt abrades from ~4 kN; another car's smooth panel
    -- only when much harder (ref 5: paint intact).
    local hKey = spotKey(p, "h", 0.3)
    local patch = (0.04 + 0.05 * sev) * (0.85 + 0.3 * rand())   -- half: 8..18 cm long
    if spotFree(hKey, 1) and not deepMarkNear(p, patch, LOOK_DEPTH.primer) then
      add(damageLook("haze", HAZE_BRUSHES[2]), patch, patch * 0.5, nil, hKey)
    end
  end
  -- Paint transfers where one panel wipes along the other; a square-on hit
  -- just presses (a round smear there read as a splat of the other car's paint).
  if transfer and dir then
    local half = 0.08 + 0.05 * slide
    -- Transfer is fairly intact paint; it would lift deeper damage under it.
    if not deepMarkNear(p, half, LOOK_DEPTH.primer) then
      add(transferLook(transfer, pickFromSet(SMEAR_BRUSHES)), half, half * 0.45)
    end
  end
  -- Chips are a few flakes, only on a solid hit; most crushed paint stays on.
  -- (The brush's flakes are 4-11% of its width, so an 8-11 cm patch gives
  -- flakes of 4-11 mm: a texel or two of the canvas, small enough to read as
  -- chips, big enough not to blur into a cloud.) Primer chips would lift an
  -- earlier gouge's core back to primer.
  local chipHalf = 0.04 + 0.015 * sev
  if sev >= 0.4 and not glass and not deepMarkNear(p, chipHalf, LOOK_DEPTH.plastic) then
    add(damageLook("chip", pickFromSet(CHIP_BRUSHES)), chipHalf)
  end
  if gouges then
    local g = GOUGES[rand(#GOUGES)]
    local len = 0.06 + 0.08 * sev
    local core = damageLook(mat == "P" and "plastic" or "metal", g.core)
    add(damageLook("primer", g.rim), len, len * 0.6, "gouge")
    add(core, len, len * 0.6, "gouge")
    specs[#specs - 1].rank = core.depth   -- the rim goes wherever its core goes
  end
  if #specs == 0 then return false end
  -- Short on room: keep the deepest marks, a gouge's rim and core together.
  local room = stampRoom(vid)
  if room < #specs then
    for i, sp in ipairs(specs) do sp.order = i end
    table.sort(specs, function(a, b)
      if a.rank ~= b.rank then return a.rank > b.rank end
      return a.order < b.order
    end)
    local keep, units = {}, {}
    for _, sp in ipairs(specs) do units[sp.unit] = (units[sp.unit] or 0) + 1 end
    local taken = {}
    for _, sp in ipairs(specs) do
      if taken[sp.unit] or #keep + units[sp.unit] <= room then
        taken[sp.unit] = true
        keep[#keep + 1] = sp
      end
    end
    specs = keep
    if #specs == 0 then return false end
    table.sort(specs, function(a, b) return a.look.depth < b.look.depth end)
  end
  local depth, radius = 0, 0
  spotCommit(iKey)
  for _, sp in ipairs(specs) do
    depth = math.max(depth, sp.look.depth)
    radius = math.max(radius, sp.scale, sp.scaleY or 0)
    if sp.key then spotCommit(sp.key) end
  end
  local mark = newClaim({ iKey })
  mark.entry = logMark(localPos, localNormal, "i", depth, radius, dir)
  for _, sp in ipairs(specs) do
    local taken = enqueueStamp(p, localNormal, { look = sp.look, scale = sp.scale, scaleY = sp.scaleY, dist = dist,
                                                 noJitter = true, rot = rot, dir = dir, mark = mark,
                                                 contact = localPos,
                                                 key = sp.key, radius = math.max(sp.scale, sp.scaleY or 0) }, vid)
    if not taken and sp.key then spotHits[sp.key] = math.max(0, (spotHits[sp.key] or 1) - 1) end
  end
  if mark.live == 0 then claimDone(mark) end   -- none taken after all
  return true
end

-- A slide band's deepest look, for the mark log.
local function bandDepth(sev)
  return sev >= 0.6 and LOOK_DEPTH.metal or sev >= 0.25 and LOOK_DEPTH.primer or LOOK_DEPTH.scuff
end

-- Which of a new band's layers would lift an earlier, deeper mark under it.
local function bandGuard(p, half)
  return { noHaze = deepMarkNear(p, half, LOOK_DEPTH.primer), noLine = deepMarkNear(p, half, LOOK_DEPTH.plastic) }
end

-- ---- car-on-car contact ----
-- BeamNG reports node-vs-world contacts to onNodeCollision, but not
-- node-vs-vehicle ones, in either car's VM (measured: a pickup T-boning the
-- player car logged only its own tyres). The engine does say which objects
-- touch (map.objects[id].objectCollisions), and GE can read any vehicle's
-- nodes. So while the player car touches another vehicle and they are moving
-- relative to each other, every CVC_INTERVAL the painter finds the player's
-- body nodes within CVC_RADIUS of the other car's nodes (spatial hash) and
-- treats each as a contact: an impact sized by the closing speed, oriented by
-- the relative velocity, plus the other car's paint smeared on. Nodes press
-- into the other car's triangles rather than its nodes, so the radius is
-- ~20 cm (8 cm found almost nothing). Two wrecks left wedged together don't
-- move, so they cost nothing and use up no mark budget.
local CVC_INTERVAL   = 0.1   -- s between probes while touching
local CVC_MIN_GAP    = 0.03  -- s; a touch flickering on and off can't probe faster
local CVC_RADIUS     = 0.2   -- m
local CVC_MAX_MARKS  = 10    -- contacts painted per probe, over every partner (closest first)
local CVC_SWIPE_SPEED = 2.0  -- m/s along the panel above which a contact is a scrape, not a hit
local CVC_SLIDE_MIN  = 1.0   -- m/s along the panel below which a contact has no slide direction
local CVC_CLOSING_MIN = 1.3  -- m/s; slower and not sliding: resting contact, no mark
local CVC_SWIPE_HALF = 0.25  -- m, half-length of a scrape band through one contact
-- Only the contact front is painted: player nodes no further from the other
-- car than the closest one plus this. Node rows above and below it are within
-- CVC_RADIUS of the other car's nodes (nodes are 10-30 cm apart) but not
-- touching, and painted one swipe as bands at several heights.
local CVC_FRONT      = 0.06  -- m
local cvcBodyNodes   = {}    -- vid -> { ids = {cid...}, mats = "MPM..." } (from the detector)
local cvcSince       = 0
local cvcTouching    = false

-- From the detector: the car's paintable body nodes and each one's material
-- initial (M/P), in the same order.
M.setBodyNodes = function(vid, nodes, mats) cvcBodyNodes[vid] = { ids = nodes, mats = mats or "" } end

local function resetCarContacts()
  table.clear(cvcBodyNodes)
  cvcSince, cvcTouching = 0, false
end

-- Other vehicles the player car is touching right now.
local function touchingVehicles(pid)
  local mo = map and map.objects and map.objects[pid]
  local cols = mo and mo.objectCollisions
  if not cols then return nil end
  local out = nil
  for oid, state in pairs(cols) do
    if state == 1 then
      local o = scenetree.findObjectById(oid)
      if o and o.getNodeCount then out = out or {}; out[#out + 1] = o end
    end
  end
  return out
end

-- Numeric cell key (exact in a double for |coord| < 10 km at 20 cm cells).
local function cellKey(cx, cy, cz)
  return ((cx + 50000) * 100000 + (cy + 50000)) * 100000 + (cz + 50000)
end

-- Player body nodes within CVC_RADIUS of O's nodes, closest first. Only the
-- nodes inside the other car's box (plus the radius) are tested, and only the
-- other car's nodes inside ours are hashed.
local function probeContacts(P, O, nodes)
  local cell, R2 = CVC_RADIUS, CVC_RADIUS * CVC_RADIUS
  local pb, ob = P:getWorldBox(), O:getWorldBox()
  local pmin, pmax, omin, omax = pb.minExtents, pb.maxExtents, ob.minExtents, ob.maxExtents
  local grid = {}
  for i = 0, O:getNodeCount() - 1 do
    local x, y, z = O:getNodeAbsPositionXYZ(i)
    if x > pmin.x - cell and x < pmax.x + cell and y > pmin.y - cell and y < pmax.y + cell
       and z > pmin.z - cell and z < pmax.z + cell then
      local k = cellKey(math.floor(x / cell), math.floor(y / cell), math.floor(z / cell))
      local b = grid[k]
      if not b then b = {}; grid[k] = b end
      b[#b + 1] = x; b[#b + 1] = y; b[#b + 1] = z
    end
  end
  local hits = {}
  for k, i in ipairs(nodes) do
    local x, y, z = P:getNodeAbsPositionXYZ(i)
    if x > omin.x - cell and x < omax.x + cell and y > omin.y - cell and y < omax.y + cell
       and z > omin.z - cell and z < omax.z + cell then
      local cx, cy, cz = math.floor(x / cell), math.floor(y / cell), math.floor(z / cell)
      local best = R2
      for dx = -1, 1 do for dy = -1, 1 do for dz = -1, 1 do
        local b = grid[cellKey(cx + dx, cy + dy, cz + dz)]
        if b then
          for j = 1, #b, 3 do
            local ex, ey, ez = b[j] - x, b[j + 1] - y, b[j + 2] - z
            local d2 = ex * ex + ey * ey + ez * ez
            if d2 < best then best = d2 end
          end
        end
      end end end
      if best < R2 then hits[#hits + 1] = { k = k, d2 = best, x = x, y = y, z = z } end
    end
  end
  table.sort(hits, function(a, b) return a.d2 < b.d2 end)
  return hits
end

local function updateCarContacts(dt, veh)
  cvcSince = cvcSince + dt
  local pid = veh:getId()
  local body = cvcBodyNodes[pid]
  if not body then return end
  local others = touchingVehicles(pid)
  local fresh = others and not cvcTouching and cvcSince >= CVC_MIN_GAP  -- a swipe is brief: probe at onset
  cvcTouching = others ~= nil
  if not others or (cvcSince < CVC_INTERVAL and not fresh) then return end
  cvcSince = 0
  local t0 = clockhp()
  local invM = veh:getRefNodeMatrix():fullInverse()
  local rotOnly = invM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))
  local pv = veh:getVelocity()
  local budget = CVC_MAX_MARKS
  for _, O in ipairs(others) do
    local rel = O:getVelocity() - pv                -- other car relative to ours
    -- Cars slide past each other horizontally; the vertical part of their
    -- relative motion is suspension bounce and would tilt the scrapes.
    local lrel = rotOnly:mulP3F(rel)
    lrel.z = 0
    -- Wedged together at rest: nothing can mark, so skip the probe entirely.
    if budget > 0 and lrel:length() >= math.min(CVC_CLOSING_MIN, CVC_SLIDE_MIN) then
      local col = O.color
      local transfer = col and { col.x, col.y, col.z } or nil
      local hits = probeContacts(veh, O, body.ids)
      perfStats.cvcProbes = perfStats.cvcProbes + 1
      local front = hits[1] and (math.sqrt(hits[1].d2) + CVC_FRONT) ^ 2 or 0
      for k = 1, #hits do
        if budget <= 0 or hits[k].d2 > front then break end   -- sorted closest first
        local h = hits[k]
        local mat = body.mats:sub(h.k, h.k)
        if mat == "" then mat = "M" end
        local lp = invM:mulP3F(vec3(h.x, h.y, h.z))
        local n = chooseHullOutward(lp, nil)
        local closing = math.max(0, -lrel:dot(n))
        local tang = lrel - n * lrel:dot(n)
        local ts = tang:length()
        -- A crush shoves the panels about; only a real slide has a direction
        -- (noisy small ones made neighbouring streaks cross).
        local dir = ts > CVC_SLIDE_MIN and tang * (1 / ts) or nil
        if stampVerbose then
          log('I', logTag, string.format("car contact: lp=(%.2f,%.2f,%.2f) n=(%.1f,%.1f,%.1f) rel=(%.2f,%.2f,%.2f) ts=%.2f closing=%.2f",
            lp.x, lp.y, lp.z, n.x, n.y, n.z, lrel.x, lrel.y, lrel.z, ts, closing))
        end
        if ts > CVC_SWIPE_SPEED then
          -- Sliding along the panel: a scrape band through this contact, along
          -- the relative motion; neighbouring contacts' bands join into one.
          -- One band per 20 cm cell: ~10 contacts every 0.1 s over a whole
          -- swipe would otherwise stack into solid primer.
          local key = spotKey(lp, "cs", 0.2)
          if spotFree(key, 1) then
            local sev = math.min(1, 0.05 + closing / 8 + ts / 60)
            local guard = bandGuard(lp, CVC_SWIPE_HALF)
            local claim = newClaim({ key })
            if enqueueStreamLocal({ lp - dir * CVC_SWIPE_HALF, lp + dir * CVC_SWIPE_HALF }, { n }, pid, sev, mat,
                                  transfer, guard, claim) then
              spotCommit(key)
              claim.entry = logMark(lp, n, "s", bandDepth(sev), CVC_SWIPE_HALF, dir)
              budget = budget - 1
            end
          end
        elseif (closing >= CVC_CLOSING_MIN or dir)
               and enqueueImpact(lp, -n, 800 + closing * 2200, pid, mat, dir, ts, transfer, IMPACT.onCar) then
          budget = budget - 1
        end
      end
    end
  end
  local ms = (clockhp() - t0) * 1000
  perfStats.cvcMsTotal = perfStats.cvcMsTotal + ms
  if ms > perfStats.cvcMsMax then perfStats.cvcMsMax = ms end
end
updateCarContactsRef = updateCarContacts
resetCarContactsRef = resetCarContacts

-- A slide stream is one body point dragged along the ground. Its world
-- samples trace how far the CAR moved, not where the body was scraped - the
-- contact stays at the same body point. (Converting every sample with the
-- current pose used to paint a trail as long as the slide, up to ~3.5 m,
-- smeared back across and off the body.) So the scrape is drawn AT the
-- latest contact, along the slide axis (first->last displacement, which is
-- exact because the ground doesn't move) flattened onto the panel, as long as
-- a contact patch. Neighbouring contact nodes' bands join into the rash.
-- Depth comes from how hard it pressed and how far it dragged; a repeat pass
-- over the same spot digs deeper.
local SLIDE_BAND = { min = 0.30, max = 0.70 }   -- band length, m (long enough to join neighbours)
local function enqueueSlide(points, invM, rotOnly, vid)
  local first, last = points[1], points[#points]
  local anchor = invM:mulP3F(vec3(last[1], last[2], last[3]))
  local sKey = spotKey(anchor, "s")
  if not spotFree(sKey, SPOT.maxSlide) then
    stampStats.spotsSkipped = stampStats.spotsSkipped + 1
    return
  end
  local pass = (spotHits[sKey] or 0) + 1
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
  -- Pressed, not dragged: no usable direction, or the contact moved mostly
  -- into the panel (within ~20 deg of its normal - a bumper's front face
  -- pushed into a post while the car dipped; a band there ran its strokes
  -- along the dip): a press, composed like a square-on hit (with its claim).
  if dlen < 1e-4 or nlen < 1e-6 or dlen < 0.35 * dist then
    enqueueImpact(anchor, nlen > 1e-6 and normal or vec3(0, 0, 1), points.f, vid, points.m, nil, nil, nil, IMPACT.brief)
    return
  end
  dir = dir * (1 / dlen)
  local half = 0.5 * math.min(SLIDE_BAND.max, SLIDE_BAND.min + 0.12 * dist)
  -- How hard it pressed sets the depth; a long drag adds a little.
  local sev = math.min(1, math.max(0, ((points.f or 0) - 1000) / 14000) + math.min(0.2, dist / 10)
                          + (pass - 1) * 0.35)
  local guard = bandGuard(anchor, half)
  local claim = newClaim({ sKey })
  if enqueueStreamLocal({ anchor - dir * half, anchor + dir * half }, { normal }, vid, sev, points.m, nil, guard,
                        claim) then
    spotCommit(sKey)
    claim.entry = logMark(anchor, normal, "s", bandDepth(sev), half, dir)
  end
end

-- (G) Single per-frame entry point from scratches_detect. The vehicle sends
-- its id, the frame's discrete events and every slide stream that ended this
-- frame in ONE call. World -> vehicle-local conversion happens here, once per
-- batch (one matrix inverse per frame instead of one per event).
--   events  : list of {x,y,z,nx,ny,nz,kind,sev,mat,dx,dy,dz,ts}
--             kind "i" = collision impact, "s" = 1-point slide fallback;
--             sev = normalForce in N; mat = body material initial (M/P/G);
--             d = world direction the panel slid along the surface (0 if
--             none), ts = that tangential speed in m/s.
--   streams : list of point lists, each {{x,y,z,nx,ny,nz}, ..., m=mat, f=peak force}
--             (>= 2 points)
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

  local invM    = veh:getRefNodeMatrix():fullInverse()
  local rotOnly = invM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))

  -- The detector also sees a trickle of contacts against another car's body,
  -- with the node's absolute (not relative) velocity, so their direction is
  -- meaningless; updateCarContacts paints those. Drop detector contacts that
  -- lie in a touching car's box (plus a margin); a barrier or the ground
  -- elsewhere still scrapes as usual.
  local boxes = nil
  local others = touchingVehicles(vid)
  if others then
    boxes = {}
    for _, O in ipairs(others) do
      local b = O:getWorldBox()
      boxes[#boxes + 1] = { b.minExtents.x - 0.25, b.minExtents.y - 0.25, b.minExtents.z - 0.25,
                            b.maxExtents.x + 0.25, b.maxExtents.y + 0.25, b.maxExtents.z + 0.25 }
    end
  end
  local function onOtherCar(x, y, z)
    if not boxes then return false end
    for _, b in ipairs(boxes) do
      if x > b[1] and y > b[2] and z > b[3] and x < b[4] and y < b[5] and z < b[6] then
        stampStats.carContactsDropped = (stampStats.carContactsDropped or 0) + 1
        return true
      end
    end
    return false
  end

  if events then
    for i = 1, #events do
      local e = events[i]
      local lp = invM:mulP3F(vec3(e[1], e[2], e[3]))
      local ln = rotOnly:mulP3F(vec3(e[4], e[5], e[6]))
      if onOtherCar(e[1], e[2], e[3]) then
        -- painted by updateCarContacts
      else
        local dir = nil
        if e[10] and (e[10] ~= 0 or e[11] ~= 0 or e[12] ~= 0) then
          dir = rotOnly:mulP3F(vec3(e[10], e[11], e[12]))
        end
        if e[7] == "i" then
          enqueueImpact(lp, ln, e[8], vid, e[9], dir, e[13])
        elseif dir then
          -- A slide too brief to trace (a few physics ticks, the contact
          -- moving under 1.5 cm - a bumper corner raked across a post): a
          -- short drag along the slip, composed like a glancing hit.
          enqueueImpact(lp, ln, e[8], vid, e[9], dir, e[13], nil, IMPACT.brief)
        else
          -- No direction either: a press, composed like a square-on hit.
          enqueueImpact(lp, ln, e[8], vid, e[9], nil, nil, nil, IMPACT.brief)
        end
      end
    end
  end

  if streams then
    for si = 1, #streams do
      local points = streams[si]
      local last = points and points[#points]
      if points and #points >= 2 and not onOtherCar(last[1], last[2], last[3]) then
        enqueueSlide(points, invM, rotOnly, vid)
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
    {tex = "/art/dynamicDecals/textures/scr_streak_01.png", rgb = {0.0, 1.0, 0.0}, name = "streak_01 (GREEN)"},
    {tex = "/art/dynamicDecals/textures/scr_streak_02.png", rgb = {0.0, 1.0, 1.0}, name = "streak_02 (CYAN)"},
    {tex = "/art/dynamicDecals/textures/scr_haze_01.png",   rgb = {1.0, 1.0, 0.0}, name = "haze_01 (YELLOW)"},
    {tex = "/art/dynamicDecals/textures/scr_smear_01.png",  rgb = {1.0, 0.0, 1.0}, name = "smear_01 (MAGENTA)"},
    {tex = "/art/dynamicDecals/textures/scr_chips_01.png",  rgb = {0.5, 1.0, 0.5}, name = "chips_01 (LIGHT GREEN)"},
    {tex = "/art/dynamicDecals/textures/scr_chips_02.png",  rgb = {0.5, 0.5, 1.0}, name = "chips_02 (LIGHT BLUE)"},
    {tex = "/art/dynamicDecals/textures/scr_gouge_01_rim.png",  rgb = {1.0, 0.5, 0.0}, name = "gouge_01_rim (ORANGE)"},
    {tex = "/art/dynamicDecals/textures/scr_gouge_01_core.png", rgb = {1.0, 0.0, 0.5}, name = "gouge_01_core (PINK)"},
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
  table.clear(markLog)
  markGen = markGen + 1
  log('I', logTag, "cleared all stamps (textures flushed); layers before clear=" ..
    tostring(preClearLayers))
  -- Re-assert the damage layer before re-seeding. It otherwise runs once,
  -- from the binding stabilizer at setup, but a respawn (the Ctrl+R path that
  -- gets us here) can rebuild the .skin.dynamicTextures materials. Idempotent
  -- and cheap at clear frequency.
  setupDamageLayer()
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
  stampStats.projectsIssued = 0
  stampStats.clustersTotal = 0
  stampStats.streamsBaked = 0
  stampStats.streamSubstrokesTotal = 0
  stampStats.jobsDropped = 0
  stampStats.jobsFailed = 0
  stampStats.framesDeferred = 0
  stampStats.foreignDropped = 0
  stampStats.combinesRun = 0
  stampStats.rebinds = 0
  stampStats.spotsSkipped = 0
  stampStats.streamsMerged = 0
  stampStats.framesTicked = 0
  for _, k in ipairs({ "stampsSkippedGap", "stampsGapDeepened", "stampsUnmeasured", "reaims", "reaimsHelped",
                       "marksRetracted", "gapFront", "gapUnder5",
                       "gapUnder10", "gapUnder18", "gapUnder25", "gapHole" }) do
    stampStats[k] = 0
  end
  for k in pairs(perfStats) do perfStats[k] = 0 end
  log('I', logTag, "paint stats reset")
end

-- Machine-readable snapshot of every counter, for tools/bench.py and anything
-- else that wants numbers rather than log lines. Copies, so callers can keep it.
M.getStats = function()
  local stamp, perf = {}, {}
  for k, v in pairs(stampStats) do stamp[k] = v end
  for k, v in pairs(perfStats) do perf[k] = v end
  return {
    ready  = ready,
    stamp  = stamp,
    perf   = perf,
    detect = lastDetectStats,
    queue  = { stamps = #pendingStampInputs, jobs = #jobQueue, bake = #bakeQueue },
    config = { aggregateCap = AGGREGATE_PER_FRAME_CAP, clusterRadius = CLUSTER_RADIUS,
               projBudget = MAX_PROJECTS_PER_FRAME, flushInterval = FLUSH_INTERVAL,
               layerBudget = MAX_LAYERS_PER_FLUSH,
               fullRateCombine = fullRateCombine },
  }
end

-- The painter's cost on the most recent ready frame (ms); bench samples it.
M.getLastFrameMs = function() return perfStats.lastMs end

-- The mark log (see logMark): {{x,y,z,nx,ny,nz,kind,depth,radius,dx,dy,dz}, ...},
-- vehicle-local.
M.getMarks = function() return markLog end

-- Projection passes allowed per frame. Lower = flatter frame times during a
-- big crash (marks trickle in over a few frames); higher = marks land sooner.
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
-- recent: always keep this many most-recent lines; max: hard cap on log lines in the report.
local REPORT_LINES = { recent = 50, max = 140 }

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
  local firstRecent = math.max(1, n - REPORT_LINES.recent + 1)
  local picked = {}
  for i = 1, n do
    local e = logRing[i]
    if e.lvl == 'W' or e.lvl == 'E' or i >= firstRecent then
      picked[#picked + 1] = string.format("%s [%s] %s", e.lvl or 'I', e.src or '?', e.msg or '')
    end
  end
  -- Cap from the front so the most recent lines always survive.
  local startAt = math.max(1, #picked - REPORT_LINES.max + 1)
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
  -- The skin material is shared and outlives the painter; leave it as shipped.
  restoreDamageLayers()
  ready = false
  api = nil
  -- The projection was resolved from an upvalue of the api module we are
  -- dropping; holding it past unload would keep a stale handle alive.
  decalProjection = nil
  apiApp = nil
  table.clear(spotHits)
  markGen = markGen + 1
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
-- A reset can rebuild the car's materials; re-assert the damage layer and
-- re-bind on the next composite.
M.onVehicleResetted   = function(vid)
  local veh = getPlayerVehicle(0)
  if ready and veh and veh:getId() == vid then
    setupDamageLayer()
    rebindDirty = true
  end
end

return M
