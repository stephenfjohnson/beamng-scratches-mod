-- scratches_mod / paint.lua  (GELUA)
-- Game-engine-side painter. Owns the Dynamic Decals projection per player vehicle.
-- Phase 2 scaffold: load editor_api_dynamicDecals, auto-set the dynamicTextures
-- skin on supported vehicles, drive the per-frame onUpdate. Test stamp probe
-- (M.testStamp) is left as a stub for the next sub-step.

local M = {}

local logTag = "scratches.paint"

-- ---- state ----
local api               = nil    -- editor_api_dynamicDecals module
local ready             = false  -- decals projection bound, skin set, ready to bake
local pendingSetup      = false  -- want setup but haven't succeeded yet
local setupAttemptTimer = 0      -- seconds since last attempt
local SETUP_RETRY       = 1.0    -- seconds between retry attempts
local lastSkinJBeam     = nil    -- last vehicle jbeam we successfully set skin on

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
local AGGREGATE_PER_FRAME_CAP = 32 -- hard cap per frame; further enqueues drop
-- Greedy spatial-cluster radius (vehicle-local meters). Stamps within this
-- distance share a project camera. Bigger = fewer clusters = fewer projects;
-- too big and the shared cam can land on the wrong panel for off-axis stamps.
-- 1.5m comfortably covers a single-panel slide; multi-panel rolls partition.
local CLUSTER_RADIUS         = 1.5

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
  -- Idempotent: setSkin no-ops if already selected
  extensions.core_vehicle_partmgmt.setSkin("dynamicTextures")
  if lastSkinJBeam ~= jbeam then
    log('I', logTag, "set skin 'dynamicTextures' on vehicle " .. jbeam)
    lastSkinJBeam = jbeam
  end
  return true
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

  -- Seed @DynamicTextureBaseColor with the vehicle's actual paint color so
  -- the body doesn't render black after the dynamic-textures skin activates.
  -- Without this, Stage 1 of the materials.json reads from an empty dynamic
  -- texture (default 0,0,0) and the vehicle goes solid black wherever the
  -- skin's opacityMap covers it.
  M.addPaintFill()
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

-- Bake a fill layer at the bottom of the layer stack with the player vehicle's
-- current paint color. Direct-bake (same pattern as our scratch stamps) — we
-- do not use api.addFillLayer because it goes through history machinery and
-- doesn't accept an explicit color in params.
M.addPaintFill = function()
  if not ready then log('W', logTag, "addPaintFill: not ready"); return end
  if not resolveDecalProjection() then return end
  local veh = getPlayerVehicle(0)
  if not veh then return end

  local r, g, b = parseVehicleColor(getVehicleColor and getVehicleColor() or nil)
  if not r then
    -- Fallback: a neutral mid-grey so the body isn't black even if we can't
    -- resolve the actual paint. The user can call M.addPaintFill() again
    -- manually after the vehicle finishes initializing.
    r, g, b = 0.5, 0.5, 0.5
    log('W', logTag, "addPaintFill: getVehicleColor unavailable; using mid-grey fallback")
  end

  local fillData = {
    name              = "scratches_base_paint",
    uid               = string.format("scr-fill-%08x", math.random(0, 0xffffffff)),
    type              = api.layerTypes.fill,
    blendMode         = 0,  -- Normal
    color             = Point4F(r, g, b, 1),
    colorPaletteMapId = 0,
    enabled           = true,
    locked            = false,
    parentUid         = nil,
    children          = {},
  }
  decalProjection:bakeLayers({fillData}, veh.JBeam or veh.jbeam)
  log('I', logTag, string.format("paint fill: rgb=(%.2f,%.2f,%.2f) uid=%s", r, g, b, fillData.uid))
end

-- ---- per-frame ----
-- Forward declarations so onUpdate can call them; the function bodies are
-- defined further down (alongside stampAtLocal for flushPendingStamps;
-- alongside the K probes for drawUI).
local flushPendingStampsRef
local drawUIRef

