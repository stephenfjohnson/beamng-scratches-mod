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
end, findClassObjects = function() return {} end }
-- The generic body adapter's orphan sweep runs every session; nothing to collect here.
getAllVehicles = function() return hasPlayer and {{getId=function() return 1 end,getMaterialNames=function() return {} end}} or {} end

-- Dynamic-decals projection + API mocks.
local counters = { projects = 0, bakes = 0, bakeLayers = 0, combines = 0, apiUpdates = 0,
                   maxProjectsInFrame = 0, projectsThisFrame = 0, clears = 0 }
counters.tex = {}
local decalProjection = {}
function decalProjection:projectDynamicDecals()
  counters.projects = counters.projects + 1
  counters.projectsThisFrame = counters.projectsThisFrame + 1
end
function decalProjection:getDecalData()
  return { cursorPosScreenUv = {x = 0.5, y = 0.5}, decalPos = {x = 0, y = 0, z = 0},
    decalRotation=counters.rotation,decalScale=counters.scale,
    colorTex=counters.tex.color,metalTex=counters.tex.metallic,roughTex=counters.tex.roughness }
end
function decalProjection:bakeLayers(list)
  for _,layer in ipairs(list) do if layer.name=='soil' then counters.lastSoilLayer=layer end end
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
for _, n in ipairs({"setDecalTexturePath", "setMetallicIntensity", "setRoughnessIntensity",
                    "setDecalColor", "setDecalScale", "setDecalRotation", "setUseSurfaceNormal"}) do
  api[n] = function() end
end
api.setDecalLocalPos = function(decal) decal.cursorPosScreenUv = {x = 0.5, y = 0.5} end
api.setDecalTexturePath = function(kind, path) counters.tex[kind]=path end
api.setDecalRotation = function(value) counters.rotation=value end
api.setDecalScale = function(value) counters.scale=value end

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
local nativeDofile=dofile
dofile=function(path)
  return nativeDofile(path:sub(1,5)=="/lua/" and ROOT..path or path)
end
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
check(paint.getStats().config.contactPatches == true, "contact patches are the default pipeline")
-- The scheduler checks below exercise the legacy one-decal-per-contact
-- pipeline; contact patches are checked near the end.
paint.setContactPatches(false)
-- The scheduling checks below count native projection passes, so they run in
-- the legacy projected-anchor mode; synthetic anchors are checked at the end.
check(paint.getStats().config.syntheticAnchors == true, "projection-free synthetic anchors are the default")
paint.setSyntheticAnchors(false)
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
  getNodePosition = function() return vec3(0,0,0.3) end,
  getPosition = function() return vec3(100,0,0) end,
  getVelocity = function() return vec3(0,5,0) end,
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

-- Slow frames must drain captured layers even when another projection is due.
paint.setFlushInterval(0)
for i=1,24 do
  paint.stampAtLocal(vec3(i*0.3,0,0),vec3(0,0,1),{size=0.1},42)
end
frame(0.3)
local waiting=paint.getStats().queue.bake
local projectsBeforeDrain=counters.projects
if waiting>0 then frame(0.3) end
check(waiting>0, "slow-frame fixture captures layers")
check(counters.projects==projectsBeforeDrain and paint.getStats().queue.bake<waiting,
  "due projection cannot starve the bake queue")
for _=1,80 do frame(0.3) end
paint.setFlushInterval(0.2)

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
paint.ingest(playerVid, nil, {
  { {100.0, 0.0, 0.6, 0, 0, 1}, {100.4, 0.0, 0.6, 0, 0, 1} },
  { {100.0, 0.1, 0.6, 0, 0, 1}, {100.4, 0.1, 0.6, 0, 0, 1} },
})
for _ = 1, 20 do frame() end
check(paint.getStats().stamp.streamsMerged == m0 + 1 and counters.projects == pr0 + 1,
  "adjacent slides share one projection (" .. (counters.projects - pr0) .. " projections)")

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

-- 8) Unload/reload of the extension doesn't error.
local ok4, err4 = pcall(paint.onExtensionUnloaded)
check(ok4, "onExtensionUnloaded runs cleanly: " .. tostring(err4))

for _, l in ipairs(logLines) do
  if l:sub(1, 1) == "E" then check(false, "error logged: " .. l) end
end

paint.onExtensionLoaded()
for i=1,5 do frame() end

