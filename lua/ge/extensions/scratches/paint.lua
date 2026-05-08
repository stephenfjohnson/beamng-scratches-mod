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
  return true
end

-- ---- per-frame ----
local function onUpdate(dtReal, dtSim, dtRaw)
  if ready then
    if api and api.onUpdate_ then api.onUpdate_() end
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
-- Generated by tools/generate_brushes.py. Greyscale streak shapes that get
-- tinted by setDecalColor at stamp time. Rotated randomly per-stamp so a
-- sliding contact doesn't lay down 50 identical-orientation copies.
local SCRATCH_BRUSHES = {
  "/art/dynamicDecals/textures/scratch_streak_01.png",
  "/art/dynamicDecals/textures/scratch_streak_02.png",
  "/art/dynamicDecals/textures/scratch_streak_03.png",
  "/art/dynamicDecals/textures/scratch_streak_04.png",
}

-- ---- synthetic-camera stamping (Phase 3 step 1) ----
--
-- The api keeps `decalProjection` and `app` as module-locals (line 16-17 of
-- editor/api/dynamicDecals.lua). M.addDecal hardcodes `app:getCameraM()` (the
-- player camera) and offers no override hook, so to stamp at an arbitrary
-- world point we have to call `decalProjection:getDecalData(camM, projM)` with
-- our own camera. We pluck decalProjection out via the bakeLayers closure;
-- BeamNG's own code uses debug.getupvalue (devUtils, powertrain, ai), so the
-- facility is sandbox-permitted.

local decalProjection = nil

local function resolveDecalProjection()
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
M.stampAtLocal = function(localPos, localNormal, opts)
  if not ready then log('W', logTag, "stampAtLocal: not ready"); return end
  if not resolveDecalProjection() then return end
  opts = opts or {}

  local veh = getPlayerVehicle(0)
  if not veh then return end

  -- Apply small positional jitter perpendicular to the surface so repeated
  -- events at the same node don't perfectly stack. Body nodes have fixed
  -- body-relative positions, so without jitter a 1-second drag against a
  -- wall produces N stamps at exactly the same point; with jitter they
  -- spread into a small cluster that reads as scratch coverage.
  if not opts.noJitter then
    local jitter = 0.03  -- ±3 cm
    localPos = vec3(
      localPos.x + (math.random() - 0.5) * 2 * jitter,
      localPos.y + (math.random() - 0.5) * 2 * jitter,
      localPos.z + (math.random() - 0.5) * 2 * jitter)
  end

  -- Style. Default GREEN tint until Phase 4 wires the multi-stage material;
  -- brush rotates among the procedural scratch set with a random angle and a
  -- small scale wobble so repeated stamps in the same spot don't all look
  -- identical.
  local baseScale = opts.scale or 0.10
  local scale    = opts.noJitter and baseScale or baseScale * (0.7 + math.random() * 0.6)
  local colorTex = opts.colorTex or SCRATCH_BRUSHES[math.random(#SCRATCH_BRUSHES)]
  local rot      = opts.rot or math.random() * 360.0
  api.setDecalTexturePath("color", colorTex)
  api.setDecalTexturePath("alpha", opts.alphaTex or "/art/dynamicDecals/textures/_one.png")
  api.setDecalColor(Point4F(opts.r or 0, opts.g or 1, opts.b or 0, 1))
  api.setDecalScale(vec3(scale, 1, scale))
  api.setDecalRotation(rot)
  api.setUseSurfaceNormal(true)

  -- UseMousePos must be OFF so the projection's cursor stays at screen-center
  -- (0.5, 0.5). Toggling here is idempotent because we check first.
  if api.isUseMousePos and api.isUseMousePos() then
    api.toggleSetting(api.settingsFlags.UseMousePos.value)
    log('I', logTag, "stampAtLocal: disabled UseMousePos")
  end

  local camLocal = buildSyntheticCameraLocal(localPos, localNormal, opts.dist)
  local projM    = getCameraProjMatrix()  -- reuse player projection; tune later

  -- Drive projectDynamicDecals manually. With UseMousePos=off, this writes
  -- the cursor to center-of-view (which IS our impact point under the
  -- synthetic camera). It also refreshes the depth/normal pass that
  -- getDecalData samples. The api.setProjectDynamicDecalsState(false) at
  -- setup() ensures nobody else is firing this with the player camera between
  -- frames.
  decalProjection:projectDynamicDecals(camLocal, projM)

  local decalData = decalProjection:getDecalData(camLocal, projM)
  if not decalData then log('W', logTag, "getDecalData returned nil"); return end

  -- Mint the layer-record fields addDecal sets after getDecalData.
  decalData.uid       = string.format("scr-%08x", math.random(0, 0xffffffff))
  decalData.name      = "scratch"
  decalData.enabled   = true
  decalData.locked    = false
  decalData.parentUid = nil
  decalData.children  = {}

  decalProjection:bakeLayers({decalData}, veh.JBeam or veh.jbeam)
  M._lastDecal = decalData
  log('I', logTag, string.format(
    "stampAtLocal: input pos=(%.2f,%.2f,%.2f) norm=(%.2f,%.2f,%.2f) | result decalPos=(%.2f,%.2f,%.2f) cursor=(%.3f,%.3f) uid=%s",
    localPos.x, localPos.y, localPos.z,
    localNormal.x, localNormal.y, localNormal.z,
    decalData.decalPos.x, decalData.decalPos.y, decalData.decalPos.z,
    decalData.cursorPosScreenUv and decalData.cursorPosScreenUv.x or -1,
    decalData.cursorPosScreenUv and decalData.cursorPosScreenUv.y or -1,
    decalData.uid))
  return decalData
end

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
M.stampAt = function(worldPos, worldNormal, kindOrOpts)
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
      opts = {
        scale    = 0.18,
        colorTex = "/art/dynamicDecals/textures/scratch_streak_03.png",
      }
    end
  elseif type(kindOrOpts) == "table" then
    opts = kindOrOpts
  end

  return M.stampAtLocal(localPos, localNormal, opts)
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
    {tex = "/art/dynamicDecals/textures/shape_circle.png",      rgb = {1, 0, 0}, name = "vanilla shape_circle (RED)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_01.png", rgb = {0, 1, 0}, name = "streak_01 (GREEN)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_02.png", rgb = {0, 1, 1}, name = "streak_02 (CYAN)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_03.png", rgb = {1, 1, 0}, name = "streak_03 (YELLOW)"},
    {tex = "/art/dynamicDecals/textures/scratch_streak_04.png", rgb = {1, 0, 1}, name = "streak_04 (MAGENTA)"},
  }
  -- Tight spread (±16cm Y) so probes stay on body for small vehicles too.
  -- X=1.0 / Z=0.4 is a right-door-ish point known to hit pigeon (verified
  -- from impact events) and well within bounds for larger vehicles.
  for i, brush in ipairs(brushes) do
    local y = -0.16 + (i - 1) * 0.08
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

-- Wipe all stamps (clears the layer stack and re-bakes empty texture).
M.clearStamps = function()
  if not ready then log('W', logTag, "clearStamps: not ready"); return end
  if not api or not api.clearLayerStack then log('W', logTag, "api.clearLayerStack unavailable"); return end
  api.clearLayerStack()
  log('I', logTag, "cleared all stamps (layers=" .. tostring(api.getLayerCount and api.getLayerCount()) .. ")")
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
  log('I', logTag, "loaded. probes: scratches_paint.{dumpState,kickSetup,testStamp,testStampAt,testStampAtWorld,probeBrushes,stampAt,stampAtLocal,clearStamps,dumpDecalConfig,drawTextures}")
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
