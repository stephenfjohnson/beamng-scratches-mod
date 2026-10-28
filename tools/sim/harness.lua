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
function Mx:getColumn(i) return self.c[i] end
function Mx:setColumn(i, v) self.c[i] = vec3(v.x, v.y, v.z); return self end
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

local Q = {}; Q.__index = Q
function quat(m)
  local rotation = m:copy(); rotation:setColumn(3, vec3(0, 0, 0))
  return setmetatable({m = rotation}, Q)
end
function Q:inversed() return quat(self.m:fullInverse()) end
Q.__mul = function(q, p) return q.m:mulP3F(p) end
local mockNodes = {}

function Point4F(r, g, b, a) return {x = r, y = g, z = b, w = a} end
function Point2F(x, y) return {x = x, y = y} end

-- Player vehicle: translated 100 m along x so world != local.
local playerVid = 1001
local refM = MatrixF(); refM:setColumn(3, vec3(100, 0, 0))
local vehicle = {
  JBeam = "pickup",
  getId = function() return playerVid end,
  getRefNodeMatrix = function() return refM:copy() end,
  getNodePosition = function(self, id) return mockNodes[id] or vec3(0, 0, 0.6) end,
  getDecalProjectionShape = function() return {} end,
  getSpawnLocalAABB = function()
    return {minExtents = vec3(-1, -2.5, 0), maxExtents = vec3(1, 2.5, 1.8)}
  end,
  queueLuaCommand = function() end,
}
local hasPlayer = true
function getPlayerVehicle() return hasPlayer and vehicle or nil end
function getCameraProjMatrix() return MatrixF() end
function getVehicleColor() return "0.8 0.1 0.1 1 0 0 0 0" end