-- Surface capability: real callback argument order, rate limiting, independent
-- wheel eligibility, washing state, disabled/missing API and lifecycle.
paint.clearStamps()
detect.onReset(); runGE()
local function soil(id, material, x)
  _G.onNodeCollision(id, vec3(x or 100,0,0.3),vec3(0,0,1),vec3(0,0,0),0,
    vec3(0,0,0),5,0,300,0.01,material,METAL)
end
local function surfaceTick(wet)
  obj.inWater = function() return wet end
  obj.simTime = obj.simTime + 0.26
  detect.updateGFX(0.26); runGE(); frame(0.26)
end
-- Resting wheels (even with slip) must not produce deposits; zero-slip
-- translation must. This catches the old slip-only rolling gate.
local movingVelocity = obj.getVelocity
vehicle.getVelocity = function() return obj:getVelocity() end
obj.getVelocity = function() return vec3(0,0,0) end
soil(30,18); surfaceTick(false)
check(paint.getSurfaceState().deposits == 0, "stationary tire slip adds no soil")
obj.getVelocity = movingVelocity
_G.onNodeCollision(30,vec3(100,0,0.3),vec3(0,0,1),vec3(0,5,0),0,
  vec3(0,0,0),0,0,300,0.01,18,METAL)
surfaceTick(false)
check(paint.getSurfaceState().deposits == 1, "rolling without slip adds soil")
check(paint.getSurfaceState().lastSample.wheel == 1, "rolling packet retains wheel identity")
check(paint.getSurfaceState().lastSample.flowY < 0 and paint.getSurfaceState().lastSample.flowZ > 0,
  "wheel spray travels opposite motion and upward from the tire")
obj.getVelocity = function() return vec3(0,-5,0) end
paint.clearStamps(); soil(30,18); surfaceTick(false)
check(paint.getSurfaceState().lastSample.flowY > 0,
  "reversing reverses wheel spray flow rather than rotating randomly")
obj.getVelocity = movingVelocity
paint.clearStamps()
for _,side in ipairs({-1,1}) do
  for _,speed in ipairs({-5,5}) do
    paint.clearStamps()
    obj.getVelocity=function() return vec3(0,speed,0) end
    paint.ingestSurface(playerVid,{{'mud',100+side,-1,0.3,0,0,1,1}},false,true)
    for _=1,5 do frame(0.26) end
    local sample=paint.getSurfaceState().lastSample
    local layer=counters.lastSoilLayer
    -- Reconstruct +texture X in the engine's surface-normal decal basis.
    local alignment=(-side*math.cos(layer.decalRotation))*sample.flowY
      -math.sin(layer.decalRotation)*sample.flowZ
    check(alignment>0.999,'fling follows its throw on side '..side..' at speed '..speed)
    check(sample.flowZ>0.25 and layer.decalScale.x>=0.6 and layer.decalScale.x<=1.45
      and math.abs(layer.decalScale.z-layer.decalScale.x*0.5)<1e-6,
      'fling is thrown upward as a bounded 2:1 fan')
    check(layer.colorTex:find('soil_mud_fling_',1,true)~=nil,'wheel mud uses a fling brush')
    check(layer.decalScale.y>1 and layer.decalScale.y<2,
      'soil slab reaches recessed bodywork but stays short of the vehicle centerline')
  end
end
obj.getVelocity=movingVelocity
paint.clearStamps()
soil(10,18); soil(30,18); surfaceTick(false)
check(paint.getSurfaceState().lastSample.wheel == 1,
  "wheel sample takes priority over earlier body contact")
paint.clearStamps()
local scratchBeforeSoil = paint.getStats().stamp.streamsBaked
local beforeSoft = detStats()
for _, name in ipairs({'MUD','SNOW','GRASS'}) do
  for step=1,8 do
    obj.simTime = obj.simTime + 0.04
    _G.onNodeCollision(10,vec3(100+step*.02,0,0.3),vec3(0,0,1),vec3(0,5,0),3,
      vec3(0,5,0),8,0,12000,0.01,particles.getMaterialIDByName(mats,name),METAL)
  end
end
surfaceTick(false)
local afterSoft = detStats()
check(afterSoft.filteredCalls==beforeSoft.filteredCalls and afterSoft.impactEvents==beforeSoft.impactEvents,
  'high-force body contacts on mud, snow and grass never trigger abrasion')
check(paint.getSurfaceState().mud>0 and paint.getSurfaceState().snow>0,
  'soft body contacts still deliver mud and snow deposits')