local function onUpdate(dtReal, dtSim, dtRaw)
  if ready then
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

-- Build a 4x4 camera transform (camera -> vehicle-local) for a synthetic
-- view that's OUTSIDE the body at `localPos` looking IN along the radial
-- direction. The contact normal arg is ignored: in practice it's unreliable
-- (internal panel-on-panel collisions during deformation point in random
-- directions, putting the synth camera inside the body and projecting the
-- decal onto the opposite side). The radial direction
-- `(localPos - origin):normalized()` always puts the camera outside the
-- body's outer hull looking in, regardless of contact geometry.
-- BeamNG/Torque convention: col0=right(+X), col1=forward(+Y), col2=up(+Z),
-- col3=position. (Verified in lua/ge/spawn.lua lines 98-101.)
local function buildSyntheticCameraLocal(localPos, _localNormal_unused, dist)
  dist = dist or 0.5
  local outward = localPos:normalized()
  if outward:length() < 1e-3 then outward = vec3(0, 0, 1) end

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
    local camLocal = buildSyntheticCameraLocal(centroid, nil, clusterDist)
    -- ONE project pass for the whole cluster.
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
--   "d" — (J) deformation event, vehicle-local coords, sev = magnitude m
-- sev drives synth-camera distance and stamp scale (I).
M.stampBatch = function(events)
  if not ready or not events then return end
  for i = 1, #events do
    local e = events[i]
    local kind = e[7]
    local sev  = e[8]

    if kind == "d" then
      -- (J) Deformation event — coords already vehicle-local, skip the
      -- world->local conversion stampAt would do. severity is meters of
      -- displacement; bigger displacement gets a larger, further-camera
      -- stamp so dramatic crumpling reads as dramatic damage.
      --
      -- (L) Use STRETCH_BRUSHES with a forward-aligned rotation so deform
      -- stamps on slide-active panels reinforce the slide direction instead
      -- of breaking it up with non-directional starbursts. The synth camera
      -- (buildSyntheticCameraLocal) puts vehicle-forward on screen-X for
      -- side panels and on screen-back-X for roof/floor — both symmetric
      -- under streak rotation — so rot ≈ 0 ± jitter draws forward/back
      -- scrape lines on those panels. Front/rear bumpers get cross-car
      -- streaks under this rule, which is a small fraction of events.
      local heavy = math.min(1, math.max(0, ((sev or 0) - 0.04) / 0.16))
      M.stampAtLocal(vec3(e[1], e[2], e[3]), vec3(e[4], e[5], e[6]), {
        scale    = 0.20 + heavy * 0.20,                       -- 0.20m..0.40m
        dist     = 0.5  + heavy * 1.5,                        -- 0.5m..2.0m
        colorTex = pickStretchBrush(),                        -- streak_*
        rot      = (math.random() - 0.5) * math.rad(40),      -- ±20° around forward
      })
    else
      M.stampAt(vec3(e[1], e[2], e[3]), vec3(e[4], e[5], e[6]),
                kind == "i" and "impact" or nil, sev)
    end
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
      local heavy = math.min(1, math.max(0, (f - 3000) / 30000))  -- 0..1 over 3-33 kN
      opts = {
        scale    = 0.18 + heavy * 0.15,                        -- 0.18..0.33m
        dist     = 0.5  + heavy * 1.5,                         -- 0.5..2.0m
        colorTex = pickBrush(),
      }
    end
  elseif type(kindOrOpts) == "table" then
    opts = kindOrOpts
  end

  -- For 1-point slide fallbacks, also widen the synth cam distance with
  -- force. We don't have a kindOrOpts string for these — pickup directly.
  if not opts and force and force > 3000 then
    local heavy = math.min(1, math.max(0, (force - 3000) / 30000))
    opts = { dist = 0.5 + heavy * 1.5 }
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