-- Materials: one body material with stage 1 on the dynamic canvas and a
-- factory stage 0 that must be left alone.
local matReloads = 0
local skinMat = {
  fields = {
    metallicMap  = {[0] = "vehicles/pickup/pickup_m.png", "@DynamicTextureMetallic", "", ""},
    roughnessMap = {[0] = "vehicles/pickup/pickup_r.png", "@DynamicTextureRoughness", "", ""},
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
local decalScale = vec3(0.1, 1, 0.1)
local decalRotation, decalBrush = 0, ""
local bakedLayers = {}
local usedLayerUids = {}
local syncedWorldTransform
function decalProjection:projectDynamicDecals()
  counters.projects = counters.projects + 1
  counters.projectsThisFrame = counters.projectsThisFrame + 1
end
function decalProjection:getDecalData()
  return { cursorPosScreenUv = {x = 0.5, y = 0.5}, decalPos = {x = 0, y = 0, z = 0},
           decalScale = vec3(decalScale.x, decalScale.y, decalScale.z),
           decalRotation = decalRotation, colorTexturePath = decalBrush }
end
function decalProjection:bakeLayers(list)
  for _, layer in ipairs(list) do
    assert(layer.uid and not usedLayerUids[layer.uid], "engine layer UID must not repeat across seed resets or hot reloads")
    usedLayerUids[layer.uid] = true
    if layer.decalNorm then
      assert(getmetatable(layer.decalPos) == V and getmetatable(layer.decalNorm) == V,
        "explicit decal coordinates require native vec3 objects")
      for axis=0,3 do
        assert(syncedWorldTransform and (syncedWorldTransform:getColumn(axis)-refM:getColumn(axis)):length()<1e-6,
          "bake must refresh engine transforms after a deferred projection")
      end
    end
  end
  for _, layer in ipairs(list) do bakedLayers[#bakedLayers + 1] = layer end
  counters.bakes = counters.bakes + 1
  counters.bakeLayers = counters.bakeLayers + #list
  counters.bakesThisFrame = (counters.bakesThisFrame or 0) + 1
  if #list > (counters.maxBakeLayers or 0) then counters.maxBakeLayers = #list end
end
function decalProjection:clearBakedTextures() counters.clears = counters.clears + 1 end
function decalProjection:flushDynamicTextures() end
function decalProjection:combineTextures() counters.combines = counters.combines + 1 end
function decalProjection:setShape() end
function decalProjection:setWorldTransform(m) syncedWorldTransform = m:copy() end
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
api.getShapeMeshes = function() return {pickup_body=true,pickup_door_L=true,pickup_bed=true} end
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
for _, n in ipairs({"setDecalTexturePath", "setMetallicIntensity", "setRoughnessIntensity",
                    "setDecalColor", "setDecalScale", "setDecalRotation", "setUseSurfaceNormal"}) do
  api[n] = function() end
end
api.setDecalScale = function(scale) decalScale = scale end
api.setDecalRotation = function(rotation) decalRotation = rotation end
api.setDecalTexturePath = function(channel, path) if channel == "color" then decalBrush = path end end
api.setDecalLocalPos = function(decal, p) decal.cursorPosScreenUv = {x = 0.5 + p.x * 0.001, y = 0.5 + p.y * 0.001} end

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
core_vehicle_manager = { getPlayerVehicleData = function() return {vdata = v and v.data} end }

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
check(skinMat.fields.metallicMap[1] == "/art/dynamicDecals/textures/_zero.png",
  "restoreFactoryMR repoints the @DynamicTexture metallic stage")
check(skinMat.fields.metallicMap[0] == "vehicles/pickup/pickup_m.png",
  "restoreFactoryMR leaves the factory stage-0 metallic map alone")
check(matReloads == 1, "material reloaded exactly once at setup (got " .. matReloads .. ")")
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
  getRotation = function() return refM end,
  getPosition = function() return refM:getColumn(3) end,
  getNodePosition = function(self, id) return vehicle:getNodePosition(id) end,
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
} } }
v.data.flexbodies = {{mesh="pickup_door_L",partOrigin="pickup_door_L"}}
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
  mockNodes[id] = vec3(x, y, z) - refM:getColumn(3)
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
  contact(10 + (i % 2), 100 + (i % 8) * 0.9, (i % 5) * 0.9 - 2, 0.3, 0, 5000)
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
contact(10, 0/0, 0, 0.3, 0, 5000)
obj.simTime = obj.simTime + 0.5
contact(11, 101, 0.5, 0.3, 0, 5000)
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
paint.ingest(playerVid, { {100, 0, 0.5, 0, 0, 1, "i", 6000}, {103, 2, 0.5, 0, 0, 1, "i", 6000} }, nil)
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
for _ = 1, 4 do paint.ingest(playerVid, { {150, 1, 0.5, 0, 0, 1, "i", 6000} }, nil) end
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
local mergedLayersBefore = counters.bakeLayers
paint.ingest(playerVid, nil, {
  { {100.0, 0.0, 0.6, 0, 0, 1}, {100.4, 0.0, 0.6, 0, 0, 1} },
  { {100.0, 0.1, 0.6, 0, 0, 1}, {100.4, 0.1, 0.6, 0, 0, 1} },
})
for _ = 1, 20 do frame() end
check(paint.getStats().stamp.streamsMerged == m0 + 1 and counters.projects == pr0 + 1,
  "adjacent slides share one projection (" .. (counters.projects - pr0) .. " projections)")
check(counters.bakeLayers - mergedLayersBefore == 4,
  "two merged bands each bake one haze and one scrape (got " .. (counters.bakeLayers - mergedLayersBefore) .. ")")

-- Continuous input must still bake, even if every frame is eligible to
-- project (zero interval, or a frame slower than the default interval).
for _, timing in ipairs({{0, 1 / 60}, {0.2, 0.25}}) do
  paint.clearStamps()
  frame()
  paint.setFlushInterval(timing[1])
  local bakedBefore, maxWaiting = counters.bakeLayers, 0
  for i = 1, 60 do
    for j = 1, 12 do
      paint.stampAtLocal(vec3(0, 0, 0.6), vec3(0, 0, 1), {noJitter = true})
    end
    frame(timing[2])
    maxWaiting = math.max(maxWaiting, paint.getStats().queue.bake)
  end
  check(counters.bakeLayers > bakedBefore, "continuous input makes bake progress at interval " .. timing[1])
  check(maxWaiting <= paint.getStats().config.aggregateCap,
    "bake backlog stays within one batch at interval " .. timing[1] .. " (max " .. maxWaiting .. ")")
  for _ = 1, 200 do frame(timing[2]) end
  local q = paint.getStats().queue
  check(q.bake == 0 and q.jobs == 0 and q.stamps == 0, "overload backlog drains completely")
