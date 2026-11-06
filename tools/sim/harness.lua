-- Headless harness for scratches_mod. Runs BOTH Lua VMs' code in one stock
-- Lua 5.1 state against mocked engine objects, so control flow, the VLUA -> GE
-- payload round trip, the per-frame projection budget and the combine gating
-- can be checked without launching BeamNG. It does not render anything:
-- whether marks LOOK right still needs an in-game check.
--
-- Run from the repo root:   lua tools/sim/harness.lua
-- Exit code 0 = all checks passed.

local ROOT = (arg and arg[0] or ""):match("^(.*)[/\\]tools[/\\]sim[/\\]") or "."

local failures, passes = 0, 0
local function check(cond, msg)
  if cond then passes = passes + 1
  else failures = failures + 1; print("FAIL: " .. msg) end
end

-- ---------------------------------------------------------------- mocks ----
table.clear = function(t) for k in pairs(t) do t[k] = nil end end
function tableSize(t) local n = 0; for _ in pairs(t) do n = n + 1 end; return n end
local logLines = {}
function log(lvl, tag, msg) logLines[#logLines + 1] = lvl .. " " .. tostring(msg) end
function dump() end
function dumps(x) return tostring(x) end

local V = {}
V.__index = V
function vec3(x, y, z) return setmetatable({x = x or 0, y = y or 0, z = z or 0}, V) end
V.__add = function(a, b) return vec3(a.x + b.x, a.y + b.y, a.z + b.z) end
V.__sub = function(a, b) return vec3(a.x - b.x, a.y - b.y, a.z - b.z) end
V.__mul = function(a, b)
  if type(a) == "number" then a, b = b, a end
  return vec3(a.x * b, a.y * b, a.z * b)
end
V.__unm = function(a) return vec3(-a.x, -a.y, -a.z) end
function V:dot(b) return self.x * b.x + self.y * b.y + self.z * b.z end
function V:cross(b)
  return vec3(self.y * b.z - self.z * b.y, self.z * b.x - self.x * b.z, self.x * b.y - self.y * b.x)
end
function V:length() return math.sqrt(self:dot(self)) end
function V:normalized()
  local l = self:length()
  if l < 1e-12 then return vec3(0, 0, 0) end
  return vec3(self.x / l, self.y / l, self.z / l)
end

-- Rigid 4x4: columns c[0..3] (c[3] = translation).
local Mx = {}
Mx.__index = Mx
function MatrixF()
  return setmetatable({c = {[0] = vec3(1,0,0), vec3(0,1,0), vec3(0,0,1), vec3(0,0,0)}}, Mx)
end
function Mx:setColumn(i, v) self.c[i] = vec3(v.x, v.y, v.z); return self end
function Mx:getColumn(i) local v = self.c[i]; return vec3(v.x, v.y, v.z) end
function Mx:copy()
  local m = MatrixF()
  for i = 0, 3 do m.c[i] = vec3(self.c[i].x, self.c[i].y, self.c[i].z) end
  return m
end
function Mx:mulP3F(p)
  local c = self.c
  return vec3(c[0].x*p.x + c[1].x*p.y + c[2].x*p.z + c[3].x,
              c[0].y*p.x + c[1].y*p.y + c[2].y*p.z + c[3].y,
              c[0].z*p.x + c[1].z*p.y + c[2].z*p.z + c[3].z)
end
function Mx:setPosition(v) self.c[3] = vec3(v.x, v.y, v.z); return self end
function Mx:fullInverse()
  -- R^T, -R^T t
  local c, m = self.c, MatrixF()
  m.c[0] = vec3(c[0].x, c[1].x, c[2].x)
  m.c[1] = vec3(c[0].y, c[1].y, c[2].y)
  m.c[2] = vec3(c[0].z, c[1].z, c[2].z)
  local t = c[3]
  m.c[3] = vec3(-(c[0]:dot(t)), -(c[1]:dot(t)), -(c[2]:dot(t)))
  return m
end
Mx.inverse = Mx.fullInverse

function Point4F(r, g, b, a) return {x = r, y = g, z = b, w = a} end
function Point2F(x, y) return {x = x, y = y} end

-- Player vehicle: translated 100 m along x so world != local.
local playerVid = 1001
local refM = MatrixF(); refM:setColumn(3, vec3(100, 0, 0))
local vehicle = {
  JBeam = "pickup",
  getId = function() return playerVid end,
  getRefNodeMatrix = function() return refM:copy() end,
  getDecalProjectionShape = function() return {} end,
  getWorldBox = function() return {minExtents = vec3(98, -3, -1), maxExtents = vec3(102, 3, 2)} end,
  getSpawnLocalAABB = function()
    return {minExtents = vec3(-1, -2.5, 0), maxExtents = vec3(1, 2.5, 1.8)}
  end,
  queueLuaCommand = function() end,
}
local hasPlayer = true
function getPlayerVehicle() return hasPlayer and vehicle or nil end
function getCameraProjMatrix() return MatrixF() end
function getVehicleColor() return "0.8 0.1 0.1 1 0 0 0 0" end

-- Materials: one body material with stage 1 painted from the dynamic canvas
-- (under a clear coat) and a factory stage 0 that must be left alone.
local matReloads = 0
local skinMat = {
  fields = {
    activeLayers    = {[0] = "2"},
    baseColorMap    = {[0] = "vehicles/pickup/pickup_b.png", "@DynamicTextureBaseColor", "", ""},
    metallicMap     = {[0] = "vehicles/pickup/pickup_m.png", "@DynamicTextureMetallic", "", ""},
    roughnessMap    = {[0] = "vehicles/pickup/pickup_r.png", "@DynamicTextureRoughness", "", ""},
    clearCoatFactor = {[0] = "0", "1", "0", "0"},
    normalMap       = {[0] = "vehicles/pickup/pickup_n.png", "vehicles/pickup/pickup_n.png", "", ""},
    opacityMap      = {[0] = "", "vehicles/pickup/pickup_c.png", "", ""},
  },
}
function skinMat:getField(name, stage) return (self.fields[name] or {})[stage] or "" end
function skinMat:setField(name, stage, value)
  self.fields[name] = self.fields[name] or {}
  self.fields[name][stage] = value
end
function skinMat:flush() end
function skinMat:reload() matReloads = matReloads + 1 end
scenetree = { findObject = function(name)
  if name == "pickup_body.skin.dynamicTextures" then return skinMat end
end }

-- Dynamic-decals projection + API mocks.
local counters = { projects = 0, bakes = 0, bakeLayers = 0, combines = 0, apiUpdates = 0,
                   maxProjectsInFrame = 0, projectsThisFrame = 0, clears = 0 }
local decalProjection = {}
-- Like the engine, a projection reads back one surface hit: the one under the
-- screen centre, along the camera's axis, taken when it projects. A capture
-- reports it as decalPos; setDecalLocalPos only moves the layer's cursor (its
-- screen UV under that camera, 60 deg field of view). mockSurface(camPos,
-- camFwd) returns the hit (car-local) when a test models one; otherwise there
-- is no reading.
local lastCam, lastHit = nil, nil
local mockSurface = nil
function decalProjection:projectDynamicDecals(cam)
  lastCam = cam
  lastHit = mockSurface and mockSurface(cam.c[3], cam.c[1]) or nil
  counters.projects = counters.projects + 1
  counters.projectsThisFrame = counters.projectsThisFrame + 1
end
-- A captured layer snapshots the box depth and orientation the api was set to.
local decalState = { depth = nil, surfaceNormal = true, rot = 0 }
local bakedLog = {}   -- every layer baked, in order
function decalProjection:getDecalData()
  counters.getDecalData = (counters.getDecalData or 0) + 1
  local hit = lastHit and { x = lastHit.x, y = lastHit.y, z = lastHit.z } or nil
  return { cursorPosScreenUv = {x = 0.5, y = 0.5}, decalPos = hit,
           depth = decalState.depth, surfaceNormal = decalState.surfaceNormal, rot = decalState.rot,
           camFwd = lastCam and lastCam.c[1] }