paint.clearStamps()
for i=1,1000 do soil(30,18) end -- tire MUD, no body scratch
surfaceTick(false)
check(paint.getStats().stamp.streamsBaked == scratchBeforeSoil, "tire soil creates no scratch streams")
check(paint.getSurfaceState().mud > 0, "wheel mud contact accumulates cosmetic exposure")
check(paint.getSurfaceState().deposits == 1, "1000 contacts coalesce into one deposit")
soil(30,15,101); soil(30,22,102); surfaceTick(false)
check(paint.getSurfaceState().dirt > 0 and paint.getSurfaceState().snow > 0,
  "DIRT and SNOW resolve by material name")
local deposits = paint.getSurfaceState().deposits
soil(20,18); surfaceTick(false)
check(paint.getSurfaceState().deposits == deposits, "internal engine contact does not add soil")
local clearsBeforeWater = counters.clears
for i=1,5 do soil(30,18); surfaceTick(true) end
check(paint.getSurfaceState().wetness > 0, "inWater raises wetness")
check(paint.getSurfaceState().mud == 0, "water washes exposure state")
check(counters.clears == clearsBeforeWater, "washing never clears baked scratches")
check(paint.getSurfaceState().deposits == deposits, "submersion suppresses deposits")
local wetness = paint.getSurfaceState().wetness
for i=1,12 do surfaceTick(false) end
check(paint.getSurfaceState().wetness < wetness, "wetness dries after water contact expires")
obj.inWater = nil
obj.simTime = obj.simTime + 0.26; detect.updateGFX(0.26); runGE()
check(not paint.getSurfaceState().waterSupported, "missing water API reported without failure")
local beforeForeign = paint.getSurfaceState().mud
paint.ingestSurface(-1,{{"mud",100,0,0,0,0,1}},true,true)
check(paint.getSurfaceState().mud == beforeForeign, "foreign vehicle surface packet ignored")
paint.ingestSurface(playerVid,{{"mud",0/0,0,0,0,0,1},{"bogus",0,0,0,0,0,1}},false,true)
check(paint.getSurfaceState().mud == beforeForeign, "invalid surface samples ignored")
for i=1,150 do
  paint.ingestSurface(playerVid,{{"mud",100+i,0,0,0,0,1}},false,true)
end
check(paint.getSurfaceState().deposits == 96, "surface deposit lifetime cap enforced")
for i=1,120 do frame() end
check(counters.maxProjectsInFrame <= projBudget(), "soil respects shared projection budget")
paint.clearStamps()
check(paint.getSurfaceState().deposits == 0 and paint.getSurfaceState().wetness == 0,
  "clear resets surface state")
soil(30,18); detect.setPaintEnabled(false); surfaceTick(false)
check(paint.getSurfaceState().deposits == 0, "disable discards pending surface samples")
detect.setPaintEnabled(true)
soil(30,18); playerInfo.firstPlayerSeated=false; surfaceTick(false)
playerInfo.firstPlayerSeated=true; surfaceTick(false)
check(paint.getSurfaceState().deposits == 0, "leaving vehicle discards pending samples")
soil(30,18); detect.onReset(); runGE(); surfaceTick(false)
check(paint.getSurfaceState().deposits == 0, "reset discards pending samples")
paint.ingestSurface(playerVid,{{"snow",100,0,0,0,0,1}},false,true)
paint.onVehicleSwitched(playerVid,playerVid+1,0)
check(paint.getSurfaceState().snow == 0, "switch clears surface state")

-- Paint design changes on the same vehicle must revoke canvas access.
for i=1,4 do frame() end
partConfig.partsTree.children[1].chosenPartName = "pickup_skin_police"
paint.onVehicleSpawned(playerVid)
local beforeClear, beforeBake = counters.clears, counters.bakes
for i=1,4 do frame() end
paint.clearStamps()
check(partConfig.partsTree.children[1].chosenPartName == "pickup_skin_police", "stock livery survives same-id respawn")
check(not paint.getCompatibility().ready, "livery revokes painter readiness")
check(counters.clears == beforeClear and counters.bakes == beforeBake, "skipped livery never clears or seeds")
partConfig.partsTree.children[1].chosenPartName = "pickup_skin_dynamicTextures"
paint.onVehicleSpawned(playerVid)
for i=1,4 do frame() end
check(not paint.getCompatibility().ready, "unowned dynamic livery is skipped")
partConfig.partsTree.children[1].chosenPartName = ""
paint.onVehicleSpawned(playerVid)
for i=1,4 do frame() end
check(paint.getCompatibility().ready, "removing livery re-enables plain paint")
paint.onVehicleSpawned(playerVid)
for i=1,4 do frame() end
check(paint.getCompatibility().ready, "owned dynamic skin survives respawn")

