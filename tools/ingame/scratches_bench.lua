-- Dev-only scenario bench for tools/bench.py. Never shipped: tools/dev.py
-- copies it into the dev mount as lua/ge/extensions/scratches/bench.lua, so it
-- loads as the GE extension `scratches_bench`.
--
-- One run: reset the player car to an exact pose, launch it, record per-frame
-- engine and mod timings until it settles and the painter's backlog drains,
-- pull the detector's stats, then screenshot it from fixed orbit angles with
-- the HUD hidden. Everything is stepped from onUpdate, so timings come from
-- the game loop itself and never depend on MCP round-trip latency.

local M = {}
local logTag = 'scratches_bench'
local clockhp = os.clockhp or os.clock

-- Engine frame-section timings (ms) from Engine.Debug.getLastPerformanceMetrics;
-- every key is recorded except these memory counters. They describe the
-- previous frame, so they lag frameMs/painterMs by one row.
local SKIP_METRICS = { physAvailable = true, physUsed = true, virtAvailable = true, virtUsed = true }
local metricsScratch = {}

local run = nil     -- active run
local result = nil  -- last finished run
local obstacles = {} -- TSStatics the current scenario spawned
local strikers = {}  -- {veh, spec} for vehicles the scenario drives into the player car

-- ---- helpers ----

local function v3(t) return vec3(t.x, t.y, t.z) end

local function rotateAbout(v, axis, deg)
  return quatFromAxisAngle(axis, math.rad(deg)) * v
end

-- Home frame: forward, right, up unit vectors.
local function homeFrame(home)
  local fwd = v3(home.dir):normalized()
  local up = v3(home.up):normalized()
  return fwd, fwd:cross(up):normalized(), up
end

-- ---- scenario obstacles ----
-- Static meshes (walls, posts) placed around the home pose. Offsets are in
-- the home frame from the car's box center at home, plus multiples of the
-- car's half-length (fwdL) and half-width (rightW), so one scenario fits any
-- car: {shape, fwd, right, up, fwdL, rightW, yaw (deg), scale}.