end
function decalProjection:bakeLayers(list)
  for _, l in ipairs(list) do bakedLog[#bakedLog + 1] = l end
  counters.bakes = counters.bakes + 1
  counters.bakeLayers = counters.bakeLayers + #list
  counters.bakesThisFrame = (counters.bakesThisFrame or 0) + 1
  if #list > (counters.maxBakeLayers or 0) then counters.maxBakeLayers = #list end
end
function decalProjection:clearBakedTextures() counters.clears = counters.clears + 1 end
function decalProjection:flushDynamicTextures() end
function decalProjection:combineTextures() counters.combines = counters.combines + 1 end
function decalProjection:setShape() end
function decalProjection:setWorldTransform() end
function decalProjection:setTransform() end

local api = { ready = false, layerTypes = {fill = 1}, blendModesMap = {Normal = 1},
              settingsFlags = {UseMousePos = {value = 1}} }
api.bakeLayers = function(layers) return decalProjection:bakeLayers(layers) end  -- upvalue pluck target
api.setup = function() api.ready = true end
local app = { textureSet = {} }  -- upvalue the painter plucks, like the real API's
api.onUpdate_ = function()
  counters.apiUpdates = counters.apiUpdates + 1  -- a full texture-set re-bind
  decalProjection:combineTextures(app.textureSet)
end
api.onVehicleSwitched = function() end
api.setProjectDynamicDecalsState = function() end
api.getShapeMaterialNames = function() return {"pickup_body", "pickup_glass"} end
local boundIdx = {}
api.getMaterialIndices = function() return boundIdx end
api.addMaterialIdx = function(i) boundIdx[#boundIdx + 1] = i end
api.getLayerCount = function() return 0 end
api.clearLayerStack = function() end
api.getTextureSet = function() return {} end
api.isUseMousePos = function() return false end
api.toggleSetting = function() end
api.setLockDepth = function() end
for _, n in ipairs({"setMetallicIntensity", "setRoughnessIntensity",
                    "setDecalColor"}) do
  api[n] = function() end
end
api.setDecalRotation = function(a) decalState.rot = a end
api.setDecalScale = function(v) decalState.depth = v.y end
api.setUseSurfaceNormal = function(on) decalState.surfaceNormal = on end
local brushLog = {}   -- every colour brush the painter selected, in order
api.setDecalTexturePath = function(kind, path) if kind == "color" then brushLog[#brushLog + 1] = path end end
api.setDecalLocalPos = function(decal, p)
  local u, v = 0.5, 0.5
  if lastCam then
    local c = lastCam.c
    local rx, ry, rz = p.x - c[3].x, p.y - c[3].y, p.z - c[3].z
    local z = rx * c[1].x + ry * c[1].y + rz * c[1].z
    if z <= 1e-3 then
      u, v = -1, -1   -- behind the camera
    else
      local k = 1 / (2 * z * math.tan(math.rad(30)))
      u = 0.5 + (rx * c[0].x + ry * c[0].y + rz * c[0].z) * k
      v = 0.5 - (rx * c[2].x + ry * c[2].y + rz * c[2].z) * k
    end
  end
  decal.cursorPosScreenUv = {x = u, y = v}
end

local partConfig = { partsTree = { id = "root", children = { { id = "paint_design", chosenPartName = "" } } } }
extensions = {
  editor_api_dynamicDecals = api,
  core_vehicle_partmgmt = {
    hasAvailablePart = function() return true end,
    getConfig = function() return partConfig end,
    setSkin = function() partConfig.partsTree.children[1].chosenPartName = "pickup_skin_dynamicTextures" end,
  },
  load = function() end,
}
core_vehicle_manager = { getPlayerVehicleData = function() return {} end }

-- Minimal ImGui: any unknown function is a no-op returning false; pointers
-- are {[0]=value} like the FFI-backed ones.
local function ptr(v) return {[0] = v} end
ui_imgui = setmetatable({
  FloatPtr = ptr, IntPtr = ptr, BoolPtr = ptr,
  ImVec2 = function(x, y) return {x = x, y = y} end,
  ImVec4 = function(...) return {...} end,
  Begin = function() return true end,
  GetContentRegionAvail = function() return {x = 820, y = 560} end,
  GetScrollY = function() return 0 end, GetScrollMaxY = function() return 0 end,
}, { __index = function() return function() return false end end })

-- ------------------------------------------------------ load the GE side ----
local paint = dofile(ROOT .. "/lua/ge/extensions/scratches/paint.lua")
scratches_paint = paint

local function frame(dt)
  counters.projectsThisFrame = 0
  counters.bakesThisFrame = 0
  paint.onUpdate(dt or 1 / 60, dt or 1 / 60, dt or 1 / 60)
  if counters.projectsThisFrame > counters.maxProjectsInFrame then
    counters.maxProjectsInFrame = counters.projectsThisFrame
  end
  if counters.projectsThisFrame > 0 then
    counters.projectingFrames = (counters.projectingFrames or 0) + 1
    if counters.bakesThisFrame > 0 then
      counters.projectAndBakeFrames = (counters.projectAndBakeFrames or 0) + 1
    end
  end
end
-- Projection passes allowed per flush batch, as configured in the painter.
local function projBudget() return paint.getStats().config.projBudget end

paint.onExtensionLoaded()
for _ = 1, 5 do frame() end
local f = skinMat.fields
check(f.activeLayers[0] == "3", "damage layer adds a third material stage")
check(f.opacityMap[2] == "@DynamicTextureRoughness" and f.opacityMapUseUV[2] == "1",
  "factory paint (stage 2) fades on the canvas roughness, sampled on UV1")
check(f.opacityDetailMap[2] == "vehicles/pickup/pickup_c.png" and f.detailOpacityMapStrength[2] == "1",
  "stage 2 keeps the paint mask (as its opacity detail) so trim stays unpainted")
check(f.baseColorMap[2] == "@DynamicTextureBaseColor" and f.normalMap[2] == "vehicles/pickup/pickup_n.png"
  and f.clearCoatFactor[2] == "1", "stage 2 is a copy of the original paint stage")
check(f.metallicMap[2] == "" and f.metallicFactor[2] == "0" and f.roughnessMap[2] == ""
  and f.roughnessFactor[2] == "0.05",
  "stage 2 paint takes the car's own paint finish as constants (no seed, no seams)")
check(f.roughnessMap[1] == "@DynamicTextureMetallic" and f.roughnessMapUseUV[1] == "1"
  and f.clearCoatFactor[1] == "0" and f.metallicFactor[1] == "0",
  "stage 1 is the exposed surface: roughness from the canvas metallic channel, no clear coat")
check(f.metallicMap[0] == "vehicles/pickup/pickup_m.png", "the factory stage-0 metallic map is left alone")
check(matReloads == 2, "material reloaded twice at setup - split, then paint finish (got " .. matReloads .. ")")
check(counters.bakes >= 1, "paint seed fill baked at setup")

-- Idle: 2 s of frames with nothing new should neither composite nor re-bind
-- (a re-bind costs 24-55 ms in game; it used to run on a 0.5 s heartbeat).
local before, beforeCombines = counters.apiUpdates, counters.combines
for _ = 1, 120 do frame() end
local idleUpdates = counters.apiUpdates - before
local idleCombines = counters.combines - beforeCombines
check(idleUpdates == 0, "idle frames run no texture-set re-bind (" .. idleUpdates .. " in 120 frames)")
check(idleCombines == 0, "idle frames run no composite (" .. idleCombines .. " in 120 frames)")

-- --------------------------------------------------- load the vehicle side ----
local queuedGE = {}
obj = {
  simTime = 0,
  getSimTime = function(self) return self.simTime end,
  getId = function() return playerVid end,
  queueGameEngineLua = function(self, s) queuedGE[#queuedGE + 1] = s end,
}
-- Ids follow lua/common/particles.json (METAL = 2 ... ASPHALT = 10).
local mats = {}
for i, n in ipairs({"NONE", "METAL", "PLASTIC", "RUBBER", "GLASS", "WOOD", "FOLIAGE", "CLOTH",
                    "WATER", "ASPHALT", "ASPHALT_WET", "SLIPPERY", "ROCK", "DIRT_DUSTY", "DIRT",
                    "SAND", "SANDY_ROAD", "MUD", "GRAVEL", "GRASS", "ICE", "SNOW", "RUMBLE_STRIP",
                    "COBBLESTONE"}) do mats[i] = {name = n} end
particles = {
  getMaterialsParticlesTable = function() return mats end,
  getMaterialIDByName = function(m, s)
    for k, v in pairs(m) do if v.name == s then return k end end
    return math.min(3, #m)
  end,
}
local METAL, ASPHALT = 2, 10
v = { data = { nodes = {
  [10] = { nodeMaterial = METAL, partOrigin = "pickup_door_L" },
  [11] = { nodeMaterial = METAL, partOrigin = "pickup_door_L" },
  [20] = { nodeMaterial = METAL, partOrigin = "pickup_engine_v8", },
  [30] = { nodeMaterial = 4, wheelID = 1, partOrigin = "tire" },
  [40] = { nodeMaterial = METAL, partOrigin = "pickup_headlight_L" },   -- 5 cm from door node 10
  [41] = { nodeMaterial = METAL, partOrigin = "pickup_headlight_R" },   -- nothing paintable near
} } }
playerInfo = { firstPlayerSeated = true }
function onNodeCollision() end

local detect = dofile(ROOT .. "/lua/vehicle/extensions/auto/scratches_detect.lua")
detect.onExtensionLoaded()
queuedGE = {}

local function runGE()
  for _, s in ipairs(queuedGE) do
    local f, err = loadstring(s)
    check(f ~= nil, "VLUA payload compiles on GE: " .. tostring(err))
    if f then f() end
  end
  local n = #queuedGE
  queuedGE = {}
  return n
end

local function contact(id, x, y, z, slipVel, normalForce)
  _G.onNodeCollision(id, vec3(x, y, z), vec3(0, 0, 1), vec3(0, 0, 0), 0, vec3(0, 0, 0),
                     slipVel, 0, normalForce, 0.01, ASPHALT, METAL)  -- (surface, node material) as the engine passes them
end

-- 1) A long slide on two door nodes + a wheel + an excluded engine node.
local dtPhys = 0.0005
for step = 1, 1200 do
  obj.simTime = obj.simTime + dtPhys
  local x = 100 + step * 0.01
  contact(10, x, 0.5, 0.3, 8, 300)
  contact(11, x, 0.8, 0.3, 8, 300)
  contact(30, x, 0, 0, 8, 3000)
  contact(20, x, 0, 0.2, 8, 300)
  if step % 33 == 0 then detect.updateGFX(1 / 60) end
end
obj.simTime = obj.simTime + 0.2
detect.updateGFX(1 / 60)
local calls = runGE()
check(calls >= 1, "slide produced GE ingest calls (" .. calls .. ")")

-- Drain on GE and verify the per-frame budget.
counters.maxProjectsInFrame = 0
local bakesBefore = counters.bakes
local combinesBefore, rebindsBefore = counters.combines, counters.apiUpdates
counters.projectingFrames = 0
for _ = 1, 40 do frame() end
check(counters.bakes > bakesBefore, "streams were baked")
-- Projection costs ~14 ms per frame that projects at all, so work is batched
-- on FLUSH_INTERVAL (0.2 s): 40 frames at 60 fps = 0.67 s -> at most 4 flushes.
check(counters.projectingFrames <= 4,
  "slide work is batched (" .. counters.projectingFrames .. " projecting frames in 40)")
check(counters.combines > combinesBefore and counters.apiUpdates == rebindsBefore,
  "baked frames composite on the light path (" .. (counters.apiUpdates - rebindsBefore) .. " re-binds)")
check(counters.maxProjectsInFrame <= projBudget(),
  "projections/frame stay within budget (max " .. counters.maxProjectsInFrame .. ")")

-- 2) A burst of impacts: many clusters, one bake per frame, spread over frames.
for i = 1, 40 do
  obj.simTime = obj.simTime + 0.5   -- re-arm the impact onset gate each time
  contact(10 + (i % 2), 100 + (i % 8) * 0.9, (i % 5) * 0.9 - 2, 0.3, 0, 12000)  -- hard enough to chip
end
detect.updateGFX(1 / 60)
runGE()
counters.maxProjectsInFrame = 0
local bakes0, frames = counters.bakes, 0
for _ = 1, 30 do
  local b = counters.bakes
  frame()
  check(counters.bakes - b <= 1, "at most one bake per frame")
  frames = frames + 1
end
check(counters.bakes > bakes0, "impacts were baked")
check(counters.maxProjectsInFrame <= projBudget(), "impact burst within budget (max " .. counters.maxProjectsInFrame .. ")")
-- The ~14 ms projection toll and the ~0.85 ms/layer bake never share a frame,
-- and bakes are chunked so no single frame bakes a whole crash.
check((counters.projectAndBakeFrames or 0) == 0,
  "no frame both projects and bakes (" .. (counters.projectAndBakeFrames or 0) .. ")")
check((counters.maxBakeLayers or 0) <= 6, "bakes are chunked (max " .. (counters.maxBakeLayers or 0) .. " layers)")

-- 2b) A NaN contact is dropped on its own; the rest of the frame still ships.
obj.simTime = obj.simTime + 0.5
contact(10, 0/0, 0, 0.3, 0, 12000)
obj.simTime = obj.simTime + 0.5
contact(11, 101, 0.5, 0.3, 0, 12000)
detect.updateGFX(1 / 60)
local payload = table.concat(queuedGE, " ")
check(not payload:find("nan", 1, true) and not payload:find("inf", 1, true),
  "non-finite sample kept out of the GE payload")
local p0 = counters.projects
runGE()
for _ = 1, 10 do frame() end
check(counters.projects > p0, "the finite impact in the same frame still lands")

-- 2c) A projection job that throws costs one job, not the whole queue.
local realGetDecalData = decalProjection.getDecalData
local throwOnce = true
decalProjection.getDecalData = function(self, ...)
  if throwOnce then throwOnce = false; error("simulated engine failure") end
  return realGetDecalData(self, ...)
end
paint.ingest(playerVid, { {100, 0, 0.5, 0, 0, 1, "i", 12000}, {103, 2, 0.5, 0, 0, 1, "i", 12000} }, nil)
local b1 = counters.bakes
local okF, errF = pcall(function() for _ = 1, 40 do frame() end end)
check(okF, "a throwing job does not abort onUpdate: " .. tostring(errF))
check(counters.bakes > b1, "the job after a failed one still bakes")
decalProjection.getDecalData = realGetDecalData
local failedLogged = false
for i = #logLines, 1, -1 do
  if logLines[i]:find("projection job failed", 1, true) then failedLogged = true; table.remove(logLines, i) end
end
check(failedLogged, "failed job is logged")

-- 3) A traffic car (not player-seated) does nothing at all.
playerInfo.firstPlayerSeated = false
for step = 1, 200 do
  obj.simTime = obj.simTime + dtPhys
  contact(10, 100 + step * 0.01, 0.5, 0.3, 8, 5000)