paint.onVehicleDestroyed(playerVid)
paint.onVehicleSpawned(playerVid)
for i=1,4 do frame() end
check(not paint.getCompatibility().ready, "reused id cannot claim an old dynamic skin")

-- Milestone 4: inspect style helpers without needing a GPU. Rendering is live-tested.
local function up(fn, wanted)
  for i=1,100 do
    local name,value=debug.getupvalue(fn,i)
    if not name then break end
    if name==wanted then return value end
  end
  error("missing upvalue "..wanted)
end
local enqueue = up(paint.stampAtLocal,"enqueueStamp")
local tone = up(enqueue,"lineTone")
local pick = up(up(enqueue,"pickBrush"),"pickFromSet")
local family={"a","b","c","d"}
local other={"haze1","haze2"}
local previous
local different = true
for i=1,100 do
  local nextBrush=pick(family)
  pick(other)
  if nextBrush==previous then different=false end
  previous=nextBrush
end
check(different,"brush variation never repeats immediately")
local r,g,b,a=tone(0)
check(r>=0.72 and r<=0.80 and r==g and g==b and a==0.72,"shallow depth brush uses restrained neutral tint")
local _,_,_,deep=tone(1)
check(deep>a and deep<=0.89,"deep damage increases opacity within bound")

-- Representative coalescing: contained repeated damage is accounted, not lost.
partConfig.partsTree.children[1].chosenPartName=""
paint.onVehicleSpawned(playerVid)
for i=1,4 do frame() end
local savedDofile=dofile
dofile=function(path) return savedDofile(path=="/lua/ge/extensions/scratches/coverage.lua" and "lua/ge/extensions/scratches/coverage.lua" or path) end
paint.clearStamps();paint.setCoverageCoalescing(true);paint.resetPaintStats()
for i=1,200 do paint.stampAtLocal(vec3(0,0,.3),vec3(0,0,1),{noJitter=true,scale=.1,colorTex="m4_scrape_a.png"}) end
local co=paint.getStats().coverage
check(co.requests==200 and co.representatives==1 and co.mergedQueued==199,"repeated contained inputs retain one queued representative")
check(paint.getStats().stamp.aggregateDropped==0,"coalescing happens before aggregate cap")
for _=1,50 do frame(.02) end
co=paint.getStats().coverage
check(co.completedRequests==200 and co.pendingRequests==0 and co.lostRequests==0,"bake accounts all represented requests")
check(co.unrepresentedCells==0,"all requested footprint proxy cells represented")
paint.stampAtLocal(vec3(0,0,.3),vec3(0,0,1),{noJitter=true,scale=.05,colorTex="m4_scrape_b.png"})
check(paint.getStats().coverage.mergedBaked==1,"contained brush variant is an explicit completed representative merge")
paint.stampAtLocal(vec3(.4,0,.3),vec3(0,0,1),{noJitter=true,scale=.1,colorTex="m4_scrape_a.png"})
check(paint.getStats().coverage.representatives==2,"new area is never merged into a distant mark")
paint.stampAtLocal(vec3(0,0,.3),vec3(0,0,1),{noJitter=true,scale=.05,colorTex="m4_scrape_b.png",r=.1,g=.2,b=.3})
check(paint.getStats().coverage.representatives==3,"explicit color override is not merged into procedural damage")
paint.clearStamps();paint.resetPaintStats()
local bakeBeforeFailure=decalProjection.bakeLayers
local failBake=true
decalProjection.bakeLayers=function(self,list) if failBake then failBake=false;error("simulated native bake failure") end;return bakeBeforeFailure(self,list) end
paint.stampAtLocal(vec3(0,0,.3),vec3(0,0,1),{noJitter=true,scale=.1,colorTex="m4_scrape_a.png"})
local bakeOk=pcall(function() for _=1,40 do frame(.02) end end)
check(bakeOk and paint.getStats().stamp.bakeFailures==1,"native bake error does not abort scheduler")
check(paint.getStats().coverage.lostRequests==1 and paint.getStats().coverage.pendingRequests==0,"failed bake explicitly accounts lost request")
paint.stampAtLocal(vec3(0,0,.3),vec3(0,0,1),{noJitter=true,scale=.1,colorTex="m4_scrape_a.png"})
for _=1,40 do frame(.02) end
check(paint.getStats().coverage.completedRequests==1,"failed native bake cannot suppress a subsequent mark")
decalProjection.bakeLayers=bakeBeforeFailure
paint.setCoverageCoalescing(false);dofile=savedDofile