-- Continuous-slide entry point. detect.lua collects (worldPos, worldNormal)
-- samples for each contacting body node and flushes them here as a batch
-- when the slide ends (or at MAX_DURATION).
--
-- (H) Each stream becomes 1-3 stretched decals along the slide direction
-- instead of N interpolated brushStroke decals. The path is split by
-- curvature: straight slides → 1 elongated decal; curving slides → 2-3
-- shorter ones at the highest-turn points. Brushes come from STRETCH_BRUSHES
-- (streak_*) only — the impact splatter shapes don't tile cleanly when
-- stretched at high aspect ratios.
--
-- Geometry: same single-camera trick as before. Centroid of all segment
-- centers gets a synthetic radial-outward camera. One projectDynamicDecals.
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

  -- World -> vehicle-local
  local n = #points
  local localPos = {}
  for i = 1, n do
    local p = points[i]
    localPos[i] = invM:mulP3F(vec3(p[1], p[2], p[3]))
  end

  -- Curvature analysis -> 1/2/3 segments
  local rawSegments = buildStretchSegments(localPos)

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
        width  = 0.06 + math.random() * 0.12,  -- 0.06m..0.18m
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
  local camLocal = buildSyntheticCameraLocal(centroidLocal, nil, nil)
  local projM    = getCameraProjMatrix()

  if api.isUseMousePos and api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
  end

  -- One project for the whole stream.
  decalProjection:projectDynamicDecals(camLocal, projM)

  -- Helper layer used only to compute screen-UV for start/end points (cheap;
  -- we mutate cursor and read it back without baking). Does NOT enter the
  -- bake list — we get a fresh styled layer per segment below.
  local probe = decalProjection:getDecalData(camLocal, projM)
  if not probe then log('W', logTag, "stampStream: getDecalData returned nil"); return end

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
-- re-seed the paint fill so the vehicle's color is preserved instead of
-- going back to default-black.
M.clearStamps = function()
  if not ready then log('W', logTag, "clearStamps: not ready"); return end
  if not api or not api.clearLayerStack then log('W', logTag, "api.clearLayerStack unavailable"); return end
  -- Drop any pending stamps before clearing — otherwise the next onUpdate
  -- flushes them into the freshly-cleared layer stack and the wipe is
  -- partially undone.
  pendingStampInputs = {}
  pendingStampsJBeam = nil
  api.clearLayerStack()
  log('I', logTag, "cleared all stamps (layers=" .. tostring(api.getLayerCount and api.getLayerCount()) .. ")")
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
  end

  -- API state
  log('I', logTag, "api.ready = " .. tostring(api.ready))
  log('I', logTag, "api.projectDynamicDecals = " .. tostring(api.projectDynamicDecals))
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
  AGGREGATE_PER_FRAME_CAP = math.max(1, math.floor(tonumber(n) or 24))
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
  CLUSTER_RADIUS = math.max(0.1, tonumber(meters) or 1.5)
  log('I', logTag, string.format("CLUSTER_RADIUS = %.2fm", CLUSTER_RADIUS))
end

-- ---- (K) IMGUI debug + tuning panel ----