end
obj.simTime = obj.simTime + 0.2
detect.updateGFX(1 / 60)
check(#queuedGE == 0, "non-player vehicle queues nothing for GE (got " .. #queuedGE .. ")")
detect.onReset()
local clearQueued = false
for _, q in ipairs(queuedGE) do if q:find("clearStamps", 1, true) then clearQueued = true end end
check(not clearQueued, "non-player reset does not clear the player's scratches")
queuedGE = {}
playerInfo.firstPlayerSeated = true

-- 4) A batch tagged with another vehicle id is dropped on GE.
for _ = 1, 60 do frame() end  -- drain anything still batched from above
local jobsBefore = counters.projects
paint.ingest(4242, { {100, 0, 0.5, 0, 0, 1, "i", 6000} }, nil)
for _ = 1, 30 do frame() end
check(counters.projects == jobsBefore, "foreign-vehicle batch dropped")

-- 4b) Spot memory: the same spot takes SPOT_MAX_IMPACT (2) impact passes, then
-- further marks there are skipped until the canvas is cleared.
local skip0 = paint.getStats().stamp.spotsSkipped
for _ = 1, 4 do paint.ingest(playerVid, { {150, 1, 0.5, 0, 0, 1, "i", 12000} }, nil) end
check(paint.getStats().stamp.spotsSkipped == skip0 + 2,
  "a saturated spot skips further impacts (" .. (paint.getStats().stamp.spotsSkipped - skip0) .. " skipped of 4)")