local cov=savedDofile("lua/ge/extensions/scratches/coverage.lua").new(function() return 2 end)
local function input(x,n,scale,sev) return {localPos=vec3(x,0,0),localNormal=n,scale=scale,brush="m4_scrape_a.png",severity=sev,queuedAt=0} end
local r=cov:admit(input(0,vec3(0,0,1),.1,0))
local _,needed=cov:admit(input(0,vec3(0,0,-1),.1,0));check(needed,"opposite panels never coalesce")
_,needed=cov:admit(input(0,vec3(0,0,1),.2,0));check(needed,"larger footprint retains new coverage")
_,needed=cov:admit(input(0,vec3(0,0,1),.1,1));check(needed,"stronger severity retains new work")
cov:fail(r);check(cov:snapshot().lostRequests==1,"failed representative explicitly counts lost coverage requests")
local fresh=savedDofile("lua/ge/extensions/scratches/coverage.lua").new(function() return 2 end)
local failed=fresh:admit(input(0,vec3(0,0,1),.1,0));fresh:fail(failed)
_,needed=fresh:admit(input(0,vec3(0,0,1),.1,0));check(needed,"failed mark cannot suppress retry")
local _,same=fresh:admit(input(0,vec3(0,0,1),.1,0));check(not same and fresh:snapshot().staleMerged==1,"stale queued work coalesces with original age retained")

local bounded=savedDofile("lua/ge/extensions/scratches/coverage.lua").new(function() return 2 end)
for i=1,8200 do local record=bounded:admit(input(i*.5,vec3(0,0,1),.1,0));bounded:complete(record) end
check(bounded:snapshot().cachedRepresentatives==8192 and bounded:snapshot().historyEvicted==8,"representative history remains bounded across a long session")
check(bounded:snapshot().requiredCells<=65536 and bounded:snapshot().trackingOverflow>0,"coverage diagnostic cap reports overflow instead of unbounded growth")

paint.clearStamps();paint.resetPaintStats();paint.setPanelGrouping(true);paint.setBakeBudget(1)
counters.maxBakeLayers=0
for i=1,20 do paint.stampAtLocal(vec3((i-10)*.07,0,.3),vec3(0,0,1),{noJitter=true,scale=.04}) end
for _=1,100 do frame(.02) end
check(paint.getStats().stamp.projectsIssued==1,"wider same-panel group shares one projection")
check(paint.getStats().perf.bakeLayersTotal==20,"panel grouping retains every authored layer")
check(counters.maxBakeLayers<=1,"native bake batch setting is honored")
local gen=paint.getStats().generation;paint.clearStamps()
check(paint.getStats().generation>gen,"reset generation exposes invalidated measurement")
paint.resetPaintStats()
paint.stampAtLocal(vec3(0,0,.3),vec3(0,0,1),{noJitter=true,scale=.04})
paint.stampAtLocal(vec3(.05,0,.3),vec3(0,0,-1),{noJitter=true,scale=.04})
for _=1,40 do frame(.02) end
check(paint.getStats().stamp.projectsIssued==2,"opposing normals never share the wider panel camera")
paint.setPanelGrouping(false);paint.setBakeBudget(6)
local profile=paint.getNativeTimingProfile()
check(profile.project.calls==paint.getStats().perf.projectCalls and profile.bakeBatch.calls==paint.getStats().perf.bakeCalls,"bounded native histogram accounts every timed call/batch")
paint.clearStamps();paint.resetPaintStats()
local captureBeforeFailure=decalProjection.getDecalData
local captureCalls=0
decalProjection.getDecalData=function(self,...)
  captureCalls=captureCalls+1
  if captureCalls==2 then return nil end
  return captureBeforeFailure(self,...)
end
paint.ingest(playerVid,nil,{{{100,0,.6,0,0,1},{100.4,0,.6,0,0,1}}})
for _=1,40 do frame(.02) end
check(paint.getStats().stamp.streamLayersExpected==2 and paint.getStats().stamp.streamLayersMissed==1,"partial stream capture loss is explicit, even when the other layer succeeds")
check(paint.getStats().perf.bakeLayersTotal==1,"valid remainder of a partially missed stream still bakes")
decalProjection.getDecalData=captureBeforeFailure
paint.clearStamps();paint.resetPaintStats();paint.setPanelGrouping(true)
paint.ingest(playerVid,nil,{
  {{100,0,.6,0,0,1},{100.4,0,.6,0,0,1}},
  {{100,.1,.6,0,0,1},{100.4,.1,.6,0,0,1}}})