-- Canonical default values for every tunable the panel exposes. The Reset
-- Defaults button writes these back into the slider pointers and pushes
-- them to the VLUA side. Keep in sync with the matching constants in
-- scratches_detect.lua and the AGGREGATE_PER_FRAME_CAP / CLUSTER_RADIUS
-- definitions further up this file.
local UI_DEFAULTS = {
  slip       = 1.5,
  paintCool  = 0.015,
  impForce   = 3000,
  impCool    = 0.25,
  defT1      = 0.04,
  defT2      = 0.10,
  defT3      = 0.20,
  aggCap     = 32,
  clusterRad = 1.5,
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
    defT1 = 0.08, defT2 = 0.18, defT3 = 0.30,
    aggCap = 16,  clusterRad = 2.0,
    desc = "Subtle. Only fast slides + solid hits leave marks.\n" ..
           "Easy on hardware. Realistic 'careful driver' look." },
  { name = "Default",
    slip = 1.5,  paintCool = 0.015,
    impForce = 3000, impCool = 0.25,
    defT1 = 0.04, defT2 = 0.10, defT3 = 0.20,
    aggCap = 32,  clusterRad = 1.5,
    desc = "Sensible defaults. Realistic damage from real crashes;\n" ..
           "balanced sensitivity, balanced cost." },
  { name = "Heavy",
    slip = 0.9,  paintCool = 0.012,
    impForce = 1800, impCool = 0.18,
    defT1 = 0.025, defT2 = 0.07, defT3 = 0.14,
    aggCap = 44,  clusterRad = 1.3,
    desc = "More sensitive. Light contacts register; cars accumulate\n" ..
           "visible wear faster. Modest cost increase." },
  { name = "Max",
    slip = 0.6,  paintCool = 0.008,
    impForce = 1200, impCool = 0.10,
    defT1 = 0.015, defT2 = 0.05, defT3 = 0.10,
    aggCap = 56,  clusterRad = 1.0,
    desc = "Every drag, bump, and dent leaves a mark.\n" ..
           "Banged-up look after one good roll.\n" ..
           "Notable CPU+GPU cost; should still hold steady framerate." },
  { name = "Extreme",
    slip = 0.5,  paintCool = 0.005,
    impForce = 800,  impCool = 0.05,
    defT1 = 0.010, defT2 = 0.04, defT3 = 0.08,
    aggCap = 64,  clusterRad = 0.7,
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
-- the slide/impact/deform ones to whatever the VLUA side actually has.
local function ensureUIPointers()
  if uiPtrs then return true end
  local im = ui_imgui
  if not im then return false end
  uiPtrs = {
    slip       = im.FloatPtr(1.5),
    paintCool  = im.FloatPtr(0.015),
    impForce   = im.FloatPtr(3000),
    impCool    = im.FloatPtr(0.25),
    defT1      = im.FloatPtr(0.04),
    defT2      = im.FloatPtr(0.10),
    defT3      = im.FloatPtr(0.20),
    aggCap     = im.IntPtr(AGGREGATE_PER_FRAME_CAP),
    clusterRad = im.FloatPtr(CLUSTER_RADIUS),
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
  if lastDetectStats.defT1     then uiPtrs.defT1[0]     = lastDetectStats.defT1 end
  if lastDetectStats.defT2     then uiPtrs.defT2[0]     = lastDetectStats.defT2 end
  if lastDetectStats.defT3     then uiPtrs.defT3[0]     = lastDetectStats.defT3 end
  uiPtrs.aggCap[0]     = AGGREGATE_PER_FRAME_CAP
  uiPtrs.clusterRad[0] = CLUSTER_RADIUS
end

-- Send a tuning command back to the player vehicle's VLUA. detect.lua
-- exposes setThresholds / setImpactParams / setDeformTiers / setPaintCooldown.
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
  uiPtrs.defT1[0]      = preset.defT1
  uiPtrs.defT2[0]      = preset.defT2
  uiPtrs.defT3[0]      = preset.defT3
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
  sendVehicleCmd(string.format("scratches_detect.setDeformTiers(%.4f, %.4f, %.4f)",
    preset.defT1, preset.defT2, preset.defT3))
  log('I', logTag, string.format("preset applied: %s (slip=%.2f cool=%.4f force=%.0f impCool=%.2f tiers=%.3f/%.3f/%.3f cap=%d radius=%.2f)",
    preset.name, preset.slip, preset.paintCool, preset.impForce, preset.impCool,
    preset.defT1, preset.defT2, preset.defT3, preset.aggCap, preset.clusterRad))
end

-- Live debug + tuning panel. Two columns of read-only counters at the top,
-- then grouped slider sections for slide / impact / deformation tunables,
-- then action buttons. Sliders with visible value labels via SliderFloat.
local function drawUI()
  if not uiVisible then return end
  local im = ui_imgui
  if not im then return end
  if not ensureUIPointers() then return end
  syncUIPointersFromSnapshot()

  -- The window's close button writes to uiClosePtr[0]; mirror to uiVisible.
  uiClosePtr[0] = true
  if not im.Begin("Scratches Debug", uiClosePtr, 0) then
    im.End()
    if not uiClosePtr[0] then uiVisible = false end
    return
  end
  if not uiClosePtr[0] then uiVisible = false end

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

  im.Text(string.format("Deformation events:   %d  (%d skin nodes)",
    lastDetectStats.deformEvents or 0, lastDetectStats.skinNodes or 0))
  uiTooltip(
    "Body-skin nodes that crossed a deformation tier.\n" ..
    "Catches damage where the skin moved without itself touching ground\n" ..
    "(internal frame transferring force, sustained crush, etc.).\n" ..
    "Each skin node fires up to 3 times across a session (one per tier).")

  im.Text(string.format("Streams baked:        %d",
    stampStats.streamsBaked))
  uiTooltip(
    "Slide events committed as stretched-decal scrape marks.\n" ..
    "Each stream becomes 1-3 elongated decals depending on path curvature.\n" ..
    "Cheap — one bake per stream, regardless of sample count.")

  im.Text(string.format("Discrete stamps:      %d (queued) / %d (skipped)",
    stampStats.stampsEnqueued, stampStats.stampsSkippedMissed))
  uiTooltip(
    "Impact + deformation + 1-point-fallback stamps reaching the GE bake queue.\n" ..
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
    "After clustering: usually 1.0-1.5; a higher number means stamps are\n" ..
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
    "Default: 1.50 m/s.\n" ..
    "Performance: lower bumps stream count; cheap thanks to stretched decals.")

  if im.SliderFloat("Sample period (s)", uiPtrs.paintCool, 0.005, 0.10, "%.3f") then
    sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)", uiPtrs.paintCool[0]))
  end
  uiTooltip(
    "How often a sliding node contributes a sample to its active stream.\n" ..
    "LOWER -> denser sample chains, longer streams (rich curve detection).\n" ..
    "HIGHER -> chunkier sampling, lighter CPU cost per slide.\n" ..
    "Default: 0.015 s (~66 samples/second per node).\n" ..
    "Performance: every 30 samples force-flushes a stream; lower = more flushes.")

  im.Separator()
  im.Text("--- Impact marks ---")
  if im.SliderFloat("Force threshold (N)", uiPtrs.impForce, 500, 10000, "%.0f") then
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, nil)", uiPtrs.impForce[0]))
  end
  uiTooltip(
    "Minimum normalForce (newtons) for a contact to fire as an IMPACT stamp.\n" ..
    "LOWER -> light bumps register (door dings, curb rubs).\n" ..
    "HIGHER -> only solid hits leave a mark.\n" ..
    "Default: 3000 N.\n" ..
    "Performance: every impact joins the per-frame bake; cap=Aggregate cap.")

  if im.SliderFloat("Cooldown (s)", uiPtrs.impCool, 0.05, 1.5, "%.2f") then
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(nil, %.3f)", uiPtrs.impCool[0]))
  end
  uiTooltip(
    "Minimum seconds between impact stamps on the SAME node.\n" ..
    "LOWER -> sustained collisions leave tighter mark sequences.\n" ..
    "HIGHER -> a single mark per period even if hammering continues.\n" ..
    "Default: 0.25 s.\n" ..
    "Performance: lower = potentially many more impact stamps per crash.")

  im.Separator()
  im.Text("--- Deformation tiers (m) ---")
  local tierChanged = false
  if im.SliderFloat("Tier 1 (light)", uiPtrs.defT1, 0.01, 0.20, "%.3f") then tierChanged = true end
  uiTooltip(
    "Skin-deformation magnitude that fires the first stamp on a node.\n" ..
    "LOWER -> minor dings show up.\n" ..
    "HIGHER -> only real dents leave marks.\n" ..
    "Default: 0.040 m (4 cm).")

  if im.SliderFloat("Tier 2 (mod.) ", uiPtrs.defT2, 0.05, 0.40, "%.3f") then tierChanged = true end
  uiTooltip(
    "Second tier — fires a second stamp on the same node when deformation\n" ..
    "reaches this magnitude.\n" ..
    "Default: 0.100 m (10 cm).")

  if im.SliderFloat("Tier 3 (heavy)", uiPtrs.defT3, 0.10, 0.60, "%.3f") then tierChanged = true end
  uiTooltip(
    "Third tier — final stamp per node, fires on heavy crumpling.\n" ..
    "Default: 0.200 m (20 cm).\n" ..
    "Each skin node fires at most #tiers times across the session.\n" ..
    "Performance: deform scan is round-robin (12 nodes/frame); cost is\n" ..
    "fixed regardless of tier values.")

  if tierChanged then
    sendVehicleCmd(string.format("scratches_detect.setDeformTiers(%.4f, %.4f, %.4f)",
      uiPtrs.defT1[0], uiPtrs.defT2[0], uiPtrs.defT3[0]))
  end

  im.Separator()
  im.Text("--- Bake limits (GE) ---")
  if im.SliderInt("Aggregate cap (per frame)", uiPtrs.aggCap, 4, 64) then
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
    "Default: 1.50 m.\n" ..
    "Performance: avg projects/frame ~= avg clusters/frame.")

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
    uiPtrs.defT1[0]      = UI_DEFAULTS.defT1
    uiPtrs.defT2[0]      = UI_DEFAULTS.defT2
    uiPtrs.defT3[0]      = UI_DEFAULTS.defT3
    uiPtrs.aggCap[0]     = UI_DEFAULTS.aggCap
    uiPtrs.clusterRad[0] = UI_DEFAULTS.clusterRad
    AGGREGATE_PER_FRAME_CAP = UI_DEFAULTS.aggCap
    CLUSTER_RADIUS          = UI_DEFAULTS.clusterRad
    sendVehicleCmd(string.format("scratches_detect.setThresholds(%.3f, nil, nil)", UI_DEFAULTS.slip))
    sendVehicleCmd(string.format("scratches_detect.setPaintCooldown(%.4f)", UI_DEFAULTS.paintCool))
    sendVehicleCmd(string.format("scratches_detect.setImpactParams(%.0f, %.3f)", UI_DEFAULTS.impForce, UI_DEFAULTS.impCool))
    sendVehicleCmd(string.format("scratches_detect.setDeformTiers(%.4f, %.4f, %.4f)",
      UI_DEFAULTS.defT1, UI_DEFAULTS.defT2, UI_DEFAULTS.defT3))
    log('I', logTag, "UI: reset all tunables to defaults")
  end
  uiTooltip("Restore every slider to its canonical default and push the values to VLUA.")

  im.SameLine()
  if im.Button("Clear stamps") then
    M.clearStamps()
  end
  uiTooltip("Wipe every baked decal off the vehicle (keeps the underlying paint color).\nKeyboard equivalent: Ctrl+L.")

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
  log('I', logTag, "loaded. probes: scratches_paint.{dumpState,kickSetup,testStamp,testStampAt,testStampAtWorld,probeBrushes,stampAt,stampAtLocal,stampStream,stampBatch,clearStamps,addPaintFill,dumpDecalConfig,drawTextures,setStampVerbose,setAggregateCap,setClusterRadius,dumpPaintStats,resetPaintStats,toggleUI}")
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