paint.clearStamps()
local skip1 = paint.getStats().stamp.spotsSkipped
paint.ingest(playerVid, { {150, 1, 0.5, 0, 0, 1, "i", 6000} }, nil)
check(paint.getStats().stamp.spotsSkipped == skip1, "a clear resets the spot memory")
for _ = 1, 20 do frame() end

-- 4c) Two slides 10 cm apart share one projection (each projecting frame
-- costs a ~14 ms toll in game).
local m0, pr0 = paint.getStats().stamp.streamsMerged, counters.projects
paint.ingest(playerVid, nil, {
  { {100.0, 0.0, 0.6, 0, 0, 1}, {100.4, 0.0, 0.6, 0, 0, 1} },
  { {100.0, 0.1, 0.6, 0, 0, 1}, {100.4, 0.1, 0.6, 0, 0, 1} },
})
for _ = 1, 20 do frame() end
check(paint.getStats().stamp.streamsMerged == m0 + 1 and counters.projects == pr0 + 1,
  "adjacent slides share one projection (" .. (counters.projects - pr0) .. " projections)")

-- 5) Vehicle switch mid-backlog: no error, queue dropped (the WIP crash),
-- and the old car's mark log goes with it (it would steer the new car's marks).
paint.ingest(playerVid, { {100, 0, 0.5, 0, 0, 1, "i", 6000} }, nil)
local ok, err = pcall(paint.onVehicleSwitched, playerVid, 2002, 0)
check(ok, "onVehicleSwitched runs cleanly: " .. tostring(err))
check(#paint.getMarks() == 0, "a vehicle switch clears the mark log")
for _ = 1, 5 do frame() end

-- 5b) Bench hooks (tools/bench.py): profiling counts every contact, stats
-- reach GE as a table through a named callback, and only a plain
-- module.function name is accepted (it is spliced into GE code).
detect.setProfile(true)
for step = 1, 20 do contact(10, 200 + step * 0.01, 0.5, 0.3, 8, 300) end
detect.updateGFX(1 / 60)
runGE()
local got
_G.benchProbe = { recv = function(s, p) got = { s = s, p = p } end }
detect.sendStatsTo("benchProbe.recv")
runGE()
check(got ~= nil and got.p.contacts == 20,
  "profiled contacts counted (" .. tostring(got and got.p.contacts) .. ")")
check(got ~= nil and type(got.s.totalCalls) == "number", "detector stats reach GE as a table")
detect.sendStatsTo("os.exit(1) --")
check(#queuedGE == 0, "sendStatsTo refuses a callback that isn't module.function")
detect.setProfile(false)

-- The surface filter reads materialId1 (what the node hit), not materialId2
-- (the node's own material): a METAL door node brushing FOLIAGE is rejected.
local FOLIAGE = 7
local function detStats()
  got = nil
  detect.sendStatsTo("benchProbe.recv")
  runGE()
  return got.s
end
local rejBefore = detStats().rejSurfaceMat or 0
_G.onNodeCollision(10, vec3(300, 0.5, 0.3), vec3(0, 0, 1), vec3(0, 0, 0), 0, vec3(0, 0, 0),
                   8, 0, 300, 0.01, FOLIAGE, METAL)
check((detStats().rejSurfaceMat or 0) == rejBefore + 1,
  "surface filter reads materialId1 (body node on FOLIAGE rejected)")

local st = paint.getStats()
check(st.perf.frames > 0 and type(st.perf.msMax) == "number", "painter reports its own frame cost")
check(type(st.stamp.projectsIssued) == "number" and st.queue.jobs ~= nil, "painter stats snapshot is complete")

-- 6) Clear: wipes, re-seeds, and does NOT reload materials again.
local reloads = matReloads
local ok2, err2 = pcall(paint.clearStamps)
check(ok2, "clearStamps runs cleanly: " .. tostring(err2))
local rebindsAtClear = counters.apiUpdates
frame()
check(counters.apiUpdates == rebindsAtClear + 1, "a clear re-binds the texture set exactly once")
check(matReloads == reloads, "clearStamps skips material reload when M/R already repointed")

-- 6b) A respawn/reset that rebuilds the skin material from its JSON gets the
-- damage layer back (otherwise the shipped stage would read canvas metallic/
-- roughness - both 1 - as a matte-metal body).
for k in pairs(f) do
  if k ~= "activeLayers" then f[k][2] = "" end
end
f.activeLayers[0] = "2"
f.metallicMap[1], f.roughnessMap[1], f.clearCoatFactor[1] = "@DynamicTextureMetallic", "@DynamicTextureRoughness", "1"
f.opacityMap[1], f.detailMap[1], f.detailNormalMap[1], f.roughnessDetailMap[1] = "vehicles/pickup/pickup_c.png", "", "", ""
paint.onVehicleResetted(playerVid)
check(f.activeLayers[0] == "3" and f.opacityMap[2] == "@DynamicTextureRoughness"
  and f.roughnessMap[1] == "@DynamicTextureMetallic", "reset after a material rebuild re-applies the damage layer")

-- 6c) The event fields the detector now sends (material, slide direction and
-- speed) are consumed: a fast glancing hit on a METAL panel leaves marks.
local layersBefore = counters.bakeLayers
paint.ingest(playerVid, { { 101, 0.5, 0.4, -1, 0, 0, "i", 16000, "M", 0, 1, 0, 5 } }, {})
for _ = 1, 30 do frame() end
check(counters.bakeLayers - layersBefore >= 4,
  "a hard glancing impact lays haze, streaks, chips and a gouge (" .. (counters.bakeLayers - layersBefore) .. " layers)")
layersBefore = counters.bakeLayers
paint.ingest(playerVid, { { 104, 0.5, 0.4, -1, 0, 0, "i", 16000, "G", 0, 1, 0, 5 } }, {})
for _ = 1, 30 do frame() end
check(counters.bakeLayers - layersBefore <= 2, "glass contacts only scuff (no chips/gouge)")

-- 6d) Car-on-car: BeamNG never reports vehicle-vehicle contacts to
-- onNodeCollision, so while map.objects says we touch another car the painter
-- probes node proximity and paints the player nodes within reach, with the
-- other car's paint transferred.
do
  local refPos = vec3(100, 0, 0)  -- refM translation (above)
  local function at(lx, ly, lz) return refPos.x + lx, refPos.y + ly, refPos.z + lz end
  -- Node 3 is a row behind the contact front (further along the side, clear
  -- of the other marks): within reach of the other car's node 2, not touching.
  local playerNodes = { [0] = { at(1.0, 0.0, 0.5) }, [1] = { at(1.0, 0.5, 0.5) }, [2] = { at(-1.0, 0.0, 0.5) },
                        [3] = { at(0.93, 1.5, 0.45) } }
  vehicle.getNodeAbsPositionXYZ = function(_, i) local q = playerNodes[i] return q[1], q[2], q[3] end
  vehicle.getVelocity = function() return vec3(0, 0, 0) end
  local other = {
    getId = function() return 777 end,
    getNodeCount = function() return 3 end,
    getNodeAbsPositionXYZ = function(_, i)
      local x, y, z = at(1.1, i < 2 and i * 0.5 or 1.5, 0.5)
      return x, y, z
    end,
    getVelocity = function() return vec3(-6, 2, 0) end,
    getWorldBox = function() return {minExtents = vec3(100.5, -1, -1), maxExtents = vec3(104, 2, 2)} end,
    color = { x = 0.9, y = 0.1, z = 0.1 },
  }
  local realFindById = scenetree.findObjectById
  scenetree.findObjectById = function(id) if id == 777 then return other end end
  _G.map = { objects = { [playerVid] = { objectCollisions = { [777] = 1 } } } }
  paint.setBodyNodes(playerVid, { 0, 1, 2, 3 }, "MMPM")
  local before = counters.bakeLayers
  for _ = 1, 40 do frame() end
  check(counters.bakeLayers > before, "car-on-car contact paints the touching side ("
    .. (counters.bakeLayers - before) .. " layers)")
  local behind = false
  for _, m in ipairs(paint.getMarks()) do if m[2] > 1.2 then behind = true end end
  check(not behind, "car-on-car paints the contact front, not node rows behind it")

  -- Wedged together at rest, then a real hit: resting contact must not use
  -- up the contact spots (it used to: two probes saturated them for good).
  other.getVelocity = function() return vec3(0, 0, 0) end
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  before = counters.bakeLayers
  local probes0 = paint.getStats().perf.cvcProbes
  for _ = 1, 40 do frame() end
  check(counters.bakeLayers == before, "cars resting against each other paint nothing")
  check(paint.getStats().perf.cvcProbes == probes0, "cars resting against each other skip the probe")
  other.getVelocity = function() return vec3(-6, 0, 0) end
  for _ = 1, 40 do frame() end
  check(counters.bakeLayers > before, "a real hit after resting contact still paints")

  -- While touching, a detector contact inside the other car's box is left to
  -- the probe; one elsewhere (a barrier, the ground) still marks.
  other.getVelocity = function() return vec3(0, 0, 0) end
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local d0 = paint.getStats().stamp.carContactsDropped or 0
  paint.ingest(playerVid, { { 101, 0, 0.5, -1, 0, 0, "i", 16000, "M", 0, 1, 0, 5 } }, {})
  check((paint.getStats().stamp.carContactsDropped or 0) == d0 + 1, "a detector contact on the other car is dropped")
  before = counters.bakeLayers
  paint.ingest(playerVid, { { 99, -2, 0.5, -1, 0, 0, "i", 16000, "M", 0, 1, 0, 5 } }, {})
  for _ = 1, 30 do frame() end
  check(counters.bakeLayers > before, "a detector contact away from the other car still marks")

  _G.map = nil
  scenetree.findObjectById = realFindById