for _=1,40 do frame(.02) end
local streamStats=paint.getStats()
check(streamStats.stamp.streamsMerged==1,"adjacent stream bands share a projection")
check(streamStats.stamp.streamLayersExpected==4 and streamStats.stamp.streamSubstrokesTotal==4 and streamStats.perf.bakeLayersTotal==4,"merged bands retain exactly one haze and one segment each without alias duplication")
paint.setPanelGrouping(false)
-- Ground paint: a slide whose contact normal is vertical leaves marks on the
-- road along its path; walls leave none; the ring is bounded; marks fade and
-- expire; a vehicle reset keeps them and a level change does not.
do
  local ground = dofile("/lua/ge/extensions/scratches/groundPaint.lua") -- private instance
  local drawn, drawnPool = 0, nil
  ground._setBackend(function(pool, n) drawn = n; drawnPool = pool end)
  local red = {0.8, 0.1, 0.1}
  check(ground.addStream({{0,0,0,1,0,0},{2,0,0,1,0,0}}, red) == 0, "a slide along a wall leaves nothing on the ground")
  check(ground.addStream({{0,0,0,0,0,1},{0.03,0,0,0,0,1}}, red) == 0, "a slide that went nowhere leaves nothing on the ground")
  local laid = ground.addStream({{0,0,0,0,0,1},{2,0,0,0,0,1}}, red)
  check(laid >= 5 and laid <= 9, "a 2 m ground scrape lays one mark per 0.25-0.4 m ("..laid..")")
  local first = ground._marks()[1]
  check(first.dx > 0.99 and first.len > 0.25 and first.len < 0.7 and first.width < 0.2, "a ground mark lies along the scrape")
  check(first.r > first.g + 0.2 and first.g > 0.1 and first.a < 0.7, "paint transfer keeps the car's hue, chalkier and translucent")
  ground.update(1/60)
  check(drawn == laid and ground.getStats().submitted == laid, "every nearby mark is submitted each frame ("..drawn..")")
  check(drawnPool[1].scale.y == first.len and drawnPool[1].color.a == first.a and drawnPool[1].texture == first.tex, "the decal carries the mark's size, tint and texture")
  local poolEntry = drawnPool[1]
  ground.update(1/60)
  check(drawnPool[1] == poolEntry, "the decal pool is reused between frames")
  core_camera = { getPosition = function() return vec3(1000, 0, 0) end }
  drawn = 0; ground.update(1/60)
  check(drawn == 0 and ground.getStats().submitted == 0 and ground.getStats().culled == laid, "marks far from the camera are not submitted")
  core_camera = nil
  check(ground.addImpact(5,5,0, 0,0,1, 500, red) == 0 and ground.addImpact(5,5,0, 1,0,0, 30000, red) == 0, "soft hits and wall hits chip nothing onto the ground")
  check(ground.addImpact(5,5,0, 0,0,1, 12000, red) >= 2, "a hard hit on the ground leaves a smear and chips")
  check(ground.addWheelScrape({0,9,0}, {0,0,1}, 6) == 0, "the first wheel-side report only starts a track")
  check(ground.addWheelScrape(vec3(0.3,9,0), vec3(0,0,1), 6) == 1, "a dragged wheel lays a mark once it has moved")
  local stats = ground.getStats()
  local wheelMark = ground._marks()[stats.alive]
  check(wheelMark.r < 0.6 and math.abs(wheelMark.r - wheelMark.g) < 0.05 and wheelMark.dx > 0.99, "the wheel mark is dark rubber or bare metal, along the drag")
  check(ground.addWheelScrape({0.6,9,0}, {1,0,0}, 6) == 0, "a wheel rubbing a wall leaves nothing on the ground")
  for i = 1, 40 do ground.addStream({{0,20+i,0,0,0,1},{6,20+i,0,0,0,1}}, red) end
  stats = ground.getStats()
  check(stats.alive == ground._limits.max and stats.dropped > 0, "the ring is bounded and drops the oldest ("..stats.alive.." alive, "..stats.dropped.." dropped)")
  local bare = 0
  for _, m in ipairs(ground._marks()) do if math.abs(m.r - m.g) < 0.02 and m.r < 0.4 then bare = bare + 1 end end
  check(bare > 50, "a long hard scrape wears through to bare metal ("..bare..")")
  ground.update(ground._limits.life - ground._limits.fade / 2)
  local a = drawnPool[1].color.a
  check(a > 0 and a < 0.4, "marks fade over their last seconds ("..a..")")
  ground.update(ground._limits.fade)
  check(ground.getStats().alive == 0, "marks expire")
  ground.addStream({{0,0,0,0,0,1},{2,0,0,0,0,1}}, red)
  ground._setBackend(function() error("decal manager gone") end)
  check(pcall(ground.update, 1/60) and ground.getStats().drawErrors == 1, "a throwing decal manager is contained")
  ground.setEnabled(false)
  check(ground.getStats().alive == 0 and ground.addStream({{0,0,0,0,0,1},{2,0,0,0,0,1}}, red) == 0, "switched off: marks forgotten, nothing new laid")