-- The car's box in its own frame: world center, half-length, half-width and
-- the world z of its underside, from the spawn-local bounds (a world AABB
-- inflates both on any heading that isn't axis-aligned).
local function carBox(veh)
  local b = veh:getSpawnLocalAABB()
  local lc = vec3((b.minExtents.x + b.maxExtents.x) * 0.5, (b.minExtents.y + b.maxExtents.y) * 0.5,
                  (b.minExtents.z + b.maxExtents.z) * 0.5)
  return veh:getRefNodeMatrix():mulP3F(lc), 0.5 * (b.maxExtents.y - b.minExtents.y),
         0.5 * (b.maxExtents.x - b.minExtents.x), veh:getWorldBox().minExtents.z
end

local function clearObstacles()
  if #obstacles == 0 then return end
  for _, o in ipairs(obstacles) do
    if o and o.delete then pcall(function() o:delete() end) end
  end
  table.clear(obstacles)
  be:reloadCollision()
end

local function spawnObstacles(veh, home, list)
  clearObstacles()
  if not list or #list == 0 then return end
  local fwd, right, up = homeFrame(home)
  local center, halfLen, halfWid, groundZ = carBox(veh)
  for i, o in ipairs(list) do
    local obj = createObject('TSStatic')
    obj:setField('shapeName', 0, o.shape)
    obj.canSave = false
    obj:registerObject('scr_bench_obstacle_' .. i)
    local pos = center + fwd * ((o.fwd or 0) + (o.fwdL or 0) * halfLen)
                       + right * ((o.right or 0) + (o.rightW or 0) * halfWid)
    pos.z = groundZ + (o.up or 0)
    local dir = o.yaw and rotateAbout(fwd, up, o.yaw) or fwd
    local q = quatFromDir(dir, up)
    local m = QuatF(q.x, q.y, q.z, q.w):getMatrix()
    m:setPosition(pos)
    obj:setTransform(m)
    if o.scale then obj:setScale(vec3(o.scale, o.scale, o.scale)) end
    obstacles[#obstacles + 1] = obj
  end
  be:reloadCollision()
end

-- ---- striker vehicles ----
-- Other cars the scenario drives into the player car (car-on-car contact).
-- spec: {model, config, color={r,g,b}, fwd, right, rightW, yaw (deg, heading
-- relative to home forward; positive turns right), speed (m/s)}.
local function clearStrikers()
  for _, s in ipairs(strikers) do
    if s.veh then pcall(function() s.veh:delete() end) end
  end
  table.clear(strikers)
end

local function spawnStrikers(veh, home, list)
  clearStrikers()
  if not list or #list == 0 then return end
  local fwd, right, up = homeFrame(home)
  local center, _, halfWid = carBox(veh)
  for _, sp in ipairs(list) do
    local pos = center + fwd * (sp.fwd or 0) + right * ((sp.right or 0) + (sp.rightW or 0) * halfWid)
    local dir = rotateAbout(fwd, up, sp.yaw or 0)
    local col = sp.color or { 0.8, 0.8, 0.8 }
    local paint = createVehiclePaint({ x = col[1], y = col[2], z = col[3], w = 1 }, { 0.3, 0.4, 1, 0.05 })
    local o = core_vehicles.spawnNewVehicle(sp.model or 'pickup', { config = sp.config, pos = pos,
      rot = quat(0, 0, 1, 0) * quatFromDir(dir, up), paint = paint, autoEnterVehicle = false, cling = true })
    if o then strikers[#strikers + 1] = { veh = o, dir = dir, spec = sp } end
  end
end

local function launchStrikers()
  for _, s in ipairs(strikers) do
    local o, v = s.veh, s.dir * (s.spec.speed or 8)
    o:queueLuaCommand("if controller.mainController and controller.mainController.shiftToGearIndex then " ..
      "controller.mainController.shiftToGearIndex(0) end input.event('parkingbrake', 0, 2) input.event('brake', 0, 2)")
    o:applyClusterVelocityScaleAdd(o:getRefNodeId(), 0, v.x, v.y, v.z)
  end
end

-- ---- damage sites ----
-- The painter logs where it laid marks (vehicle-local position + normal).
-- Group them greedily into sites, biggest first, each with a world position,
-- an outward world normal and a rough radius, for aiming close-up photos.
local function damageSites(veh, maxSites, radius)
  local marks = scratches_paint and scratches_paint.getMarks and scratches_paint.getMarks() or {}
  local sites = {}
  for _, mk in ipairs(marks) do
    local p, n = vec3(mk[1], mk[2], mk[3]), vec3(mk[4], mk[5], mk[6])
    local best, bestD = nil, radius
    for _, s in ipairs(sites) do
      local d = (s.p - p):length()
      if d < bestD and s.n:dot(n) > 0.3 then best, bestD = s, d end
    end
    if best then
      best.sum = best.sum + p
      best.nsum = best.nsum + n
      best.count = best.count + 1
      best.p = best.sum * (1 / best.count)
      best.n = best.nsum:normalized()
      best.pts[#best.pts + 1] = p
    else
      sites[#sites + 1] = { p = p, n = n, sum = p, nsum = n, count = 1, pts = { p } }
    end
  end
  table.sort(sites, function(a, b) return a.count > b.count end)
  local m = veh:getRefNodeMatrix()
  local rot = m:copy(); rot:setColumn(3, vec3(0, 0, 0))
  local center = veh:getWorldBox():getCenter()
  local out = {}
  for i = 1, #sites do
    if #out >= maxSites then break end
    local s = sites[i]
    local r = 0
    for _, p in ipairs(s.pts) do r = math.max(r, (p - s.p):length()) end
    -- Aim at the densest part of the site, not its centroid: a long swipe's
    -- centroid can fall on bare paint between bands.
    local focus, most = s.p, 0
    for _, a in ipairs(s.pts) do
      local k = 0
      for _, b in ipairs(s.pts) do if (a - b):length() < 0.2 then k = k + 1 end end
      if k > most then focus, most = a, k end
    end
    local pos, n = m:mulP3F(focus), rot:mulP3F(s.n):normalized()
    -- Contact normals belong to whatever was hit (a post's face points into
    -- the car); the camera wants the hull's outward side.
    if n:dot(pos - center) < 0 then n = -n end
    -- Underbody scrapes can't be photographed; leave them out.
    if n.z > -0.6 then out[#out + 1] = { pos = pos, normal = n, count = s.count, radius = r } end
  end
  return out
end

-- Launch pose from the home pose plus the scenario's offset (home frame),
-- euler angles (yaw about up, then pitch about right, then roll about
-- forward; degrees) and velocity (home frame, m/s).
local function launchPose(home, sc)
  local fwd = v3(home.dir):normalized()
  local up = v3(home.up):normalized()
  local right = fwd:cross(up):normalized()
  local o, e, vel = sc.offset or {}, sc.euler or {}, sc.vel or {}
  local pos = v3(home.pos) + right * (o.right or 0) + fwd * (o.fwd or 0) + up * (o.up or 0)
  local d, u = fwd, up
  if e.yaw then d = rotateAbout(d, u, e.yaw) end
  local r = d:cross(u):normalized()
  if e.pitch then d = rotateAbout(d, r, e.pitch); u = rotateAbout(u, r, e.pitch) end
  if e.roll then u = rotateAbout(u, d, e.roll) end
  -- Velocity follows the yaw (a car rolls the way it points) but not pitch
  -- or roll (a tumbled car is still thrown horizontally).
  local vf, vr = fwd, right
  if e.yaw then vf, vr = rotateAbout(fwd, up, e.yaw), rotateAbout(right, up, e.yaw) end
  local v = vr * (vel.right or 0) + vf * (vel.fwd or 0) + up * (vel.up or 0)
  return pos, d, u, v
end

-- Reset the car, repaired, at an exact pose (what spawn.safeTeleport does
-- without its search for a free spot, which would move a mid-air drop).
local function placeVehicle(veh, pos, dir, up)
  local r = quat(0, 0, 1, 0) * quatFromDir(dir, up)
  veh:setPosRot(pos.x, pos.y, pos.z, r.x, r.y, r.z, r.w)
  veh:resetBrokenFlexMesh()
end

local function runChunks(chunks, veh)
  for _, c in ipairs(chunks or {}) do
    if c.vm == 'vehicle' then
      veh:queueLuaCommand(c.code)
    else
      local fn, err = loadstring(c.code, '@bench_set')
      if not fn then error('bad tuning code: ' .. tostring(err)) end
      fn()
    end
  end
end

local function setShotCamera(vid, shot)
  core_camera.setByName(0, 'orbit')
  core_camera.setRotation(vid, vec3(shot.yaw or 0, shot.pitch or 20, 0))
  if shot.dist then core_camera.setDistance(vid, shot.dist) end
end

local function setBackgroundLimiter(enabled)
  if settings and settings.setValue then settings.setValue('fpsLimitBackgroundEnabled', enabled) end
end

local function restore()
  if not run then return end
  clearObstacles()
  clearStrikers()
  if run.prevUI ~= nil and ui_visibility and ui_visibility.set then ui_visibility.set(run.prevUI) end
  if run.shotIdx and core_camera then
    local veh = getPlayerVehicle(0)
    if veh then setShotCamera(veh:getId(), { yaw = 0, pitch = -20, dist = 8 }) end
  end
  if run.prevBgLimit ~= nil then setBackgroundLimiter(run.prevBgLimit) end
  if run.paintPaused then
    local veh = getPlayerVehicle(0)
    if veh then veh:queueLuaCommand("if scratches_detect then scratches_detect.setPaintEnabled(true) end") end
    run.paintPaused = false
  end
  if run.optickRunning and Engine.Profiler then
    pcall(Engine.Profiler.stopCapture)
    run.optickRunning = false
  end
end

local function finish(err)
  if not run then return end
  -- A failing restore must not leave `run` set: onUpdate would then fail and
  -- call finish again on every frame.
  local okRestore, restoreErr = pcall(restore)
  if not okRestore then err = err or ('restore failed: ' .. tostring(restoreErr)) end
  if err then
    run.error = tostring(err)
    log('E', logTag, 'run failed: ' .. run.error)
  end
  local paintStats = scratches_paint and scratches_paint.getStats and scratches_paint.getStats() or nil
  result = {
    name = run.cfg.name,
    cfg = run.cfg,
    error = run.error,
    settled = run.settled,
    runSeconds = run.runSeconds,
    drainSeconds = run.drainSeconds,
    frames = run.frames,
    painter = run.painterStats or paintStats,
    detect = run.detect,
    detectProf = run.detectProf,
    shots = run.shotFiles,
    sites = run.siteInfo,
    optick = run.optickPath,
  }
  run = nil
end

local function newFrames()
  return { t = {}, frameMs = {}, painterMs = {}, speed = {}, upZ = {} }
end

-- frameMs is wall time between successive bench updates (os.clockhp): the
-- engine's dtReal is smoothed and under-reports long frames.
local function sample(veh)
  local f = run.frames
  local n = #f.t + 1
  local now = clockhp()
  f.t[n] = run.t
  f.frameMs[n] = run.lastClock and (now - run.lastClock) * 1000 or 0
  run.lastClock = now
  f.painterMs[n] = scratches_paint and scratches_paint.getLastFrameMs and scratches_paint.getLastFrameMs() or 0
  f.speed[n] = veh:getVelocity():length()
  f.upZ[n] = veh:getDirectionVectorUp().z
  table.clear(metricsScratch)
  if Engine.Debug and Engine.Debug.getLastPerformanceMetrics then
    Engine.Debug.getLastPerformanceMetrics(metricsScratch)
  end
  for k, v in pairs(metricsScratch) do
    if not SKIP_METRICS[k] and type(v) == 'number' then
      local col = f[k]
      if not col then
        col = {}
        for i = 1, n - 1 do col[i] = 0 end
        f[k] = col
      end
      col[n] = v
    end
  end
  for k, col in pairs(f) do
    if col[n] == nil then col[n] = 0 end
  end
end

-- Stand the car back up where it stopped, without a reset (a reset would
-- wipe the canvas), so the photos see the sides that were on the ground.
local function standUpright(veh, groundZ)
  local d = veh:getDirectionVector()
  local flat = vec3(d.x, d.y, 0)
  if flat:length() < 0.1 then flat = v3(run.cfg.home.dir) end
  flat = flat:normalized()
  local cur = quatFromDir(veh:getDirectionVector(), veh:getDirectionVectorUp())
  local diff = cur:inversed() * quatFromDir(flat, vec3(0, 0, 1))
  local p = veh:getPosition()
  local ref = veh:getRefNodeId()
  veh:setClusterPosRelRot(ref, p.x, p.y, groundZ + 0.2, diff.x, diff.y, diff.z, diff.w)
  veh:applyClusterVelocityScaleAdd(ref, 0, 0, 0, 0)
end

local function painterIdle()
  local s = scratches_paint and scratches_paint.getStats and scratches_paint.getStats()
  return not s or (s.queue.stamps == 0 and s.queue.jobs == 0 and (s.queue.bake or 0) == 0)
end

-- ---- the state machine ----

-- Photo camera in the car's own frame, from its final pose: az 0 = behind,
-- 90 = its left, 180 = front, 270 = right; elev = degrees above horizontal.
-- The free camera is placed explicitly, so a car that ended up turned still
-- gets the side it's labelled with.
local function aimSite(site, shot, fallbackFwd)
  local up = vec3(0, 0, 1)
  local n = site.normal
  local flat = vec3(n.x, n.y, 0)
  local camPos, look
  if flat:length() < 0.35 then
    -- Roof / underside: look straight down onto it, nose up the frame.
    camPos = site.pos + up * (n.z >= 0 and 1 or -1) * (shot.dist or 1.6)
    look = (site.pos - camPos):normalized()
    local rot = quatFromDir(look, fallbackFwd)
    return camPos, rot
  end
  flat = flat:normalized()
  -- Swing off the panel normal for a three-quarter view (light rakes across
  -- the scratches the way the reference photos see them), then raise.
  local horiz = rotateAbout(flat, up, shot.swing or 25)
  local el = math.rad(shot.elev or 12)
  local dist = (shot.dist or 1.4) + (shot.distPerRadius or 0.9) * (site.radius or 0)
  camPos = site.pos + (horiz * math.cos(el) + up * math.sin(el)) * dist
  look = (site.pos - camPos):normalized()
  return camPos, quatFromDir(look, up)
end

-- True if a world point is inside the car's spawn box (vehicle-local AABB,
-- shrunk a little so a camera just off a dented panel still counts as out).
local function insideCar(veh, p)
  local inv = veh:getRefNodeMatrix():fullInverse()
  local lp = inv:mulP3F(p)
  local b = veh:getSpawnLocalAABB()
  local s = 0.05
  return lp.x > b.minExtents.x + s and lp.x < b.maxExtents.x - s and lp.y > b.minExtents.y + s
     and lp.y < b.maxExtents.y - s and lp.z > b.minExtents.z + s and lp.z < b.maxExtents.z - s
end

local function aimShot(veh, shot)
  if shot.site then
    local d = veh:getDirectionVector()
    local fwd = vec3(d.x, d.y, 0)
    fwd = fwd:length() > 0.1 and fwd:normalized() or v3(run.cfg.home.dir)
    local site = run.sites and run.sites[shot.site]
    if not site then return false end
    local camPos, rot = aimSite(site, shot, fwd)
    if insideCar(veh, camPos) then
      -- The logged normal pointed into the car: shoot from the other side.
      site.normal = -site.normal
      camPos, rot = aimSite(site, shot, fwd)
      if insideCar(veh, camPos) then return false end
    end
    -- A low site (a sill, a bumper's underside) put a close-up camera on the
    -- ground looking up at the panel's edge: keep it at least knee height.
    local floorZ = veh:getWorldBox().minExtents.z + 0.35
    if camPos.z < floorZ and math.abs(site.normal.z) < 0.9 then
      camPos = vec3(camPos.x, camPos.y, floorZ)
      rot = quatFromDir((site.pos - camPos):normalized(), vec3(0, 0, 1))
    end
    core_camera.setByName(0, 'free')
    core_camera.globalCameraFunction('free', 'setPosition', camPos)
    core_camera.globalCameraFunction('free', 'setRotation', rot)
    return true
  end
  local center = veh:getWorldBox():getCenter()
  local d = veh:getDirectionVector()
  local fwd = vec3(d.x, d.y, 0)
  if fwd:length() < 0.1 then fwd = v3(run.cfg.home.dir) end
  fwd = fwd:normalized()
  local up = vec3(0, 0, 1)
  local left = up:cross(fwd):normalized()
  local az, el = math.rad(shot.az or 0), math.rad(shot.elev or 15)
  local horiz = (-fwd) * math.cos(az) + left * math.sin(az)
  local camPos = center + (horiz * math.cos(el) + up * math.sin(el)) * (shot.dist or 4.5)
  local look = (center - camPos):normalized()
  local rot = quatFromDir(look, math.abs(look.z) > 0.95 and fwd or up)
  core_camera.setByName(0, 'free')
  core_camera.globalCameraFunction('free', 'setPosition', camPos)
  core_camera.globalCameraFunction('free', 'setRotation', rot)
  return true
end

local function step(dtReal)
  local veh = getPlayerVehicle(0)
  if not veh then error('no player vehicle') end
  local cfg = run.cfg
  run.phaseT = run.phaseT + dtReal

  if run.phase == 'prep' then
    -- Upright reset at home: repairs the car and (through the detector's
    -- onReset) wipes the canvas, so every run starts from a clean car.
    run.prevBgLimit = settings and settings.getValue and settings.getValue('fpsLimitBackgroundEnabled')
    setBackgroundLimiter(false)
    -- Footage frames shouldn't carry the HUD (hiding it takes a few frames).
    if cfg.footage and ui_visibility and ui_visibility.get and run.prevUI == nil then
      run.prevUI = ui_visibility.get()
      ui_visibility.set(false)
    end
    -- Same sun for every run, so photos compare across tunings.
    if cfg.tod and scenetree.tod then
      scenetree.tod.time = cfg.tod
      scenetree.tod.play = false
    end
    runChunks(cfg.tuning, veh)
    placeVehicle(veh, v3(cfg.home.pos), v3(cfg.home.dir), v3(cfg.home.up))
    run.needStrikers = cfg.scenario.strikers and #cfg.scenario.strikers > 0
    setShotCamera(veh:getId(), cfg.runCamera or { yaw = 0, pitch = -20, dist = 8 })
    run.phase, run.phaseT = 'settleReset', 0

  elseif run.phase == 'settleReset' then
    if run.needStrikers and run.phaseT >= 0.5 then
      -- Spawned with the car parked at home; they need a couple of seconds
      -- to load before they can be launched.
      spawnStrikers(veh, cfg.home, cfg.scenario.strikers)
      run.needStrikers = false
      run.phaseT = 0
    elseif not run.needStrikers and run.phaseT >= (cfg.resetWait or 1.5) + (#strikers > 0 and 2.0 or 0)
       and painterIdle() then
      -- Obstacles go in with the car still parked at home, so offsets are
      -- measured from its box there.
      spawnObstacles(veh, cfg.home, cfg.scenario.obstacles)
      if cfg.footage then
        -- A fixed camera over the crash, framed in the home frame from the
        -- parked car's box center; the run phases grab frames from it.
        local fc = cfg.footage.cam or {}
        local fwd, right, up = homeFrame(cfg.home)
        local c = veh:getWorldBox():getCenter()
        local camPos = c + fwd * (fc.fwd or -4) + right * (fc.right or -8) + up * (fc.up or 5)
        local target = c + fwd * (fc.lookFwd or 3) + right * (fc.lookRight or 0) + up * (fc.lookUp or 0)
        core_camera.setByName(0, 'free')
        core_camera.globalCameraFunction('free', 'setPosition', camPos)
        core_camera.globalCameraFunction('free', 'setRotation', quatFromDir((target - camPos):normalized(), up))
        if ui_visibility and ui_visibility.get and run.prevUI == nil then
          run.prevUI = ui_visibility.get()
          ui_visibility.set(false)
        end
        run.footage = { n = 0, nextT = 0 }
      end
      local pos, dir, up, vel = launchPose(cfg.home, cfg.scenario)
      run.launchVel = vel
      placeVehicle(veh, pos, dir, up)
      local cmd = "if scratches_detect and scratches_detect.setProfile then scratches_detect.setProfile(true) end"
      if cfg.scenario.coast then
        -- Roll freely into the obstacle: neutral, no brakes, no throttle.
        cmd = cmd .. " if controller.mainController and controller.mainController.shiftToGearIndex then " ..
          "controller.mainController.shiftToGearIndex(0) end " ..
          "input.event('parkingbrake', 0, 2) input.event('brake', 0, 2) input.event('throttle', 0, 2)"
      end
      veh:queueLuaCommand(cmd)
      run.phase, run.phaseT = 'launch', 0
    end

  elseif run.phase == 'launch' then
    -- Give the reset a couple of frames to land before adding velocity.
    if run.phaseT >= 0.05 then
      local v = run.launchVel
      veh:applyClusterVelocityScaleAdd(veh:getRefNodeId(), 0, v.x, v.y, v.z)
      launchStrikers()
      if scratches_paint and scratches_paint.resetPaintStats then scratches_paint.resetPaintStats() end
      if cfg.optick and Engine.Profiler and Engine.Profiler.startCapture then
        Engine.Profiler.startCapture()
        run.optickRunning = true
      end
      run.t, run.still, run.lastClock = 0, 0, nil
      run.phase, run.phaseT = 'run', 0
    end

  elseif run.phase == 'run' or run.phase == 'drain' then
    run.t = run.t + dtReal
    sample(veh)
    local sc = cfg.scenario
    local fo = run.footage
    if fo and run.t >= fo.nextT and fo.n < (cfg.footage.max or 40) then
      fo.n = fo.n + 1
      fo.nextT = fo.nextT + (cfg.footage.every or 0.2)
      createScreenshot2({ filename = string.format('%s/footage_%03d', cfg.shotDir, fo.n), writeJPG = true,
                          superSampling = 1, rescaleFactor = cfg.footage.scale or 0.25 })
    end
    if run.phase == 'run' then
      local speed = run.frames.speed[#run.frames.speed]
      run.still = (speed < (sc.settleSpeed or 0.3)) and (run.still + dtReal) or 0
      local settled = sc.settle ~= false and run.t >= (sc.minTime or 1) and run.still >= (sc.settleTime or 1.0)
      if settled or run.t >= (sc.maxTime or 10) then
        run.settled = settled
        run.runSeconds = run.t
        -- A coasting car glancing off a post keeps rolling; stop it so the
        -- photos find it where the damage is.
        if sc.coast then veh:queueLuaCommand("input.event('parkingbrake', 1, 2) input.event('brake', 1, 2)") end
        run.phase, run.phaseT = 'drain', 0
      end
    elseif painterIdle() or run.phaseT >= 3 then
      run.drainSeconds = run.phaseT
      if run.optickRunning then
        Engine.Profiler.stopCapture()
        run.optickRunning = false
        if cfg.optickPath then
          Engine.Profiler.saveCapture(cfg.optickPath)
          run.optickPath = cfg.optickPath
        end
      end
      run.painterStats = scratches_paint and scratches_paint.getStats and scratches_paint.getStats() or nil
      veh:queueLuaCommand("if scratches_detect and scratches_detect.sendStatsTo then " ..
        "scratches_detect.sendStatsTo('scratches_bench.recvDetect') " ..
        "scratches_detect.setProfile(false) end")
      run.phase, run.phaseT = 'collect', 0
    end

  elseif run.phase == 'collect' then
    if run.detect or run.phaseT >= 2 then
      -- Walls, posts and other cars would block the photos.
      clearObstacles()
      clearStrikers()
      if not cfg.shots or #cfg.shots == 0 then finish(); return end
      if cfg.upright ~= false then
        -- Painting off first, so settling back onto the wheels adds nothing.
        veh:queueLuaCommand("if scratches_detect then scratches_detect.setPaintEnabled(false) end")
        run.paintPaused = true
        standUpright(veh, cfg.home.pos.z)
      end
      run.phase, run.phaseT = 'standing', 0
    end

  elseif run.phase == 'standing' then
    local still = veh:getVelocity():length() < 0.15
    if run.phaseT >= (cfg.upright ~= false and 2.0 or 0.5) and (still or run.phaseT >= 6) then
      if ui_visibility and ui_visibility.get then
        if run.prevUI == nil then run.prevUI = ui_visibility.get() end
        ui_visibility.set(false)
      end
      run.sites = damageSites(veh, cfg.maxSites or 4, cfg.siteRadius or 0.6)
      run.siteInfo = {}
      for i, s in ipairs(run.sites) do
        run.siteInfo[i] = { count = s.count, radius = s.radius,
                            normal = { x = s.normal.x, y = s.normal.y, z = s.normal.z } }
      end
      run.shotIdx, run.shotFiles = 0, {}
      run.phase, run.phaseT = 'nextShot', 0
    end

  elseif run.phase == 'nextShot' then
    -- Advance to the next shot that can be aimed (a close-up of damage site
    -- k is skipped when the car has fewer than k sites).
    repeat
      run.shotIdx = run.shotIdx + 1
      if run.shotIdx > #cfg.shots then finish(); return end
    until aimShot(veh, cfg.shots[run.shotIdx])
    run.phase, run.phaseT = 'aim', 0

  elseif run.phase == 'aim' then
    -- The orbit camera eases toward its target; give it time to arrive.
    if run.phaseT >= (cfg.shotDelay or 0.8) then
      local shot = cfg.shots[run.shotIdx]
      local base = cfg.shotDir .. '/shot_' .. run.shotIdx .. '_' .. (shot.label or 'view')
      createScreenshot2({ filename = base, writeJPG = true, superSampling = 1,
                          rescaleFactor = cfg.shotScale or 0.5 })
      run.shotPending = base .. '.jpg'
      run.phase, run.phaseT = 'shoot', 0
    end

  elseif run.phase == 'shoot' then
    -- Written asynchronously; wait for the file before moving the camera.
    if FS:fileExists(run.shotPending) or run.phaseT >= 5 then
      table.insert(run.shotFiles, run.shotPending)
      run.phase, run.phaseT = 'nextShot', 0
    end
  end
end

-- ---- public API (called by tools/bench.py over MCP) ----

-- cfgJson: { name, home={pos,dir,up}, scenario={offset,euler,vel,minTime,
-- maxTime,settle,settleSpeed,settleTime}, tuning={{vm,code}...}, shots={{yaw,
-- pitch,dist,label}...}, shotDir, shotScale, shotDelay, optick, optickPath }
M.start = function(cfgJson)
  if run then return 'busy: ' .. tostring(run.phase) end
  local cfg = type(cfgJson) == 'string' and jsonDecode(cfgJson) or cfgJson
  if not getPlayerVehicle(0) then return 'error: no player vehicle' end
  run = { cfg = cfg, phase = 'prep', phaseT = 0, t = 0, frames = newFrames(),
          startedAt = clockhp() }
  result = nil
  return 'started'
end

M.abort = function()
  if run then finish('aborted') end
  return 'aborted'
end

M.status = function()
  if run then
    return jsonEncode({ phase = run.phase, t = run.t, frames = #run.frames.t,
                        shot = run.shotIdx, elapsed = clockhp() - run.startedAt })
  end
  return jsonEncode({ phase = result and 'done' or 'idle', error = result and result.error })
end

M.result = function() return result and jsonEncode(result) or '' end

-- Called from the vehicle VM by scratches_detect.sendStatsTo.
M.recvDetect = function(stats, prof)
  if run then run.detect, run.detectProf = stats, prof end
end

-- Replace the player car with model/config in one paint colour
-- ({model, config, color={r,g,b}, metallic, roughness, clearcoat,
-- clearcoatRoughness}). Respawns; follow with applySkin once it's in.
M.spawnCar = function(cfgJson)
  local c = type(cfgJson) == 'string' and jsonDecode(cfgJson) or cfgJson
  local col = c.color or { 0.5, 0.5, 0.5 }
  local paint = createVehiclePaint({ x = col[1], y = col[2], z = col[3], w = 1 },
    { c.metallic or 0.5, c.roughness or 0.4, c.clearcoat or 1, c.clearcoatRoughness or 0.03 })
  core_vehicles.replaceVehicle(c.model, { config = c.config, paint = paint, paint2 = paint, paint3 = paint })
  return 'ok'
end

-- Put the dynamic-textures skin on the player car (evicting any design part,
-- which is fine for a test car) and restart the painter's setup on it.
M.applySkin = function()
  local veh = getPlayerVehicle(0)
  if not veh then return 'error: no player vehicle' end
  core_vehicle_partmgmt.setSkin('dynamicTextures')
  return 'ok'
end

-- Feed a fixed set of detector events straight into the painter, no physics:
-- marks of known force, direction and drag length on the car's right side,
-- front to back. Separates how damage looks from how it gets detected.
-- items: {{kind='i'|'s', fwd, up, force, dist (slides, m), mat='M'|'P'}, ...}
-- with fwd/up in metres from the car's box center along its axes.
M.gallery = function(itemsJson)
  local items = type(itemsJson) == 'string' and jsonDecode(itemsJson) or itemsJson
  local veh = getPlayerVehicle(0)
  if not veh or not scratches_paint then return 'error: no car/painter' end
  local d = veh:getDirectionVector()
  local fwd = vec3(d.x, d.y, 0):normalized()
  local up = vec3(0, 0, 1)
  local right = fwd:cross(up):normalized()
  local c, _, halfWid = carBox(veh)
  local side = halfWid - 0.12
  local events, streams = {}, {}
  for _, it in ipairs(items) do
    local p = c + fwd * (it.fwd or 0) + up * (it.up or 0) + right * side
    local n = -right  -- a contact normal points into the car
    -- Slide direction: along the car, tilted toward up by `ang` degrees.
    local a = math.rad(it.ang or 0)
    local dir = fwd * math.cos(a) + up * math.sin(a)
    if it.kind == 's' then
      local half = 0.5 * (it.dist or 0.5)
      local pts = {}
      for k = 0, 4 do
        local q = p + dir * (-half + 2 * half * k / 4)
        pts[#pts + 1] = { q.x, q.y, q.z, n.x, n.y, n.z }
      end
      pts.m, pts.f = it.mat or 'M', it.force or 2000
      streams[#streams + 1] = pts
    else
      local ts = it.ts or 4
      local dx, dy, dz = 0, 0, 0
      if ts > 0 then dx, dy, dz = dir.x, dir.y, dir.z end
      events[#events + 1] = { p.x, p.y, p.z, n.x, n.y, n.z, 'i', it.force or 5000, it.mat or 'M', dx, dy, dz, ts }
    end
  end
  scratches_paint.ingest(veh:getId(), events, streams)
  return string.format('fed %d events, %d streams', #events, #streams)
end

-- Put the car back at a home pose, repaired (same reset a run starts with).
M.placeHome = function(homeJson)
  local veh = getPlayerVehicle(0)
  if not veh then return 'error: no player vehicle' end
  local home = type(homeJson) == 'string' and jsonDecode(homeJson) or homeJson
  placeVehicle(veh, v3(home.pos), v3(home.dir), v3(home.up))
  return 'ok'
end

-- The car's box center (spawn-local bounds; a detached part on the ground
-- doesn't stretch it the way it stretches the world box), as {x,y,z}.
M.carCenter = function()
  local veh = getPlayerVehicle(0)
  if not veh then return '' end
  local c = carBox(veh)
  return jsonEncode({ x = c.x, y = c.y, z = c.z })
end

-- The car's current pose, in the shape `home` expects.
M.currentPose = function()
  local veh = getPlayerVehicle(0)
  if not veh then return '' end
  local p, d, u = veh:getPosition(), veh:getDirectionVector(), veh:getDirectionVectorUp()
  return jsonEncode({ pos = { x = p.x, y = p.y, z = p.z }, dir = { x = d.x, y = d.y, z = d.z },
                      up = { x = u.x, y = u.y, z = u.z } })
end

local function onUpdate(dtReal)
  if not run then return end
  local ok, err = pcall(step, dtReal or 0)
  if not ok then finish(err) end
end

local function onExtensionUnloaded()
  if run then restore() end
end

local function onInit() setExtensionUnloadMode(M, 'manual') end

M.onUpdate = onUpdate
M.onExtensionUnloaded = onExtensionUnloaded
M.onInit = onInit

return M
