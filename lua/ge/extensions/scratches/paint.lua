-- scratches_mod / paint.lua  (GELUA)
-- Game-engine-side painter. Owns the Dynamic Decals projection per player vehicle.
-- Phase 2 scaffold: load editor_api_dynamicDecals, auto-set the dynamicTextures
-- skin on supported vehicles, drive the per-frame onUpdate. Test stamp probe
-- (M.testStamp) is left as a stub for the next sub-step.

local M = {}

local logTag = "scratches.paint"

-- ---- debug log ring buffer (Phase 1.1) ----
-- Every mod log line is mirrored into a fixed-size ring so the in-panel log
-- pane and the one-click "Copy debug report" can show recent activity without
-- a console session. The local `log` below shadows the global logger for the
-- rest of this file, so every existing log() call site is captured for free.
local LOG_RING_MAX = 240
local logRing      = {}   -- {seq, t, lvl, src, msg}; oldest at [1], newest at [#]
local logRingSeq   = 0    -- monotonic id, survives drops — used for display/diff
local _log         = log  -- the real global logger, captured before shadowing

-- Append one line to the ring, dropping the oldest when full.
local function ringPush(lvl, src, msg)
  logRingSeq = logRingSeq + 1
  logRing[#logRing + 1] = { seq = logRingSeq, t = os.clock(), lvl = lvl, src = src, msg = msg }
  if #logRing > LOG_RING_MAX then table.remove(logRing, 1) end
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
local pendingStampsJBeam   = nil   -- jbeam the queued stamps belong to (drop on vehicle switch)
local AGGREGATE_PER_FRAME_CAP = 96 -- hard cap per frame; further enqueues drop
-- Greedy spatial-cluster radius (vehicle-local meters). Stamps within this
-- distance share a project camera. Bigger = fewer clusters = fewer projects;
-- too big and the shared cam can land on the wrong panel for off-axis stamps.
-- Keep this tighter than a full roof/side span: realism beats a few saved
-- projection passes here, because an over-broad cluster can aim through a roof
-- edge and paint side/rear panels that never touched the ground.
local CLUSTER_RADIUS         = 0.65

-- ---- variation: brush recency avoidance ----
-- Ring buffer of recently picked brushes. pickBrush() re-rolls once if it lands
-- on a recent pick. Cheap fix for "two identical chip_cluster brushes adjacent".
local recentBrushes    = {}
local RECENT_BRUSH_MAX = 3

-- Per-brush scale bias. chip_cluster is busy at default scale; streaks read
-- better slightly larger. Path -> multiplier.
local BRUSH_SCALE_BIAS = {
  ["/art/dynamicDecals/textures/scratch_chip_cluster.png"] = 0.75,
  ["/art/dynamicDecals/textures/scratch_streak_01.png"]    = 1.10,
  ["/art/dynamicDecals/textures/scratch_streak_02.png"]    = 1.10,
  ["/art/dynamicDecals/textures/scratch_streak_03.png"]    = 1.10,
  ["/art/dynamicDecals/textures/scratch_streak_05.png"]    = 1.10,
}

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
}
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

-- ---- paint canvas seed tunables ----
-- The dynamic-decals skin routes the body's metallic and roughness channels
-- through @DynamicTexture* — if we don't write to them, the body renders with
-- whatever happened to be in the uninitialized texture (usually matte). These
-- two scalars are what addPaintFill stamps into the metallic/roughness
-- channels as the canvas baseline. Defaults model "shiny dielectric paint":
--   PAINT_METALLIC  0.00  — paint is non-metal (clearcoat does the shine)
--   PAINT_ROUGHNESS 0.20  — moderately smooth, gives a glossy clearcoat reflection
-- The K debug panel exposes both as sliders so the user can preview values
-- in-game; changes there call M.reseedPaintCanvas() to re-bake the canvas.
local PAINT_METALLIC  = 0.00
local PAINT_ROUGHNESS = 0.20

-- Whether the seed also writes baseColor (the vehicle's paint color). Default
-- TRUE, and it needs to be: clearStamps now calls clearBakedTextures(), which
-- zeroes the baseColor channel — so the seed must repaint the body or it
-- renders black after every clear/reset. There's no livery to protect: the
-- mod skips any vehicle that already has a livery part (see ensureSkin), so
-- @DynamicTextureBaseColor only ever holds a plain paint color we can safely
-- re-stamp. Off is debug-only (metallic/roughness seeded, baseColor left
-- wiped). Toggled from the K debug panel.
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
local function ensureSkin(jbeam)
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
    return false
  end
  local dtPart = jbeam .. "_skin_dynamicTextures"

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
  if prevPart == dtPart then
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
    -- one-shot so single-material vehicles still get glossy paint.
    if not seedDone then
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

  if not ensureSkin(jbeam) then
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
  ready = true
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

-- Build an axis-aligned synthetic camera at `axis * dist` looking back toward
-- the vehicle origin. Same column convention as buildSyntheticCameraLocal:
-- col0=right(+X), col1=forward(+Y), col2=up(+Z), col3=position. The two-axis
-- version differs from the existing helper only in that the target is the
-- origin instead of an arbitrary local point — for the canvas seed we want
-- coverage of the whole body, not a single contact zone.
local function buildAxisCameraLocal(axis, dist)
  local camPos = axis * dist
  local fwd    = -axis            -- camera looks at origin
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

-- Seed the dynamic-texture canvas with a full-PBR paint baseline.
--
-- The `fill` layer type can only write baseColor (dynamicDecals.lua:301‑306 —
-- it serializes `name/blendMode/color/colorPaletteMapId/type`, nothing else),
-- so a fill alone leaves @DynamicTextureMetallic / @DynamicTextureRoughness
-- at whatever the initial texture contained — usually matte. We get around
-- that by stamping six full-canvas decals — one per cardinal axis — that
-- carry constant `_one.png` textures for color/metallic/roughness scaled by
-- PAINT_METALLIC and PAINT_ROUGHNESS via the projection-level intensity
-- knobs. Six projections gives every external panel at least one cam that
-- sees it head-on; the per-pixel composite picks the most-aligned write.
--
-- Cost: ~6 bakes at vehicle spawn, once. Zero per-frame work. Re-runs only
-- when the user moves a paint slider or calls clearStamps.
M.addPaintFill = function()
  if not ready then log('W', logTag, "addPaintFill: not ready"); return end
  if not resolveDecalProjection() then return end
  setScratchProjectionFence(false)
  local veh = getPlayerVehicle(0)
  if not veh then return end

  -- Resolve the paint color. It's applied below as a projection-free FILL
  -- layer, which writes every UV texel — so the roof (which the 6-axis decal
  -- seed leaves gapped) gets painted too. When PAINT_SEED_COLOR is off
  -- (debug only) no fill is added; the body keeps whatever baseColor survived.
  local r, g, b = 0.5, 0.5, 0.5
  if PAINT_SEED_COLOR then
    local pr, pg, pb = parseVehicleColor(getVehicleColor and getVehicleColor() or nil)
    if pr then
      r, g, b = pr, pg, pb
    else
      log('W', logTag, "addPaintFill: getVehicleColor unavailable; using mid-grey fallback")
    end
  end

  -- UseMousePos must be off so the projection cursor lands at screen-center
  -- (where the camera is aimed) instead of following the mouse pointer.
  -- Same dance flushPendingStamps does.
  if api.isUseMousePos and api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
  end

  local projM = getCameraProjMatrix()
  local AXES = {
    vec3( 1,  0,  0), vec3(-1,  0,  0),
    vec3( 0,  1,  0), vec3( 0, -1,  0),
    vec3( 0,  0,  1), vec3( 0,  0, -1),
  }
  local SEED_DIST  = 4.0  -- meters from origin; outside any car's bounding box
  local SEED_SCALE = 6.0  -- decal half-size; >= the largest vehicle dimension

  local bakeList = {}

  -- Uniform baseColor via a projection-free fill layer. Unlike the 6-axis
  -- decal seed, a fill writes every UV texel, so the roof — which the axis
  -- cameras leave gapped — gets painted too. decalProjection:bakeLayers
  -- dispatches on layer.type, so this fill table rides in the same bake as
  -- the metallic/roughness decals below.
  if PAINT_SEED_COLOR then
    bakeList[#bakeList + 1] = {
      name              = "scratches_base_color",
      type              = (api.layerTypes and api.layerTypes.fill) or 1,
      blendMode         = (api.blendModesMap and api.blendModesMap.Normal) or 1,
      color             = Point4F(r, g, b, 1),
      colorPaletteMapId = 0,
      enabled           = true,
      locked            = false,
      uid               = string.format("scr-fill-%08x", math.random(0, 0xffffffff)),
      parentUid         = nil,
      children          = {},
    }
  end

  for i, axis in ipairs(AXES) do
    local camLocal = buildAxisCameraLocal(axis, SEED_DIST)
    decalProjection:projectDynamicDecals(camLocal, projM)

    -- Metallic/roughness driven by setMetallicIntensity / setRoughnessIntensity
    -- regardless of mode. Color contribution gated by colorAlpha — when 0
    -- the decal stamp shouldn't disturb baseColor (alpha-zero color tint).
    api.setDecalTexturePath("color",     "/art/dynamicDecals/textures/_one.png")
    api.setDecalTexturePath("alpha",     "/art/dynamicDecals/textures/_one.png")
    api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_one.png")
    api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
    -- Colour comes from the fill layer above; these decals carry metallic/
    -- roughness only, so the colour tint is alpha-0 (writes no baseColor).
    api.setDecalColor(Point4F(1, 1, 1, 0))
    api.setMetallicIntensity(PAINT_METALLIC)
    api.setRoughnessIntensity(PAINT_ROUGHNESS)
    api.setDecalScale(vec3(SEED_SCALE, 1, SEED_SCALE))
    api.setDecalRotation(0)
    api.setUseSurfaceNormal(true)

    local decalData = decalProjection:getDecalData(camLocal, projM)
    if decalData then
      decalData.uid       = string.format("scr-seed-%d-%08x", i, math.random(0, 0xffffffff))
      decalData.name      = "scratches_base_paint_" .. tostring(i)
      decalData.enabled   = true
      decalData.locked    = false
      decalData.parentUid = nil
      decalData.children  = {}
      bakeList[#bakeList + 1] = decalData
    end
  end

  if #bakeList > 0 then
    decalProjection:bakeLayers(bakeList, veh.JBeam or veh.jbeam)
  end
  if PAINT_SEED_COLOR then
    log('I', logTag, string.format(
      "paint seed: fill rgb=(%.2f,%.2f,%.2f) + M=%.2f R=%.2f, %d layers baked",
      r, g, b, PAINT_METALLIC, PAINT_ROUGHNESS, #bakeList))
  else
    log('I', logTag, string.format(
      "paint seed: M=%.2f R=%.2f, %d layers baked (color=OFF, debug)",
      PAINT_METALLIC, PAINT_ROUGHNESS, #bakeList))
  end
end

-- Tunable setters used by the K debug panel sliders. Live-update the module
-- locals; the caller (drawUI) decides when to call clearStamps to re-seed
-- (typically on slider release, not while dragging).
M.setPaintMetallic = function(v)
  PAINT_METALLIC = math.min(1, math.max(0, tonumber(v) or 0))
end
M.setPaintRoughness = function(v)
  PAINT_ROUGHNESS = math.min(1, math.max(0, tonumber(v) or 0.2))
end
M.setPaintSeedColor = function(b)
  PAINT_SEED_COLOR = b and true or false
end
M.getPaintMetallic   = function() return PAINT_METALLIC   end
M.getPaintRoughness  = function() return PAINT_ROUGHNESS  end
M.getPaintSeedColor  = function() return PAINT_SEED_COLOR end

-- ---- per-frame ----
-- Forward declarations so onUpdate can call them; the function bodies are
-- defined further down (alongside stampAtLocal for flushPendingStamps;
-- alongside the K probes for drawUI).
local flushPendingStampsRef
local drawUIRef

local function onUpdate(dtReal, dtSim, dtRaw)
  if ready then
    -- Stabilize material bindings before stamps. BeamNG's coroutine job lands
    -- a frame or two after setup; this re-applies our desired set until it
    -- sticks, then fires the deferred canvas seed. Cheap once stable (one
    -- early-return on the latch).
    ensureDesiredMaterialsBound()
    -- Drain the per-frame discrete-stamp queue BEFORE api.onUpdate_ so the
    -- combineTextures step inside api.onUpdate_ picks up the freshly baked
    -- layers and the new stamps render this frame instead of next frame.
    -- Stream path manages its own bakes (already batched per stream).
    if flushPendingStampsRef then flushPendingStampsRef() end
    if api and api.onUpdate_ then api.onUpdate_() end
    -- (K) Draw the IMGUI debug panel after api.onUpdate_ so its frame state
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
  -- Drop any queued stamps belonging to the previous vehicle.
  pendingStampInputs = {}
  pendingStampsJBeam = nil
  -- Drop the previous vehicle's material-binding state so the new vehicle
  -- runs the discover/stabilize cycle from scratch.
  desiredMatIndices = nil
  matBindingsStable = false
  seedDone          = false
  -- The API has its own onVehicleSwitched that refreshes the projection shape;
  -- forward it.
  if api and api.onVehicleSwitched then api.onVehicleSwitched() end
end

local function onVehicleSpawned(vid)
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
  else
    log('W', logTag, "addDecal returned nil")
  end
  return decal
end

-- ---- scratch brushes ----
-- Generated by tools/generate_brushes.py. Greyscale shapes that get tinted by
-- setDecalColor at stamp time. Split into two purpose-specific sets so the
-- visual language stays clean:
--   IMPACT_BRUSHES — splatter / chip / claw shapes used for discrete
--     point-stamps (collision impacts and 1-point slide fallbacks). These
--     read as "something hit and bit the panel".
--   STRETCH_BRUSHES — directional streak shapes used by stampStream to draw
--     long stretched scrape decals along the slide path. These have fine
--     parallel lines that tile cleanly when scaled to high aspect ratios;
--     splatter shapes would smear into mush.
local IMPACT_BRUSHES = {
  "/art/dynamicDecals/textures/scratch_chip_cluster.png",
  "/art/dynamicDecals/textures/scratch_tbone.png",
  "/art/dynamicDecals/textures/scratch_raptor_claw_01.png",
  "/art/dynamicDecals/textures/scratch_raptor_claw_02.png",
}
local STRETCH_BRUSHES = {
  "/art/dynamicDecals/textures/scratch_streak_01.png",
  "/art/dynamicDecals/textures/scratch_streak_02.png",
  "/art/dynamicDecals/textures/scratch_streak_03.png",
  "/art/dynamicDecals/textures/scratch_streak_05.png",
}

-- Long straight slides used to become one large projected rectangle. On roof
-- slides that rectangle could span past the roof edge and mark the rear/side,
-- while visually reading as sparse because it was still a single layer. Chunk
-- by path length so long slides become many short, local scratches.
local STRETCH_MAX_SEGMENT_LEN = 0.22
local STRETCH_MAX_SEGMENTS_PER_STREAM = 40

-- Recency-aware random picker. Avoids the last RECENT_BRUSH_MAX picks if
-- possible. One re-roll max so small brush sets don't loop. The recentBrushes
-- ring is shared across both sets — keeps the picker simple and avoids
-- "two adjacent decals share a texture" even across slide+impact transitions.
local function pickFromSet(set)
  local b = set[math.random(#set)]
  for _, r in ipairs(recentBrushes) do
    if r == b then
      b = set[math.random(#set)]
      break
    end
  end
  recentBrushes[#recentBrushes + 1] = b
  if #recentBrushes > RECENT_BRUSH_MAX then table.remove(recentBrushes, 1) end
  return b
end

local function pickBrush()        return pickFromSet(IMPACT_BRUSHES)  end
local function pickStretchBrush() return pickFromSet(STRETCH_BRUSHES) end

-- Per-stamp tonal jitter. Brightness in [0.45, 0.85] with a 35% chance of a
-- faint warm push (exposed iron reads warmer than neutral grey). Returns r,g,b.
local function pickStampColor()
  local v = 0.45 + math.random() * 0.40
  if math.random() < 0.35 then
    return math.min(1, v + 0.04), v, math.max(0, v - 0.02)
  end
  return v, v, v
end

-- Wider scale wobble + per-brush bias. baseScale is the caller-supplied scale
-- (or stampAtLocal's default 0.10). Returns final scale.
local function pickStampScale(baseScale, brushPath)
  local wobble = 0.5 + math.random() * 1.2  -- 0.5..1.7
  local bias   = BRUSH_SCALE_BIAS[brushPath] or 1.0
  return baseScale * wobble * bias
end

-- Roughness jitter: keeps metallic=1 (polished steel) but mixes shinier and
-- duller scratches. Returns the per-stamp roughness intensity.
local function pickRoughness()
  return 0.10 + math.random() * 0.25
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

local function getSpawnAabb()
  local veh = getPlayerVehicle(0)
  if not veh then return nil end
  local ok, box = pcall(function() return veh:getSpawnLocalAABB() end)
  if not ok or not box or not box.minExtents or not box.maxExtents then return nil end
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

-- Vehicle-local entry point. Stamps a decal at `localPos` (vehicle-local
-- vec3) with surface aim along `localNormal` (vehicle-local vec3).
-- The world wrapper M.stampAt converts world -> local then calls this.
--
-- (F) This function does NO api calls and NO project — it just records a
-- raw input descriptor on pendingStampInputs and returns. flushPendingStamps
-- (per onUpdate) does the project/getDecalData/bake in a single shared-camera
-- batch. Costs that used to scale with N (project = N depth-pass renders
-- /frame) now scale with the cluster count instead — usually 1.
M.stampAtLocal = function(localPos, localNormal, opts)
  if not ready then log('W', logTag, "stampAtLocal: not ready"); return end
  if not resolveDecalProjection() then return end
  opts = opts or {}

  local veh = getPlayerVehicle(0)
  if not veh then return end

  -- Apply small positional jitter so repeated events at the same node don't
  -- perfectly stack into a single point. Body nodes have fixed body-relative
  -- positions, so without jitter a 1-second drag against a wall produces N
  -- stamps at exactly the same point; with jitter they spread into a small
  -- cluster that reads as scratch coverage.
  if not opts.noJitter then
    local jitter = 0.03  -- ±3 cm
    localPos = vec3(
      localPos.x + (math.random() - 0.5) * 2 * jitter,
      localPos.y + (math.random() - 0.5) * 2 * jitter,
      localPos.z + (math.random() - 0.5) * 2 * jitter)
  end

  -- Pick per-stamp style. opts overrides (used by probeBrushes / impact
  -- branch) win over the jitter helpers. No api state is set here — flush
  -- replays the style on each stamp's getDecalData call.
  local baseScale = opts.scale or 0.10
  local brush     = opts.colorTex or pickBrush()
  local scale     = opts.noJitter and baseScale or pickStampScale(baseScale, brush)
  local rot       = opts.rot or math.random() * 360.0
  local r, g, b
  if opts.r or opts.g or opts.b then
    r, g, b = opts.r or 0.7, opts.g or 0.7, opts.b or 0.7
  else
    r, g, b = pickStampColor()
  end
  local roughness = opts.skipMetal and 0.5 or pickRoughness()

  stampStats.stampsAttempted = stampStats.stampsAttempted + 1

  local jbeam = veh.JBeam or veh.jbeam
  if pendingStampsJBeam and pendingStampsJBeam ~= jbeam then
    pendingStampInputs = {}
  end
  pendingStampsJBeam = jbeam

  if #pendingStampInputs >= AGGREGATE_PER_FRAME_CAP then
    stampStats.aggregateDropped = stampStats.aggregateDropped + 1
    return nil
  end

  pendingStampInputs[#pendingStampInputs + 1] = {
    localPos    = localPos,
    localNormal = localNormal,
    brush       = brush,
    alpha       = opts.alphaTex or "/art/dynamicDecals/textures/_one.png",
    r = r, g = g, b = b,
    scale       = scale,
    rot         = rot,
    roughness   = roughness,
    skipMetal   = opts.skipMetal and true or false,
    dist        = opts.dist,
  }
  stampStats.stampsEnqueued = stampStats.stampsEnqueued + 1
  return nil  -- no synchronous decalData; flushed on next onUpdate
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
      if (dx*dx + dy*dy + dz*dz) < (CLUSTER_RADIUS * CLUSTER_RADIUS) then
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
        members = {s},
      }
    end
  end
  return clusters
end

-- Per-frame flush. Cluster pending inputs, project once per cluster, snapshot
-- per-stamp styled getDecalData under the shared cam, override cursor via
-- setDecalLocalPos, accumulate, single bake. The project count goes from N
-- (one per stamp) to K (one per cluster) — typically K=1 for slides.
local function flushPendingStamps()
  if #pendingStampInputs == 0 then return end
  if not resolveDecalProjection() then pendingStampInputs = {}; return end
  local jbeam = pendingStampsJBeam
  if not jbeam then pendingStampInputs = {}; return end

  -- UseMousePos must be OFF so projectDynamicDecals writes the cursor to the
  -- synth camera's screen-center instead of following the actual mouse.
  if api.isUseMousePos and api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
  end

  local projM    = getCameraProjMatrix()
  local clusters = buildClusters(pendingStampInputs)
  local bakeList = {}
  local skipped  = 0

  for _, cluster in ipairs(clusters) do
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
    local camLocal = buildSyntheticCameraLocal(centroid, averageNormals(cluster.members), clusterDist)
    -- ONE project pass for the whole cluster.
    setScratchProjectionFence(true)
    decalProjection:projectDynamicDecals(camLocal, projM)
    stampStats.projectsIssued = stampStats.projectsIssued + 1

    for _, s in ipairs(cluster.members) do
      -- Per-stamp style — getDecalData below snapshots api state into the layer.
      api.setDecalTexturePath("color", s.brush)
      api.setDecalTexturePath("alpha", s.alpha)
      if s.skipMetal then
        api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_zero.png")
        api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
        api.setMetallicIntensity(0)
        api.setRoughnessIntensity(0.5)
      else
        api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_one.png")
        api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
        api.setMetallicIntensity(1.0)
        api.setRoughnessIntensity(s.roughness)
      end
      api.setDecalColor(Point4F(s.r, s.g, s.b, 1))
      api.setDecalScale(vec3(s.scale, 1, s.scale))
      api.setDecalRotation(s.rot)
      api.setUseSurfaceNormal(true)

      local decalData = decalProjection:getDecalData(camLocal, projM)
      if decalData then
        -- Move the layer's cursor from the cluster centroid (where project
        -- placed it) to the actual stamp position. This recomputes
        -- cursorPosScreenUv and decalPos for s.localPos under the shared cam.
        api.setDecalLocalPos(decalData, s.localPos)

        -- Reject stamps whose projection lands outside the camera frustum
        -- (cursor outside [0,1]) — those would paint nothing or paint at the
        -- frustum edge incorrectly. Replaces the old (decalPos≈0, cursor≈0.5)
        -- check that no longer applies once setDecalLocalPos overrides cursor.
        local cuv = decalData.cursorPosScreenUv
        local outOfFrustum = not cuv
          or cuv.x < 0 or cuv.x > 1
          or cuv.y < 0 or cuv.y > 1
        if outOfFrustum then
          skipped = skipped + 1
        else
          decalData.uid       = string.format("scr-%08x", math.random(0, 0xffffffff))
          decalData.name      = "scratch"
          decalData.enabled   = true
          decalData.locked    = false
          decalData.parentUid = nil
          decalData.children  = {}
          bakeList[#bakeList + 1] = decalData
          M._lastDecal = decalData

          if stampVerbose then
            log('I', logTag, string.format(
              "stampAtLocal: input pos=(%.2f,%.2f,%.2f) | decalPos=(%.2f,%.2f,%.2f) cursor=(%.3f,%.3f) uid=%s",
              s.localPos.x, s.localPos.y, s.localPos.z,
              decalData.decalPos.x, decalData.decalPos.y, decalData.decalPos.z,
              cuv.x, cuv.y, decalData.uid))
          end
        end
      end
    end
    setScratchProjectionFence(false)
  end

  if skipped > 0 then
    stampStats.stampsSkippedMissed = stampStats.stampsSkippedMissed + skipped
  end
  if #bakeList > 0 then
    decalProjection:bakeLayers(bakeList, jbeam)
    stampStats.bakesIssued    = stampStats.bakesIssued + 1
    stampStats.framesFlushed  = stampStats.framesFlushed + 1
    stampStats.clustersTotal  = stampStats.clustersTotal + #clusters
  end
  pendingStampInputs = {}
end
flushPendingStampsRef = flushPendingStamps

-- World-space entry point. Detect.lua emits world coordinates; we convert to
-- vehicle-local here. The conversion mirrors app:getCameraM() in the api.
--
-- Third arg is either:
--   - a string 'kind' that GELUA expands into a stamp-style opts table
--     ('impact' currently — larger scale, dedicated brush). Lets the VLUA
--     bridge stay simple (no Lua-table serialization) while keeping the
--     visual style decision on the GE side.
--   - an opts table (legacy / direct callers) — passed through unchanged.
--   - nil — default slide-stamp style.
-- (G) Batched entry point. Detect.lua accumulates events on the VLUA side
-- per render frame and sends ONE queueGameEngineLua call per frame instead
-- of one per impact. `events` is a list of {x,y,z,nx,ny,nz,kind,sev}.
--   "i" — collision impact, world coords, sev = normalForce N
--   "s" — slide fallback, world coords, sev = normalForce N
-- sev drives synth-camera distance and stamp scale (I).
M.stampBatch = function(events)
  if not ready or not events then return end
  for i = 1, #events do
    local e = events[i]
    local kind = e[7]
    local sev  = e[8]
    M.stampAt(vec3(e[1], e[2], e[3]), vec3(e[4], e[5], e[6]),
              kind == "i" and "impact" or nil, sev)
  end
end

M.stampAt = function(worldPos, worldNormal, kindOrOpts, force)
  local veh = getPlayerVehicle(0)
  if not veh then log('W', logTag, "stampAt: no player vehicle"); return end

  local refM    = veh:getRefNodeMatrix()
  local invM    = refM:fullInverse()
  local rotOnly = invM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))

  local localPos    = invM:mulP3F(worldPos)
  local localNormal = rotOnly:mulP3F(worldNormal)

  local opts
  if type(kindOrOpts) == "string" then
    if kindOrOpts == "impact" then
      -- Impact stamps stay distinct from slide stamps via the larger scale;
      -- brush picked from IMPACT_BRUSHES (chip/claw/tbone). (I) Scale and
      -- camera distance both grow with the impact's normalForce so heavy
      -- crunches leave a bigger, more-grazing-angle mark instead of dying
      -- in the deformed cavity.
      local f = force or 0
      local heavy = math.min(1, math.max(0, (f - 800) / 20000))  -- 0..1 over 0.8-20.8 kN
      opts = {
        scale    = 0.28 + heavy * 0.35,                        -- 0.28..0.63m
        dist     = 0.7  + heavy * 1.6,                         -- 0.7..2.3m
        colorTex = pickBrush(),
      }
    end
  elseif type(kindOrOpts) == "table" then
    opts = kindOrOpts
  end

  -- For 1-point slide fallbacks, also widen the synth cam distance with
  -- force. We don't have a kindOrOpts string for these — pickup directly.
  if not opts and force and force > 800 then
    local heavy = math.min(1, math.max(0, (force - 800) / 20000))
    opts = { dist = 0.7 + heavy * 1.6, scale = 0.14 + heavy * 0.10 }
  end

  return M.stampAtLocal(localPos, localNormal, opts)
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

-- Continuous-slide entry point. detect.lua collects (worldPos, worldNormal)
-- samples for each contacting body node and flushes them here as a batch
-- when the slide ends (or at MAX_DURATION).
--
-- (H/N) Each stream becomes short stretched decals along the slide direction
-- instead of N interpolated brushStroke decals. The path is first split by
-- curvature, then any long straight section is chopped by length so one roof
-- slide cannot stamp a giant rectangle across roof/rear/side at once.
-- Brushes come from STRETCH_BRUSHES (streak_*) only — the impact splatter
-- shapes don't tile cleanly when stretched at high aspect ratios.
--
-- Geometry: same single-camera trick as before. Centroid of all segment
-- centers gets a synthetic hull-face camera. One projectDynamicDecals.
-- Per segment: set per-segment style → getDecalData (snapshots into a fresh
-- layer) → setDecalLocalPos to position cursor at segment center. One bake.
M.stampStream = function(points)
  if not ready then log('W', logTag, "stampStream: not ready"); return end
  if not resolveDecalProjection() then return end
  if not points or #points < 2 then
    log('W', logTag, string.format("stampStream: need >=2 points, got %d",
      points and #points or 0))
    return
  end

  local veh = getPlayerVehicle(0)
  if not veh then return end
  local refM = veh:getRefNodeMatrix()
  local invM = refM:fullInverse()
  local rotOnly = invM:copy(); rotOnly:setColumn(3, vec3(0, 0, 0))

  -- World -> vehicle-local
  local n = #points
  local localPos = {}
  local localNormals = {}
  for i = 1, n do
    local p = points[i]
    localPos[i] = invM:mulP3F(vec3(p[1], p[2], p[3]))
    if p[4] and p[5] and p[6] then
      localNormals[i] = rotOnly:mulP3F(vec3(p[4], p[5], p[6]))
    end
  end

  -- Curvature analysis + length chunking. Curvature catches bends; length
  -- chunking keeps straight roof slides local and visibly denser.
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
        width  = 0.10 + math.random() * 0.12,  -- 0.10m..0.22m
      }
    end
  end

  if #segments == 0 then return end

  -- Centroid of segment centers for the shared camera
  local cx, cy, cz = 0, 0, 0
  for _, s in ipairs(segments) do
    cx = cx + s.center.x; cy = cy + s.center.y; cz = cz + s.center.z
  end
  local centroidLocal = vec3(cx / #segments, cy / #segments, cz / #segments)
  local normalSamples = {}
  for _, ln in ipairs(localNormals) do
    normalSamples[#normalSamples + 1] = {localNormal = ln}
  end
  local camLocal = buildSyntheticCameraLocal(centroidLocal, averageNormals(normalSamples), nil)
  local projM    = getCameraProjMatrix()

  if api.isUseMousePos and api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
  end

  -- One project for the whole stream.
  setScratchProjectionFence(true)
  decalProjection:projectDynamicDecals(camLocal, projM)

  -- Helper layer used only to compute screen-UV for start/end points (cheap;
  -- we mutate cursor and read it back without baking). Does NOT enter the
  -- bake list — we get a fresh styled layer per segment below.
  local probe = decalProjection:getDecalData(camLocal, projM)
  if not probe then
    setScratchProjectionFence(false)
    log('W', logTag, "stampStream: getDecalData returned nil")
    return
  end

  local bakeList = {}
  for si, seg in ipairs(segments) do
    -- Project segment's start and end to screen UV via the probe so we can
    -- compute the angle that aligns the decal's long axis with travel.
    api.setDecalLocalPos(probe, seg.startP)
    local sUx, sUy = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
    api.setDecalLocalPos(probe, seg.endP)
    local eUx, eUy = probe.cursorPosScreenUv.x, probe.cursorPosScreenUv.y
    local uvDx, uvDy = eUx - sUx, eUy - sUy
    local segAngle = (math.abs(uvDx) + math.abs(uvDy)) > 1e-5
      and math.atan2(uvDy, uvDx)
      or  (math.random() * 2 * math.pi)

    -- Per-segment style (captured into the layer by getDecalData below).
    local segR, segG, segB = pickStampColor()
    api.setDecalTexturePath("color", pickStretchBrush())
    api.setDecalTexturePath("alpha", "/art/dynamicDecals/textures/_one.png")
    api.setDecalTexturePath("metallic",  "/art/dynamicDecals/textures/_one.png")
    api.setDecalTexturePath("roughness", "/art/dynamicDecals/textures/_one.png")
    api.setMetallicIntensity(1.0)
    api.setRoughnessIntensity(pickRoughness())
    api.setDecalColor(Point4F(segR, segG, segB, 1))
    -- Asymmetric scale: long along travel, thin across. Both are half-sizes.
    api.setDecalScale(vec3(seg.length * 0.5, 1, seg.width * 0.5))
    api.setDecalRotation(segAngle)
    api.setUseSurfaceNormal(true)

    local segLayer = decalProjection:getDecalData(camLocal, projM)
    if segLayer then
      api.setDecalLocalPos(segLayer, seg.center)
      -- Frustum sanity (out-of-frustum stamps wouldn't paint correctly).
      local cuv = segLayer.cursorPosScreenUv
      if cuv and cuv.x >= 0 and cuv.x <= 1 and cuv.y >= 0 and cuv.y <= 1 then
        segLayer.uid       = string.format("scr-%08x", math.random(0, 0xffffffff))
        segLayer.name      = string.format("scrape-segment-%d", si)
        segLayer.enabled   = true
        segLayer.locked    = false
        segLayer.parentUid = nil
        segLayer.children  = {}
        bakeList[#bakeList + 1] = segLayer
      end
    end
  end
  setScratchProjectionFence(false)

  if #bakeList == 0 then return end

  decalProjection:bakeLayers(bakeList, veh.JBeam or veh.jbeam)
  M._lastDecal = bakeList[#bakeList]
  stampStats.streamsBaked          = stampStats.streamsBaked + 1
  stampStats.streamSubstrokesTotal = stampStats.streamSubstrokesTotal + #bakeList
  if stampVerbose then
    log('I', logTag, string.format(
      "stampStream: n=%d -> %d stretched segments (totalTurn~analyzed)",
      n, #bakeList))
  end
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
    {tex = "/art/dynamicDecals/textures/shape_circle.png",            rgb = {1.0, 0.0, 0.0}, name = "vanilla shape_circle (RED)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_01.png",       rgb = {0.0, 1.0, 0.0}, name = "streak_01 (GREEN)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_02.png",       rgb = {0.0, 1.0, 1.0}, name = "streak_02 (CYAN)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_03.png",       rgb = {1.0, 1.0, 0.0}, name = "streak_03 (YELLOW)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_05.png",       rgb = {1.0, 0.0, 1.0}, name = "streak_05 clean (MAGENTA)"},
    {tex = "/art/dynamicDecals/textures/scratch_chip_cluster.png",    rgb = {0.5, 1.0, 0.5}, name = "chip_cluster (LIGHT GREEN)"},
    {tex = "/art/dynamicDecals/textures/scratch_tbone.png",           rgb = {0.5, 0.5, 1.0}, name = "tbone (LIGHT BLUE)"},
    {tex = "/art/dynamicDecals/textures/scratch_raptor_claw_01.png",  rgb = {1.0, 0.5, 0.0}, name = "raptor_claw_01 (ORANGE)"},
    {tex = "/art/dynamicDecals/textures/scratch_raptor_claw_02.png",  rgb = {1.0, 0.0, 0.5}, name = "raptor_claw_02 (PINK)"},
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
  pendingStampsJBeam = nil
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
  log('I', logTag, "cleared all stamps (textures flushed); layers before clear=" ..
    tostring(preClearLayers))
  -- Re-seed the metallic/roughness baseline. After flush every channel is
  -- zero — without re-seeding the body would render perfectly matte (or
  -- chrome, depending on the variant defaults) regardless of paint config.
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
  AGGREGATE_PER_FRAME_CAP = math.max(1, math.floor(tonumber(n) or 96))
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
  log('I', logTag, string.format("queueLen now           = %d", #pendingStampInputs))
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
  log('I', logTag, "paint stats reset")
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
  aggCap     = 96,
  clusterRad = 0.65,
  paintMet   = 0.00,
  paintRou   = 0.20,
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
    aggCap = 16,  clusterRad = 1.3,
    desc = "Subtle. Only fast slides + solid hits leave marks.\n" ..
           "Easy on hardware. Realistic 'careful driver' look." },
  { name = "Default",
    slip = 0.6,  paintCool = 0.003,
    impForce = 800, impCool = 0.025,
    aggCap = 96,  clusterRad = 0.65,
    desc = "Aggressive 10x damage. Long slides build dense scratches;\n" ..
           "light smashes leave visible chip/claw marks." },
  { name = "Heavy",
    slip = 0.45,  paintCool = 0.0025,
    impForce = 650, impCool = 0.020,
    aggCap = 112,  clusterRad = 0.55,
    desc = "Very aggressive. More contact noise turns into visible wear;\n" ..
           "use when the scene should look heavily abused." },
  { name = "Max",
    slip = 0.35,  paintCool = 0.002,
    impForce = 500, impCool = 0.015,
    aggCap = 128,  clusterRad = 0.45,
    desc = "Every drag, bump, and dent leaves a mark.\n" ..
           "Banged-up look after one good roll.\n" ..
           "Notable CPU+GPU cost; should still hold steady framerate." },
  { name = "Extreme",
    slip = 0.25,  paintCool = 0.0015,
    impForce = 350,  impCool = 0.010,
    aggCap = 160,  clusterRad = 0.35,
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
    paintMet   = im.FloatPtr(PAINT_METALLIC),
    paintRou   = im.FloatPtr(PAINT_ROUGHNESS),
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
  uiPtrs.paintMet[0]   = PAINT_METALLIC
  uiPtrs.paintRou[0]   = PAINT_ROUGHNESS
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
  AGGREGATE_PER_FRAME_CAP = preset.aggCap
  CLUSTER_RADIUS          = preset.clusterRad
  sendVehicleCmd(string.format("scratches_detect.setThresholds(%.3f, nil, nil)",
    preset.slip))
  sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)",
    preset.paintCool))
  sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, %.3f)",
    preset.impForce, preset.impCool))
  log('I', logTag, string.format("preset applied: %s (slip=%.2f cool=%.4f force=%.0f impCool=%.2f cap=%d radius=%.2f)",
    preset.name, preset.slip, preset.paintCool, preset.impForce, preset.impCool,
    preset.aggCap, preset.clusterRad))
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
  w(string.format("- aggregateCap=%d clusterRadius=%.2f metallic=%.2f roughness=%.2f",
    AGGREGATE_PER_FRAME_CAP, CLUSTER_RADIUS, PAINT_METALLIC, PAINT_ROUGHNESS))
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
    "Average depth-pass renders per frame (each is a real GPU cost).\n" ..
    "Pre-clustering this would equal the stamp count per frame.\n" ..
    "After clustering: usually near 1.0; a higher number means stamps are\n" ..
    "spreading across the body and forcing multiple cameras.")

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
    "Default: 32.\n" ..
    "Performance: each frame composites this many layers in one pass.")

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
  im.Text("--- Paint canvas (PBR seed) ---  (re-bake on slider release)")
  -- (1.5) These controls re-bake the canvas, which needs a bound projection.
  -- Grey them out (with a reason) instead of letting clicks silently no-op
  -- while the painter is still setting up.
  if not ready then
    im.TextDisabled("painter not ready - these controls are inactive")
  end
  im.BeginDisabled(not ready)
  -- Paint-color seed. On by default: the clear/reset wipe (clearBakedTextures)
  -- zeroes the baseColor channel, so the seed must restore the vehicle's paint
  -- color or the body goes black. Liveried cars are skipped entirely, so
  -- there's no livery at risk. Reseeds immediately on change.
  if im.Checkbox("Seed paint color", uiPtrs.paintColor) then
    PAINT_SEED_COLOR = uiPtrs.paintColor[0]
    M.clearStamps()
  end
  uiTooltip(
    "Writes the vehicle's chosen paint color into the canvas baseColor.\n" ..
    "Keep this ON: the clear/reset wipe zeroes baseColor, and without the\n" ..
    "color seed the body renders black. Off is debug-only.")
  -- Live-update PAINT_METALLIC while dragging so the slider feels responsive,
  -- but only call clearStamps (which re-seeds) on release — that's a 6-bake
  -- operation and we don't want to thrash it every frame of a drag.
  if im.SliderFloat("Paint metallic", uiPtrs.paintMet, 0.0, 1.0, "%.2f") then
    PAINT_METALLIC = uiPtrs.paintMet[0]
  end
  if im.IsItemDeactivatedAfterEdit and im.IsItemDeactivatedAfterEdit() then
    M.clearStamps()
  end
  uiTooltip(
    "Metallic value the canvas seed writes to @DynamicTextureMetallic.\n" ..
    "0 = dielectric paint (default), 1 = bare polished metal.\n" ..
    "Most car paints are dielectric — keep at 0 unless you want a chrome look.\n" ..
    "Default: 0.00.\n" ..
    "Note: re-seeding wipes existing scratches; happens on slider release.")

  if im.SliderFloat("Paint roughness", uiPtrs.paintRou, 0.0, 1.0, "%.2f") then
    PAINT_ROUGHNESS = uiPtrs.paintRou[0]
  end
  if im.IsItemDeactivatedAfterEdit and im.IsItemDeactivatedAfterEdit() then
    M.clearStamps()
  end
  uiTooltip(
    "Roughness value the canvas seed writes to @DynamicTextureRoughness.\n" ..
    "0 = mirror (sharp specular), 1 = matte (no specular).\n" ..
    "Glossy clearcoat paint is around 0.15-0.25; satin around 0.4-0.6.\n" ..
    "Default: 0.20.\n" ..
    "Note: re-seeding wipes existing scratches; happens on slider release.")
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
    uiPtrs.paintMet[0]   = UI_DEFAULTS.paintMet
    uiPtrs.paintRou[0]   = UI_DEFAULTS.paintRou
    uiPtrs.paintColor[0] = UI_DEFAULTS.paintColor
    AGGREGATE_PER_FRAME_CAP = UI_DEFAULTS.aggCap
    CLUSTER_RADIUS          = UI_DEFAULTS.clusterRad
    PAINT_METALLIC          = UI_DEFAULTS.paintMet
    PAINT_ROUGHNESS         = UI_DEFAULTS.paintRou
    PAINT_SEED_COLOR        = UI_DEFAULTS.paintColor
    sendVehicleCmd(string.format("scratches_detect.setThresholds(%.3f, nil, nil)", UI_DEFAULTS.slip))
    sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)", UI_DEFAULTS.paintCool))
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, %.3f)", UI_DEFAULTS.impForce, UI_DEFAULTS.impCool))
    M.clearStamps()  -- re-seed canvas with the restored M/R values
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
            "Disabled until the painter is ready. Keyboard equivalent: Ctrl+L.")

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
  log('I', logTag, "loaded. probes: scratches_paint.{dumpState,kickSetup,testStamp,testStampAt,testStampAtWorld,probeBrushes,stampAt,stampAtLocal,stampStream,stampBatch,clearStamps,addPaintFill,dumpDecalConfig,drawTextures,setStampVerbose,setAggregateCap,setClusterRadius,dumpPaintStats,resetPaintStats,toggleUI,buildDebugReport}")
  pendingSetup = true
  setupAttemptTimer = SETUP_RETRY  -- try immediately
  trySetup()
end

local function onExtensionUnloaded()
  ready = false
  api = nil
  lastSkinJBeam = nil
  log('I', logTag, "unloaded")
end

M.onExtensionLoaded   = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onUpdate            = onUpdate
M.onVehicleSwitched   = onVehicleSwitched
M.onVehicleSpawned    = onVehicleSpawned

return M