end
paint.setFlushInterval(0.2)
check((counters.projectAndBakeFrames or 0) == 0, "overload keeps projection and baking on separate frames")
check(counters.maxBakeLayers <= 6, "overload preserves six-layer bake budget")

-- 5) Vehicle switch mid-backlog: no error, queue dropped (the WIP crash).
paint.ingest(playerVid, { {100, 0, 0.5, 0, 0, 1, "i", 6000} }, nil)
local ok, err = pcall(paint.onVehicleSwitched, playerVid, 2002, 0)
check(ok, "onVehicleSwitched runs cleanly: " .. tostring(err))
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

-- A contact stays armed through a soft onset, fires once when force ramps
-- up, and only re-arms after separation. Force chatter is not a new impact.
detect.onReset()
runGE()
obj.simTime = obj.simTime + 1
contact(10, 100, 0, 0.6, 0, 100)
obj.simTime = obj.simTime + dtPhys
contact(10, 100, 0, 0.6, 0, 12000)
check(detStats().impactEvents == 1, "soft-to-hard onset registers its first qualifying impact")
for i = 1, 1000 do
  obj.simTime = obj.simTime + dtPhys
  contact(10, 100, 0, 0.6, 0, i % 2 == 0 and 12000 or 100)
end
check(detStats().impactEvents == 1, "sustained contact and force chatter do not repeat impacts")
obj.simTime = obj.simTime + 0.2
contact(10, 100, 0, 0.6, 0, 12000)
check(detStats().impactEvents == 2, "separation re-arms the impact")
detect.onReset()
runGE()
obj.simTime = 0
contact(10, 100, 0, 0.6, 0, 12000)
check(detStats().impactEvents == 1, "reset re-arms contact even at simulation time zero")

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

-- 7) Debug panel draws without errors and the report builds.
paint.toggleUI()
local ok3, err3 = pcall(frame)
check(ok3, "debug panel draws: " .. tostring(err3))
check(type(paint.buildDebugReport()) == "string", "debug report builds")

-- Diagnostics remain usable when setup is pending, the car is skipped,
-- or no player vehicle exists. Toggle must also load ImGui in these states.
do
  paint.toggleUI() -- hide before testing a fresh show
  local savedIm, savedLoad = ui_imgui, extensions.load
  local begins, imguiLoads = 0, 0
  savedIm.Begin = function() begins = begins + 1; return true end
  extensions.load = function(name)
    if name == "ui_imgui" then ui_imgui = savedIm; imguiLoads = imguiLoads + 1 end
  end
  paint.onVehicleSwitched(playerVid, playerVid, 0)
  partConfig.partsTree.children[1].chosenPartName = "pickup_skin_livery"
  ui_imgui = nil
  paint.toggleUI()
  for _ = 1, 3 do frame() end
  check(imguiLoads == 1, "showing diagnostics loads ImGui without a ready painter")
  check(not paint.getStats().ready and begins == 3, "panel draws on every skipped-livery frame")
  check(partConfig.partsTree.children[1].chosenPartName == "pickup_skin_livery", "diagnostics preserve the livery")
  check(paint.buildDebugReport():find("painter ready: false", 1, true) ~= nil, "report remains available for a skipped vehicle")
  hasPlayer = false
  paint.onVehicleSwitched(playerVid, nil, 0)
  begins = 0
  for _ = 1, 3 do frame() end
  check(begins == 3, "panel draws while waiting for a player vehicle")
  hasPlayer = true
  partConfig.partsTree.children[1].chosenPartName = ""
  extensions.load = savedLoad
  ui_imgui = savedIm
  for _ = 1, 70 do frame() end
  check(paint.getStats().ready, "painter recovers when a supported player vehicle returns")