end

-- 6d2) A hit that paints nothing (a light square-on knock) leaves the spot
-- free for a later real hit there.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  for _ = 1, 3 do paint.ingest(playerVid, { { 160, 1, 0.5, 0, 0, 1, "i", 2500 } }, nil) end
  local before = counters.bakeLayers
  paint.ingest(playerVid, { { 160, 1, 0.5, 0, 0, 1, "i", 16000 } }, nil)
  for _ = 1, 30 do frame() end
  check(counters.bakeLayers > before, "empty light knocks don't use up the spot")
end

-- 6e) Merged slides: two neighbouring slides share one projection job, and
-- each band draws only its own segments (the job's segment list used to be
-- the first band's own table, so merged segments were drawn twice, angled
-- across both contacts).
do
  local function slide(y0)
    return { { 99, y0, 0.5, -1, 0, 0 }, { 99, y0 + 0.2, 0.5, -1, 0, 0 }, { 99, y0 + 0.4, 0.5, -1, 0, 0 },
             m = "M", f = 1200 }
  end
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local l0 = counters.bakeLayers
  paint.ingest(playerVid, {}, { slide(-1.6) })
  for _ = 1, 30 do frame() end
  local one = counters.bakeLayers - l0
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  l0 = counters.bakeLayers
  paint.ingest(playerVid, {}, { slide(-0.4), slide(-0.25) })
  for _ = 1, 30 do frame() end
  local two = counters.bakeLayers - l0
  check(one > 0 and two == 2 * one, "two merged slides bake twice one slide's layers (" .. one .. " vs " .. two .. ")")
end

-- 6f) A seeded run repeats exactly: same seed, same events -> same brushes
-- (brush recency used to survive the reseed and change the re-rolls).
do
  local function seededRun()
    paint.clearStamps()
    for _ = 1, 20 do frame() end
    paint.seedRandom(1234)
    local b0 = #brushLog
    paint.ingest(playerVid, { { 101, -0.5, 0.4, -1, 0, 0, "i", 16000, "M", 0, 1, 0, 5 },
                              { 101, 0.5, 0.4, -1, 0, 0, "i", 9000, "M", 0, 1, 0, 3 } }, {})
    for _ = 1, 30 do frame() end
    return table.concat(brushLog, ",", b0 + 1)
  end
  local a, b = seededRun(), seededRun()
  check(a ~= "" and a == b, "a seeded run picks the same brushes every time")
end

-- 6g) A 1-point slide fallback on glass stays a scuff, however hard it pressed.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local b0 = #brushLog
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "s", 16000, "G" } }, {})
  for _ = 1, 30 do frame() end
  local chips = false
  for i = b0 + 1, #brushLog do if brushLog[i]:find("chips", 1, true) then chips = true end end
  check(#brushLog > b0 and not chips, "a hard glass slide fallback leaves haze, not primer chips")
end

-- 6g1) A slide too brief to trace (a bumper corner raked across a post: three
-- physics ticks, the contact barely moving) still carries its slip direction,
-- so the mark is dragged along it instead of a round scuff.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  obj.simTime = obj.simTime + 1
  for _ = 1, 3 do
    obj.simTime = obj.simTime + 0.003
    _G.onNodeCollision(10, vec3(100.5, 0.5, 0.3), vec3(0, 0, 1), vec3(0, 0, 0), 0, vec3(2.5, 0, 0), 2.5, 0, 3000,
                       0.01, ASPHALT, METAL)
  end
  obj.simTime = obj.simTime + 0.2
  detect.updateGFX(1 / 60)
  runGE()
  for _ = 1, 30 do frame() end
  local dragged = false
  for _, m in ipairs(paint.getMarks()) do if m[10] ~= 0 or m[11] ~= 0 or m[12] ~= 0 then dragged = true end end
  check(dragged, "a brief slide's mark runs along its slip")
end

-- 6g1b) A lamp's contact belongs to the panel around it: it moves to the
-- paintable body node nearest the lamp node at rest, within 12 cm (through a
-- broken lens the mark landed on the hood edge behind it), or is dropped when
-- there is none. Rest positions, so a crushed lamp still finds its panel.
do
  local rest = { [10] = vec3(0.5, 0.5, 0.3), [40] = vec3(0.55, 0.5, 0.3), [41] = vec3(3, 3, 3) }
  for cid, q in pairs(rest) do v.data.nodes[cid].pos = q end
  local live = { [10] = vec3(0.5, 0.5, 0.3), [40] = vec3(0.55, 0.5, 0.3), [41] = vec3(3, 3, 3) }
  obj.getNodePosition = function(_, cid) return live[cid] or vec3(50, 50, 50) end
  local function lampHit(id)   -- the contact is at the lamp node's live position
    paint.clearStamps()
    for _ = 1, 20 do frame() end
    obj.simTime = obj.simTime + 1
    local at = live[id]
    _G.onNodeCollision(id, vec3(100 + at.x, at.y, at.z), vec3(0, 0, 1), vec3(0, 0, 0), 0, vec3(0, 0, 0), 0, 0, 9000,
                       0.01, ASPHALT, METAL)
    obj.simTime = obj.simTime + 0.2
    detect.updateGFX(1 / 60)
    runGE()
    for _ = 1, 30 do frame() end
    return #paint.getMarks()
  end
  local n = lampHit(40)
  local m = paint.getMarks()[1]
  check(n == 1 and m and math.abs(m[1] - 0.5) < 0.005, "a headlight contact marks the panel beside the lamp ("
    .. tostring(m and m[1]) .. ")")
  check(lampHit(41) == 0, "a headlight contact with no panel near leaves no mark")
  -- Crushed 30 cm away from its panel, the lamp still snaps to it (by rest
  -- position), and the mark lands where that panel now is.
  detect.onReset()
  runGE()
  live[40] = vec3(0.85, 0.5, 0.3)
  n = lampHit(40)
  m = paint.getMarks()[1]
  check(n == 1 and m and math.abs(m[1] - 0.5) < 0.005, "a crushed lamp still marks its own panel ("
    .. tostring(m and m[1]) .. ")")
  live[40] = vec3(0.55, 0.5, 0.3)
  for cid in pairs(rest) do v.data.nodes[cid].pos = nil end
  obj.getNodePosition = nil
end

