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

-- ---- helpers ----

local function v3(t) return vec3(t.x, t.y, t.z) end

local function rotateAbout(v, axis, deg)
  return quatFromAxisAngle(axis, math.rad(deg)) * v
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
  local v = right * (vel.right or 0) + fwd * (vel.fwd or 0) + up * (vel.up or 0)
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
local function aimShot(veh, shot)
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
    runChunks(cfg.tuning, veh)
    placeVehicle(veh, v3(cfg.home.pos), v3(cfg.home.dir), v3(cfg.home.up))
    setShotCamera(veh:getId(), cfg.runCamera or { yaw = 0, pitch = -20, dist = 8 })
    run.phase, run.phaseT = 'settleReset', 0

  elseif run.phase == 'settleReset' then
    if run.phaseT >= (cfg.resetWait or 1.5) and painterIdle() then
      local pos, dir, up, vel = launchPose(cfg.home, cfg.scenario)
      run.launchVel = vel
      placeVehicle(veh, pos, dir, up)
      veh:queueLuaCommand("if scratches_detect and scratches_detect.setProfile then scratches_detect.setProfile(true) end")
      run.phase, run.phaseT = 'launch', 0
    end

  elseif run.phase == 'launch' then
    -- Give the reset a couple of frames to land before adding velocity.
    if run.phaseT >= 0.05 then
      local v = run.launchVel
      veh:applyClusterVelocityScaleAdd(veh:getRefNodeId(), 0, v.x, v.y, v.z)
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
    if run.phase == 'run' then
      local speed = run.frames.speed[#run.frames.speed]
      run.still = (speed < (sc.settleSpeed or 0.3)) and (run.still + dtReal) or 0
      local settled = sc.settle ~= false and run.t >= (sc.minTime or 1) and run.still >= (sc.settleTime or 1.0)
      if settled or run.t >= (sc.maxTime or 10) then
        run.settled = settled
        run.runSeconds = run.t
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
    if run.phaseT >= (cfg.upright ~= false and 2.0 or 0) then
      if ui_visibility and ui_visibility.get then
        run.prevUI = ui_visibility.get()
        ui_visibility.set(false)
      end
      run.shotIdx, run.shotFiles = 1, {}
      aimShot(veh, cfg.shots[1])
      run.phase, run.phaseT = 'aim', 0
    end

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
      run.shotIdx = run.shotIdx + 1
      if run.shotIdx > #cfg.shots then finish(); return end
      aimShot(veh, cfg.shots[run.shotIdx])
      run.phase, run.phaseT = 'aim', 0
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