end

-- Contact accuracy: a physics sample must follow its node through delayed
-- delivery, rigid rotation/translation and deformation before the bake.
do
  detect.onReset(); runGE()
  paint.clearStamps(); frame()
  paint.setFlushInterval(0)
  local initialPose = MatrixF()
  initialPose:setColumn(0,vec3(0,1,0)):setColumn(1,vec3(-1,0,0)):setColumn(3,vec3(400,-200,30))
  refM = initialPose
  local localNode, offset = vec3(0.7,0.2,1.2), vec3(0.005,0.01,0)
  local rot = refM:copy(); rot:setColumn(3,vec3(0,0,0))
  mockNodes[10] = rot:mulP3F(localNode)
  obj.simTime = obj.simTime + 1
  _G.onNodeCollision(10, refM:mulP3F(localNode+offset), rot:mulP3F(vec3(0,0,-1)),
    vec3(0,0,0), 0, rot:mulP3F(vec3(1,0,0)), 0, 0, 6000, 0.01, ASPHALT, METAL)
  detect.updateGFX(1/60)
  local captured, originalIngest = nil, paint.ingestContacts
  paint.ingestContacts = function(vid, records) captured = records; originalIngest(vid,records) end
  refM = MatrixF()
  refM:setColumn(1,vec3(0,-1,0)):setColumn(2,vec3(0,0,-1)):setColumn(3,vec3(-600,700,20))
  rot = refM:copy(); rot:setColumn(3,vec3(0,0,0))
  mockNodes[10] = rot:mulP3F(localNode)
  runGE()
  paint.ingestContacts = originalIngest
  check(captured and #captured == 1 and captured[1][1] == 10, "physics packet identifies the contacting node")
  check(captured and math.abs(captured[1][2]-.005)<1e-6 and math.abs(captured[1][3]-.01)<1e-6,
    "contact offset captured in the collision-time rotation frame")
  check(captured and captured[1][7] == 1 and captured[1][8] == 1 and captured[1][9] == 0,
    "outward normal and slip direction survive rotation and deferred delivery")
  frame()
  check(paint.getStats().queue.bake == 1, "anchored contact reaches deferred bake queue")
  localNode = localNode + vec3(.17,-.03,.02)
  refM = initialPose:copy(); refM:setColumn(3,vec3(-800,-40,10))
  rot = refM:copy(); rot:setColumn(3,vec3(0,0,0))
  mockNodes[10] = rot:mulP3F(localNode)
  frame()
  local layer = bakedLayers[#bakedLayers]
  check((layer.decalPos - (localNode+offset)):length()<1e-6, "bake follows node deformation after projection")
  check((layer.decalNorm-vec3(0,0,1)):length()<1e-6, "rollover retains the roof-facing local normal")
  check(getmetatable(layer.decalPos)==V and getmetatable(layer.decalNorm)==V, "pinned coordinates use native vectors")
  check(#layer.meshes.pickup==1 and layer.meshes.pickup[1]=='pickup_door_L', "contact cannot project onto the bed or other parts")
  check(layer.decalScale.y==.04 and layer.mirrored==false, "contact volume is shallow and never mirrored")
  check(layer.decalScale.x<=.14 and layer.decalScale.z<=.14, "impact footprint is contact sized")

  refM = MatrixF(); refM:setColumn(3,vec3(100,0,0))
  mockNodes[10],mockNodes[11] = vec3(0,0,.6),vec3(.1,0,.6)
  local function record(id,nz) return {id,0,0,0,0,0,nz or 1,1,0,0,'s',6000,1} end
  paint.clearStamps(); frame(); paint.resetPaintStats()
  local invalid = {record(20), record(999), record(10,0), record(10),record(10),record(10),false}
  invalid[4][2]=.2; invalid[5][13]=-1; invalid[6][5]=0/0
  paint.ingestContacts(playerVid,invalid)
  check(paint.getStats().stamp.contactsRejected == 7, "unknown ownership, bad normals, excessive offsets and malformed packets fail closed")
  frame(); frame()
  check(paint.getStats().stamp.projectsIssued == 0, "rejected contacts never project onto a nearby painted part")
  paint.ingestContacts(4242,{record(10)})
  check(paint.getStats().stamp.foreignDropped == 1, "foreign node-based packet is rejected")

  paint.ingestContacts(playerVid,{record(10,1),record(11,-1)})
  frame(); frame()
  check(paint.getStats().stamp.projectsIssued == 2, "opposite-facing contacts never share a projection camera")

  local signatures = {}
  local originalRandom = math.random
  math.random = function() error('painter must not consume the game RNG') end
  for seed=1,8 do
    for pass=1,2 do
      -- Disturb both RNG and recent-brush history differently before replay.
      for noise=1,pass+1 do
        paint.clearStamps(); frame()
        paint.ingestContacts(playerVid,{record(10)})
        frame(); frame()
      end
      paint.clearStamps(); frame(); paint.setRandomSeed(seed)
      paint.ingestContacts(playerVid,{record(10)})
      frame(); frame()
      layer = bakedLayers[#bakedLayers]
      signatures[pass] = layer.colorTexturePath .. ':' .. layer.decalRotation .. ':' .. layer.decalScale.x
    end
    check(signatures[1]==signatures[2], "seed " .. seed .. " repeats independently of brush history")
  end
  math.random = originalRandom

  paint.clearStamps(); frame(); paint.resetPaintStats()
  local realBake = decalProjection.bakeLayers
  decalProjection.bakeLayers = function() error('simulated native bake failure') end
  paint.ingestContacts(playerVid,{record(10)})
  local bakeOk = pcall(function() frame(); frame() end)
  decalProjection.bakeLayers = realBake
  check(bakeOk and paint.getStats().stamp.bakesFailed==1, "native bake failure is observable without aborting the frame")
  check(paint.getStats().perf.bakeLayersTotal==0 and paint.getStats().queue.bake==0, "failed bake is not counted as visible work or retried forever")
  paint.ingestContacts(playerVid,{record(11)})
  frame(); frame()
  check(paint.getStats().perf.bakeLayersTotal==1, "painting recovers after a failed bake")
  for i=#logLines,1,-1 do
    if logLines[i]:find('simulated native bake failure',1,true) then table.remove(logLines,i) end
  end
  paint.resetPaintStats()
  check(paint.getStats().stamp.bakesFailed==0 and paint.getStats().stamp.contactsRejected==0, "accuracy error counters reset between test runs")
  paint.setFlushInterval(.2)
end

-- 8) Unload/reload of the extension doesn't error.
local ok4, err4 = pcall(paint.onExtensionUnloaded)
check(ok4, "onExtensionUnloaded runs cleanly: " .. tostring(err4))

local reloadUids = {}
for reload=1,2 do
  paint = dofile(ROOT .. "/lua/ge/extensions/scratches/paint.lua")
  scratches_paint = paint
  paint.onExtensionLoaded()
  for _=1,5 do frame() end
  paint.setRandomSeed(1977)
  paint.stampAtLocal(vec3(0,0,.6),vec3(0,0,1),{noJitter=true})
  for _=1,20 do frame() end
  reloadUids[reload] = bakedLayers[#bakedLayers].uid
  paint.onExtensionUnloaded()
end
check(reloadUids[1]~=reloadUids[2], "same-seed hot reloads use distinct native layer identities")

for _, l in ipairs(logLines) do
  if l:sub(1, 1) == "E" then check(false, "error logged: " .. l) end
end

print(string.format("%d passed, %d failed  (projects=%d bakes=%d layers=%d composites=%d)",
  passes, failures, counters.projects, counters.bakes, counters.bakeLayers, counters.combines))
os.exit(failures == 0 and 0 or 1)