-- 6g1c) A crash contact whose node has stopped still drags along the car's
-- own motion over the surface (a corner raked past a post read square-on).
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  obj.getVelocity = function() return vec3(3.5, 0, 0) end
  obj.simTime = obj.simTime + 1
  _G.onNodeCollision(11, vec3(100.5, 0.8, 0.3), vec3(0, 0, 1), vec3(0, 0, 0), 0, vec3(0, 0, 0), 0, 0, 9000,
                     0.01, ASPHALT, METAL)
  obj.simTime = obj.simTime + 0.2
  detect.updateGFX(1 / 60)
  obj.getVelocity = nil
  runGE()
  for _ = 1, 30 do frame() end
  local m = paint.getMarks()[1]
  check(m and (m[10] ~= 0 or m[11] ~= 0 or m[12] ~= 0), "a stopped node's impact drags along the car's motion")
end

-- 6g1d) Against an upright surface the car's vertical motion is suspension
-- bounce: the fallback drag runs along the wall, not up it.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  obj.getVelocity = function() return vec3(3.5, 0, 2.0) end
  obj.simTime = obj.simTime + 1
  _G.onNodeCollision(11, vec3(100.5, 0.8, 0.3), vec3(0, 1, 0), vec3(0, 0, 0), 0, vec3(0, 0, 0), 0, 0, 9000,
                     0.01, ASPHALT, METAL)
  obj.simTime = obj.simTime + 0.2
  detect.updateGFX(1 / 60)
  obj.getVelocity = nil
  runGE()
  for _ = 1, 30 do frame() end
  local m = paint.getMarks()[1]
  check(m and math.abs(m[12]) < 0.1 and math.abs(m[10]) > 0.9, "the car's bounce doesn't tilt a fallback drag ("
    .. tostring(m and m[12]) .. ")")
end

-- 6g2) A hard square-on crush (no slide) scuffs the paint it pressed on.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local b0 = #brushLog
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  local haze = false
  for i = b0 + 1, #brushLog do if brushLog[i]:find("haze", 1, true) then haze = true end end
  check(haze, "a hard square-on crush leaves a clear-coat scuff")
  -- Concrete scuffs from a moderate press too (5 kN, sev ~0.2).
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  b0 = #brushLog
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 5000, "M" } }, {})
  for _ = 1, 30 do frame() end
  haze = false
  for i = b0 + 1, #brushLog do if brushLog[i]:find("haze", 1, true) then haze = true end end
  check(haze, "a moderate square-on press against a hard surface scuffs")
end