end
paint.clearGroundPaint()
paint.ingest(playerVid,nil,{{{100,0,.6,0,0,1},{101,0,.6,0,0,1}}})
local groundAlive=paint.getStats().ground.alive
check(groundAlive>=2,"a ground slide reaching the painter marks the road ("..groundAlive..")")
paint.ingest(playerVid,nil,{{{100,0,.6,1,0,0},{101,0,.6,1,0,0}}})
check(paint.getStats().ground.alive==groundAlive,"a wall slide reaching the painter does not mark the road")
paint.onVehicleResetted(playerVid)
check(paint.getStats().ground.alive==groundAlive,"a vehicle reset keeps the road marked")
paint.onClientEndMission()
check(paint.getStats().ground.alive==0,"leaving the level clears the road marks")
paint.setGroundPaint(false)
paint.ingest(playerVid,nil,{{{100,0,.6,0,0,1},{101,0,.6,0,0,1}}})
check(paint.getStats().ground.alive==0 and paint.getStats().ground.enabled==false,"setGroundPaint(false) switches road marks off")
paint.setGroundPaint(true)
for _=1,40 do frame(.02) end
paint.clearStamps();paint.resetPaintStats()
-- Synthetic anchors: no native projection pass, and every layer is anchored at
-- its own contact point with an outward normal (sign resolved against the hull
-- face even when the detector's collision normal points into the car).
paint.clearStamps();paint.resetPaintStats();paint.setSyntheticAnchors(true)
local bakedLayers={}
local bakeBeforeCapture=decalProjection.bakeLayers
decalProjection.bakeLayers=function(self,list) for _,l in ipairs(list) do bakedLayers[#bakedLayers+1]=l end;return bakeBeforeCapture(self,list) end
local projectsBeforeSynthetic=counters.projects
paint.stampAtLocal(vec3(.9,.3,.9),vec3(-1,0,0),{noJitter=true,scale=.05})
paint.stampAtLocal(vec3(.2,-1.5,1.8),vec3(0,0,1),{noJitter=true,scale=.05})
paint.ingest(playerVid,nil,{{{100,0,.6,0,0,1},{100.4,0,.6,0,0,1}}})
for _=1,60 do frame(.02) end
local synth=paint.getStats()
check(counters.projects==projectsBeforeSynthetic and synth.perf.projectCalls==0,"synthetic anchors issue no native projection pass")
check(synth.stamp.projectsIssued>=2 and synth.perf.bakeLayersTotal==4 and #bakedLayers==4,"synthetic jobs still capture and bake every layer (2 stamps + haze + segment)")
check(synth.anchors.synthesized==4,"every synthetic layer is explicitly anchored")
local side,roof
for _,l in ipairs(bakedLayers) do
  if l.decalPos and math.abs(l.decalPos.x-.9)<1e-6 then side=l end
  if l.decalPos and math.abs(l.decalPos.z-1.8)<1e-6 then roof=l end
end
check(side and side.decalNorm.x==1 and side.surfaceNormal.x==1,"inward collision normal is flipped to the hull-outward side")
check(roof and roof.decalNorm.z==1 and math.abs(roof.decalPos.y+1.5)<1e-6,"roof stamp anchors at its own contact point, not a shared hit")
decalProjection.bakeLayers=bakeBeforeCapture
paint.setSyntheticAnchors(false);paint.clearStamps();paint.resetPaintStats()
paint.stampAtLocal(vec3(.9,.3,.9),vec3(1,0,0),{noJitter=true,scale=.05})
for _=1,30 do frame(.02) end
check(paint.getStats().perf.projectCalls==1 and paint.getStats().anchors.synthesized==0,"legacy projected anchors remain selectable for comparison")
paint.setSyntheticAnchors(true)
-- Contact patches: many node reports on one panel become one decal per patch,
-- baked one layer at a time, after every brush set has been warmed while idle.
paint.setContactPatches(true);paint.clearStamps();paint.resetPaintStats()
bakedLayers={}
local maxBatch=0
local bakeBeforeCount=decalProjection.bakeLayers
decalProjection.bakeLayers=function(self,list) maxBatch=math.max(maxBatch,#list);for _,l in ipairs(list) do bakedLayers[#bakedLayers+1]=l end;return bakeBeforeCount(self,list) end
for _=1,150 do frame(1/60) end
local warm=paint.getStats().wear
local visibleWarm=false
for _,l in ipairs(bakedLayers) do if l.name~="warm" or l.decalScale.x>0.02 then visibleWarm=true end end
check(warm.warmed==20 and warm.warmPending==0 and #bakedLayers==20,"each wear brush set is warmed exactly once while idle ("..warm.warmed..")")
check(not visibleWarm,"warm-up layers are tagged and too small to show")
for _=1,60 do frame(1/60) end
check(#bakedLayers==20,"warm-up does not repeat")
bakedLayers={}
-- Twelve door nodes dragged along +y, reported in four detector flushes.
for _=1,4 do
  local streams={}
  for node=0,11 do
    local y,z=-0.5+(node%6)*0.15,0.6+math.floor(node/6)*0.1
    streams[#streams+1]={{101,y-0.3,z,-1,0,0},{101,y,z,-1,0,0}}
  end
  paint.ingest(playerVid,nil,streams)
  for _=1,15 do frame(1/60) end
end
for _=1,120 do frame(1/60) end
local w=paint.getStats().wear
check(w.patches.slideSamples==48 and w.patches.slidePatches==1,"48 slide reports on one panel fold into one patch ("..w.patches.slidePatches..")")
check(#bakedLayers>=1 and #bakedLayers<=3 and maxBatch==1,"a patch is painted as a few decals, one bake at a time ("..#bakedLayers.." layers, batch "..maxBatch..")")
local deep=bakedLayers[#bakedLayers]
check(deep.colorTex:find("w2_gouge_",1,true) and deep.metalTex:find("_m.png",1,true) and deep.roughTex:find("_r.png",1,true),"a long drag ends on a bare-metal brush with its own metal and roughness maps")
check(deep.decalNorm.x==1 and math.abs(deep.decalPos.x-1)<1e-6,"patch decal is anchored on the panel with an outward normal")
check(deep.decalScale.x>=0.9 and deep.decalScale.x<=1.35 and deep.decalScale.z>=0.15 and deep.decalScale.z<=0.44 and deep.decalScale.y<=0.34,"patch decal spans the contact extent with a bounded depth")
check(not w.pending and paint.getStats().queue.bake==0,"patch queue drains")
local settled=#bakedLayers
paint.ingest(playerVid,nil,{{{101,-0.4,0.6,-1,0,0},{101,-0.1,0.6,-1,0,0}}})
for _=1,90 do frame(1/60) end
check(#bakedLayers==settled,"scraping an already bare patch bakes nothing more")
-- Impacts: a burst on one spot is one chip decal; a glancing hit is scored along its slip.
bakedLayers={}
paint.ingest(playerVid,{{100.3,-1.2,1.8,0,0,-1,"i",3000,0,0,0},{100.33,-1.22,1.8,0,0,-1,"i",5000,0,0,0},{100.3,-1.18,1.8,0,0,-1,"i",4000,0,0,0}},nil)
for _=1,60 do frame(1/60) end
check(#bakedLayers==1 and bakedLayers[1].colorTex:find("w2_chip_",1,true),"an impact burst on one spot is a single chip decal")
check(bakedLayers[1].decalNorm.z>0.99,"roof impact gets an outward normal that still defines a decal basis")
bakedLayers={}
paint.ingest(playerVid,{{100.3,1.5,1.8,0,0,-1,"i",9000,0,6,0}},nil)
for _=1,60 do frame(1/60) end
check(#bakedLayers==1 and bakedLayers[1].colorTex:find("w2_score_",1,true),"a glancing impact uses a scored brush aligned to its slip")
paint.clearStamps()
check(paint.getStats().wear.patches.slidesLive==0 and paint.getStats().wear.patches.impactsLive==0,"reset forgets every patch")
decalProjection.bakeLayers=bakeBeforeCapture
passes = passes + dofile("tools/sim/adapter_harness.lua")
passes = passes + dofile("tools/sim/soil_color_harness.lua")

print(string.format("%d passed, %d failed  (projects=%d bakes=%d layers=%d composites=%d)",
  passes, failures, counters.projects, counters.bakes, counters.bakeLayers, counters.combines))
os.exit(failures == 0 and 0 or 1)