-- 6h) A projection ray that passes a crumpled panel: a short overshoot is
-- painted with its box deepened to reach back to the contact, lying along the
-- camera axis the overshoot was measured on; a hit in front of the contact (a
-- fold over it) is painted as is; a ray through a hole that hits something
-- far behind is dropped, and its mark is taken back. The mock panel is the
-- plane x = 1 (car-local), through the contacts; its hit is moved hitOffset
-- further along the ray. (The reading is taken at the unjittered contact, so
-- it is exactly hitOffset.)
do
  local hitOffset = 0
  mockSurface = function(cam, fwd)
    local t = (1 - cam.x) / fwd.x + hitOffset
    return { x = cam.x + fwd.x * t, y = cam.y + fwd.y * t, z = cam.z + fwd.z * t }
  end
  local hit = { 101, 0, 0.4, -1, 0, 0, "i", 16000, "M", 0, 1, 0, 5 }
  local function impact(offset, seed, events)
    paint.clearStamps()
    for _ = 1, 20 do frame() end
    paint.seedRandom(seed or 1)
    hitOffset = offset
    local l0, c0 = #bakedLog, counters.getDecalData or 0
    paint.ingest(playerVid, events or { hit }, {})
    for _ = 1, 30 do frame() end
    hitOffset = 0
    local r = { n = #bakedLog - l0, calls = (counters.getDecalData or 0) - c0, shallowest = math.huge,
                deepest = 0, deepened = 0, alongNormal = 0 }
    for i = l0 + 1, #bakedLog do
      local l = bakedLog[i]
      r.shallowest, r.deepest = math.min(r.shallowest, l.depth), math.max(r.deepest, l.depth)
      if l.surfaceNormal == false then r.deepened = r.deepened + 1 else r.alongNormal = r.alongNormal + 1 end
    end
    return r
  end
  local r = impact(0.15)
  check(r.n > 0 and r.shallowest >= 2 * 0.15 + 0.08 - 1e-6,
    "a 15 cm overshoot paints, every box reaching back to the contact (shallowest " .. r.shallowest .. ")")
  check(r.deepened == r.n, "every box compensating an overshoot lies along the camera axis, even one already deep enough ("
    .. r.deepened .. "/" .. r.n .. ")")
  check(r.calls == r.n + 1, "the overshoot is read once per projection, not per stamp ("
    .. r.calls .. " captures for " .. r.n .. " layers)")
  r = impact(0)
  check(r.n > 0 and r.deepened == 0, "no overshoot: boxes stay along the surface normal")
  r = impact(-0.3)
  check(r.n > 0 and r.deepened == 0 and r.deepest <= 0.5,
    "a hit in front of the contact (a fold over it) is painted as is (deepest " .. r.deepest .. ")")
  r = impact(0.05)
  check(r.n > 0 and r.deepened == r.n, "a 5 cm overshoot, inside every box's own depth, still turns the box to the camera axis ("
    .. r.deepened .. "/" .. r.n .. ")")
  r = impact(0.01)
  check(r.n > 0 and r.deepened == 0, "a 1 cm overshoot (a node just off the skin) is left alone")
  r = impact(0.24)
  check(r.n > 0 and r.deepened == r.n and r.shallowest >= 0.56 - 1e-6, "a 24 cm overshoot still paints, compensated")
  check(impact(0.26).n == 0, "a 26 cm overshoot is a hole: nothing painted")
  check(impact(2.0).n == 0, "an impact whose ray went through a hole 2 m deep paints nothing")

  -- The dropped impact's claim is taken back: a later hit there paints just
  -- like one on fresh paint (its spots and deep mark used to block the haze,
  -- streaks and chips).
  local fresh = impact(0, 77).n
  impact(2.0)
  check(#paint.getMarks() == 0, "a mark none of whose stamps baked is taken back")
  paint.seedRandom(77)
  local l0 = #bakedLog
  paint.ingest(playerVid, { hit }, {})
  for _ = 1, 30 do frame() end
  check(fresh > 0 and #bakedLog - l0 == fresh, "a hit where a hole impact was dropped paints like fresh paint ("
    .. (#bakedLog - l0) .. " vs " .. fresh .. " layers)")

  -- Two impacts sharing a projection: the reading is only taken where the
  -- camera is aimed (one of them). If that one went through a hole, the
  -- other still paints (they used to be dropped on the shared reading); if it
  -- shows a crush, a close neighbour borrows the compensation, a far one
  -- (intact skin, maybe) doesn't.
  local function pairAt(dy, f1) return { { 101, 0, 0.4, -1, 0, 0, "i", f1 or 16000, "M", 0, 1, 0, 5 },
                                          { 101, dy, 0.4, -1, 0, 0, "i", 16000, "M", 0, 1, 0, 5 } } end
  r = impact(2.0, nil, pairAt(0.25))
  check(r.n > 0 and #paint.getMarks() == 1, "the other impact under a hole reading still paints ("
    .. r.n .. " layers, " .. #paint.getMarks() .. " marks)")
  -- (A lighter first hit, so its marks don't keep the second's off the spot.)
  r = impact(0.15, nil, pairAt(0.1, 6800))
  check(#paint.getMarks() == 2 and r.deepened == r.n, "a neighbour 10 cm off borrows the crush compensation ("
    .. r.deepened .. "/" .. r.n .. ", " .. #paint.getMarks() .. " marks)")
  r = impact(0.15, nil, pairAt(0.5))
  check(#paint.getMarks() == 2 and r.deepened > 0 and r.deepened < r.n, "a neighbour 50 cm off keeps a normal box ("
    .. r.deepened .. " compensated of " .. r.n .. ")")

  -- A job that throws after capturing some layers bakes none of them and
  -- takes its claim back (claims used to settle at capture).
  local real = decalProjection.getDecalData
  local calls = 0
  decalProjection.getDecalData = function(self, ...)
    calls = calls + 1
    if calls == 3 then error("simulated capture failure") end
    return real(self, ...)
  end
  r = impact(0, nil, { { 101, 0, 0.4, -1, 0, 0, "i", 16000, "M" } })
  decalProjection.getDecalData = real
  check(r.n == 0 and #paint.getMarks() == 0, "a job that fails mid-capture bakes nothing and takes its claim back ("
    .. r.n .. " layers, " .. #paint.getMarks() .. " marks)")
  -- And a bake that fails takes its claim back too.
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local realBake = decalProjection.bakeLayers
  decalProjection.bakeLayers = function() error("simulated bake failure") end
  paint.ingest(playerVid, { hit }, {})
  for _ = 1, 30 do frame() end
  decalProjection.bakeLayers = realBake
  check(#paint.getMarks() == 0, "a failed bake takes its claim back")
  for i = #logLines, 1, -1 do
    if logLines[i]:find("simulated", 1, true) then table.remove(logLines, i) end
  end

  -- A stamp outside the projection's view is dropped, and its claim taken
  -- back: two light glancing hits 60 cm apart share a close camera.
  local m0 = paint.getStats().stamp.stampsSkippedMissed
  r = impact(0, nil, { { 101, 0, 0.4, -1, 0, 0, "i", 2800, "M", 0, 1, 0, 5 },
                       { 101, 0.6, 0.4, -1, 0, 0, "i", 2800, "M", 0, 1, 0, 5 } })
  check(r.n > 0 and paint.getStats().stamp.stampsSkippedMissed > m0 and #paint.getMarks() == 1,
    "a stamp outside the projection is dropped and its claim taken back (" .. #paint.getMarks() .. " marks)")
  mockSurface = nil
end

-- 6h3) A post's side face raking a bumper's front corner: the contact normal
-- (the post's) aims the camera sideways, which grazes past the front face and
-- reads as a hole. The projection is re-aimed once from the hull face nearest
-- the contact (the front), which finds the skin.
do
  mockSurface = function(cam, fwd)
    if math.abs(fwd.y) > 0.7 then
      local t = (-2.3 - cam.y) / fwd.y   -- the front face, y = -2.3
      return { x = cam.x + fwd.x * t, y = -2.3, z = cam.z + fwd.z * t }
    end
    return { x = cam.x + fwd.x * 3, y = cam.y + fwd.y * 3, z = cam.z + fwd.z * 3 }   -- grazed past
  end
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local st0 = paint.getStats().stamp
  local r0, h0 = st0.reaims, st0.reaimsHelped
  local l0 = #bakedLog
  paint.ingest(playerVid, { { 100.6, -2.3, 0.4, -1, 0, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  local st = paint.getStats().stamp
  check(st.reaims > r0 and st.reaimsHelped == h0 + 1 and #bakedLog > l0 and #paint.getMarks() == 1,
    "a sideways ray past a front corner is re-aimed from the front and paints (" .. (#bakedLog - l0) .. " layers)")
  mockSurface = nil
end

-- 6h3b) A slide that moved mostly into the panel (a front face pushed into a
-- post) was pressed, not dragged: a scuff, no band along the dip.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local l0 = counters.bakeLayers
  -- normal -x (the side panel), movement mostly along x with a little z
  paint.ingest(playerVid, {}, { { { 99.0, 0.4, 0.5, -1, 0, 0 }, { 98.9, 0.4, 0.52, -1, 0, 0 },
                                  { 98.8, 0.4, 0.54, -1, 0, 0 }, m = "M", f = 5000 } })
  for _ = 1, 30 do frame() end
  local band = false
  for _, m in ipairs(paint.getMarks()) do if m[7] == "s" then band = true end end
  check(counters.bakeLayers > l0 and not band, "a slide pushed into the panel scuffs without a band")
end

-- 6h3c) A press (a slide pushed into the panel) claims like any hit: dropped
-- before it projects, it frees its spot; baked, it is on the mark log.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local function press()
    return { { 99.0, 0.4, 0.5, -1, 0, 0 }, { 98.9, 0.4, 0.52, -1, 0, 0 }, { 98.8, 0.4, 0.54, -1, 0, 0 },
             m = "M", f = 9000 }
  end
  paint.ingest(playerVid, {}, { press() })
  paint.ingest(playerVid, {}, { press() })
  hasPlayer = false
  frame()
  hasPlayer = true
  for _ = 1, 20 do frame() end
  local l0 = counters.bakeLayers
  paint.ingest(playerVid, {}, { press() })
  for _ = 1, 30 do frame() end
  check(counters.bakeLayers > l0 and #paint.getMarks() == 1, "a dropped press frees its spot; a baked one is logged ("
    .. (counters.bakeLayers - l0) .. " layers, " .. #paint.getMarks() .. " marks)")
end

-- 6h3d) A drag is captured turned along it as seen by the camera: along the
-- door it lies horizontal on screen, up the door vertical.
do
  local function angleOf(dx, dy, dz)
    paint.clearStamps()
    for _ = 1, 20 do frame() end
    local l0 = #bakedLog
    paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 9000, "M", dx, dy, dz, 5 } }, {})
    for _ = 1, 30 do frame() end
    return bakedLog[l0 + 1] and bakedLog[l0 + 1].rot
  end
  local h, v = angleOf(0, 1, 0), angleOf(0, 0, 1)
  check(h and math.abs(math.sin(h)) < 0.3, "a drag along the door is captured horizontal (" .. tostring(h) .. ")")
  check(v and math.abs(math.cos(v)) < 0.3, "a drag up the door is captured vertical (" .. tostring(v) .. ")")
end

-- 6h4) A claim keeps only what reached the canvas: a hard glancing hit whose
-- gouge core never captures leaves a primer-deep mark, not a bare-metal one
-- (which would keep later marks off it).
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local real = decalProjection.getDecalData
  local calls = 0
  decalProjection.getDecalData = function(self, ...)
    calls = calls + 1
    if calls == 6 then return nil end   -- probe, haze, streak, chips, rim, CORE
    return real(self, ...)
  end
  paint.seedRandom(1)
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 21000, "M", 0, 1, 0, 5 } }, {})
  for _ = 1, 30 do frame() end
  decalProjection.getDecalData = real
  local m = paint.getMarks()[1]
  check(m and m[8] == 3, "a mark whose core never landed keeps the depth that baked (" .. tostring(m and m[8]) .. ")")
end

-- 6h5) A slide band none of whose layers is captured takes its claim back.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local function slide()
    return { { 99, 0.4, 0.5, -1, 0, 0 }, { 99, 0.6, 0.5, -1, 0, 0 }, { 99, 0.8, 0.5, -1, 0, 0 }, m = "M", f = 1200 }
  end
  local real = decalProjection.getDecalData
  decalProjection.getDecalData = function() return nil end
  paint.ingest(playerVid, {}, { slide() })
  for _ = 1, 30 do frame() end
  decalProjection.getDecalData = real
  check(#paint.getMarks() == 0, "a band that never captured takes its claim back")
  for i = #logLines, 1, -1 do
    if logLines[i]:find("getDecalData returned nil", 1, true) then table.remove(logLines, i) end
  end
end

-- 6h6) Stamps dropped before they project (no player car that frame) settle:
-- the spot is free for the next hit.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local hit = { 101, 0, 0.4, -1, 0, 0, "i", 16000, "M" }
  paint.ingest(playerVid, { hit }, {})
  paint.ingest(playerVid, { hit }, {})       -- two passes: the impact spot is full
  hasPlayer = false
  frame()
  hasPlayer = true
  for _ = 1, 20 do frame() end
  local l0 = counters.bakeLayers
  paint.ingest(playerVid, { hit }, {})
  for _ = 1, 30 do frame() end
  check(#paint.getMarks() == 1 and counters.bakeLayers > l0, "dropped stamps free their spot for the next hit")
end

-- 6h7) Contacts facing different ways (a bumper's front and side, 10 cm
-- apart) get a projection each.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local p0 = counters.projects
  paint.ingest(playerVid, { { 100.9, -2.3, 0.4, -1, 0, 0, "i", 16000, "M" },
                            { 100.9, -2.2, 0.4, 0, 1, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  check(counters.projects - p0 == 2, "a front and a side contact project separately (" .. (counters.projects - p0) .. ")")
end

-- 6h7b) Two contacts at a corner, 10 deg apart either side of 45 deg, want
-- different camera axes: a projection each.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local p0 = counters.projects
  local c40, s40, c50, s50 = math.cos(math.rad(40)), math.sin(math.rad(40)), math.cos(math.rad(50)), math.sin(math.rad(50))
  paint.ingest(playerVid, { { 100.9, 2.4, 0.4, -c40, -s40, 0, "i", 16000, "M" },
                            { 100.9, 2.3, 0.4, -c50, -s50, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  check(counters.projects - p0 == 2, "corner contacts either side of 45 deg project separately ("
    .. (counters.projects - p0) .. ")")
end

-- 6h7b2) A contact on a panel's bottom edge: the centre ray slips under it
-- (a hole); aimed 8 cm in toward the car's middle it finds the skin.
do
  mockSurface = function(cam, fwd)
    if math.abs(fwd.x) > 0.7 and cam.z >= 0.42 then   -- the door, from z = 0.42 up
      local t = (1 - cam.x) / fwd.x
      return { x = 1, y = cam.y + fwd.y * t, z = cam.z + fwd.z * t }
    end
    return { x = cam.x + fwd.x * 3, y = cam.y + fwd.y * 3, z = cam.z + fwd.z * 3 }
  end
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local l0 = #bakedLog
  paint.ingest(playerVid, { { 101, 0, 0.40, -1, 0, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  mockSurface = nil
  check(#bakedLog > l0 and #paint.getMarks() == 1, "a contact on a panel's edge is found by aiming just inside it ("
    .. (#bakedLog - l0) .. " layers)")
end

-- 6h7c) A re-aim that finds nothing either goes back to the camera the
-- contacts face: the cluster's other stamps are captured from it.
do
  mockSurface = function(cam, fwd) return { x = cam.x + fwd.x * 3, y = cam.y + fwd.y * 3, z = cam.z + fwd.z * 3 } end
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local l0 = #bakedLog
  paint.ingest(playerVid, { { 100.6, -2.3, 0.4, -1, 0, 0, "i", 16000, "M" },
                            { 100.6, -2.0, 0.4, -1, 0, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  mockSurface = nil
  local ok, n = true, 0
  for i = l0 + 1, #bakedLog do
    n = n + 1
    local f = bakedLog[i].camFwd
    if not f or math.abs(f.x) < 0.9 then ok = false end
  end
  check(n > 0 and ok, "after a fruitless re-aim the other stamps paint from the contacts' camera (" .. n .. " layers)")
end

-- 6h8) A hit 30 cm from a directed mark takes its direction (strokes of
-- neighbouring marks crossing read as a comb or an asterisk).
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 9000, "M", 0, 1, 0, 5 } }, {})
  paint.ingest(playerVid, { { 101, 0.3, 0.4, -1, 0, 0, "i", 9000, "M", 0, 0, 1, 5 } }, {})
  for _ = 1, 30 do frame() end
  local ms = paint.getMarks()
  local a, b = ms[1], ms[2]
  local dot = a and b and math.abs(a[10] * b[10] + a[11] * b[11] + a[12] * b[12]) or 0
  check(dot > 0.99, "a neighbour 30 cm off shares the direction (|dot| " .. string.format("%.2f", dot) .. ")")
end

-- 6h9) Brief slides have their own spots: a burst of them at a node doesn't
-- use up a real impact's.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local brief = { 101, 0, 0.4, -1, 0, 0, "s", 9000, "M", 0, 1, 0, 3 }
  paint.ingest(playerVid, { brief, brief, brief }, {})
  for _ = 1, 30 do frame() end
  local l0 = counters.bakeLayers
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  check(counters.bakeLayers > l0, "brief slides don't use up a real impact's spot")
end

-- 6h9b) Brief slides keep off a real impact's haze and streak cells too.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  -- (A light brief slide: a primer-deep one rightly keeps a later haze off.)
  -- (Both well inside one 30 cm cell, jitter included.)
  local brief = { 101, 0.15, 0.45, -1, 0, 0, "s", 4000, "M", 0, 1, 0, 3 }
  paint.ingest(playerVid, { brief }, {})
  for _ = 1, 30 do frame() end
  local b0 = #brushLog
  paint.ingest(playerVid, { { 101, 0.17, 0.45, -1, 0, 0, "i", 9000, "M", 0, 1, 0, 3 } }, {})
  for _ = 1, 30 do frame() end
  local haze = false
  for i = b0 + 1, #brushLog do if brushLog[i]:find("haze", 1, true) then haze = true end end
  check(haze, "a real glancing hit after a brief slide there still gets its haze")
end

-- 6i) A slide refused because the projection backlog is full doesn't use up
-- its spot.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local function slideAt(y0)
    return { { 99, y0, 0.5, -1, 0, 0 }, { 99, y0 + 0.2, 0.5, -1, 0, 0 }, { 99, y0 + 0.4, 0.5, -1, 0, 0 },
             m = "M", f = 1200 }
  end
  local fill = {}
  for i = 1, 80 do fill[i] = slideAt(-20 + i * 1.5) end  -- far apart: a job each
  paint.ingest(playerVid, {}, fill)
  local d0 = paint.getStats().stamp.jobsDropped
  paint.ingest(playerVid, {}, { slideAt(200), slideAt(200) })
  check(paint.getStats().stamp.jobsDropped >= d0 + 2, "slides are refused while the backlog is full")
  for _ = 1, 300 do frame() end
  local l0 = counters.bakeLayers
  paint.ingest(playerVid, {}, { slideAt(200) })
  for _ = 1, 30 do frame() end
  check(counters.bakeLayers > l0, "a slide refused at a full backlog doesn't use up its spot")
end

-- 6j) A later hit doesn't repaint an earlier gouge's core back to primer.
do
  paint.clearStamps()
  for _ = 1, 20 do frame() end
  local b0 = #brushLog
  paint.ingest(playerVid, { { 101, 0, 0.4, -1, 0, 0, "i", 21000, "M", 0, 1, 0, 5 } }, {})
  for _ = 1, 30 do frame() end
  local gouged = false
  for i = b0 + 1, #brushLog do if brushLog[i]:find("gouge", 1, true) then gouged = true end end
  b0 = #brushLog
  paint.ingest(playerVid, { { 101, 0.02, 0.4, -1, 0, 0, "i", 16000, "M" } }, {})
  for _ = 1, 30 do frame() end
  local chips = false
  for i = b0 + 1, #brushLog do if brushLog[i]:find("chips", 1, true) then chips = true end end
  check(gouged and not chips, "primer chips skip an earlier gouge's core")
end

-- 7) Debug panel draws without errors and the report builds.
paint.toggleUI()
local ok3, err3 = pcall(frame)
check(ok3, "debug panel draws: " .. tostring(err3))
check(type(paint.buildDebugReport()) == "string", "debug report builds")

-- 8) Unload/reload of the extension doesn't error, and leaves the skin
-- material un-split in the safe colour-only state.
local ok4, err4 = pcall(paint.onExtensionUnloaded)
check(ok4, "onExtensionUnloaded runs cleanly: " .. tostring(err4))
check(f.activeLayers[0] == "2" and f.opacityMap[2] == "", "unload removes the damage layer")
check(f.metallicMap[1] == "/art/dynamicDecals/textures/_zero.png"
  and f.roughnessMap[1] == "/art/dynamicDecals/textures/_paint_roughness.png",
  "unload leaves static factory metallic/roughness on the paint stage")

for _, l in ipairs(logLines) do
  if l:sub(1, 1) == "E" then check(false, "error logged: " .. l) end
end

print(string.format("%d passed, %d failed  (projects=%d bakes=%d layers=%d composites=%d)",
  passes, failures, counters.projects, counters.bakes, counters.bakeLayers, counters.combines))
os.exit(failures == 0 and 0 or 1)
