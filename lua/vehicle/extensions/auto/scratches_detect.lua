-- scratches_mod / detect.lua
-- Per-vehicle (VLUA) scrape & impact detector. Wraps the global onNodeCollision
-- callback, filters for body-vs-hard-surface contacts on the player's car, and
-- ships each frame's impacts + finished slide streams to scratches_paint.ingest.

local M = {}

local logTag = "scratches"

-- ---- debug log ring buffer (Phase 1.2) ----
-- Mirrors every mod log line into a fixed-size ring. The GE-side debug panel
-- can't read this VM's console, so updateGFX ships new lines to GE piggybacked
-- on the 0.25s stats push. The local `log` below shadows the global logger so
-- every existing call site in this file is captured for free.
local LOG_RING_MAX = 160
-- Lines dropped per overflow. Trimming in blocks keeps the ring O(1) amortized
-- per push; table.remove(logRing, 1) shifts the whole array on every line once
-- the ring is full — which is exactly when a crash is generating the most log
-- traffic, on the physics VM. Depth floats between MAX-TRIM and MAX.
local LOG_RING_TRIM = 40
local LOG_PUSH_CAP = 30   -- max lines shipped to GE per push (bounds payload)
local logRing      = {}   -- {seq, lvl, msg}; oldest at [1], newest at [#]
local logRingSeq   = 0    -- monotonic id, survives drops
local logPushedSeq = 0    -- highest seq already shipped to GE
local _log         = log  -- the real global logger, captured before shadowing

local function ringPush(lvl, msg)
  logRingSeq = logRingSeq + 1
  logRing[#logRing + 1] = { seq = logRingSeq, lvl = lvl, msg = msg }
  local n = #logRing
  if n > LOG_RING_MAX then
    -- Shift the surviving tail down once, then nil the vacated slots.
    for i = 1, n - LOG_RING_TRIM do logRing[i] = logRing[i + LOG_RING_TRIM] end
    for i = n - LOG_RING_TRIM + 1, n do logRing[i] = nil end
  end
end

-- Shadow the global `log`. Every log(level, tag, msg) call in this file now
-- also lands in the ring. Args are coerced defensively.
local function log(level, tag, msg)
  ringPush(level or 'I', tostring(msg))
  _log(level, tag, msg)
end

-- ---- state ----
local origOnNodeCollision = nil
local materials           = nil   -- particles material table (lazy-loaded)
local nameById            = nil   -- materialId -> name (debug strings)

-- material id sets (populated lazily on first event since particles.* may not
-- be loaded at extension-load time on every vehicle init)
local bodyMatSet    = nil  -- node materials we treat as paintable body
local surfaceMatSet = nil  -- ground materials worth marking against

local enabled       = true
-- Off by default: a sustained slide trips the every-50th-event line ~40x/sec
-- per sliding node, and every one of those is a string.format + a write to
-- beamng.log on the physics VM. Turn on from the console when diagnosing.
local logCandidates = false
local verbose       = false  -- if true, log every candidate. else, throttle.
local logEveryNth   = 50     -- per-node, when not verbose

-- painter coupling
local paintEnabled  = true   -- on in dev; toggle via M.setPaintEnabled(false)
local paintCooldown = 0.003  -- seconds between paints per node (~333 samples/sec/node)

-- per-node counters
local nodeEventCount = {}    -- nid -> total candidate events seen
local nodeEventLast  = {}    -- nid -> count at time of last log
local nodePaintLast  = {}    -- nid -> simTime of last sample appended to stream (slide)
local nodeImpactLast = {}    -- nid -> simTime of last queued impact stamp
local nodeLastContactTime = {} -- nid -> simTime onNodeCollision last fired for this
                               --   node (drives impact-onset detection — see
                               --   IMPACT_REARM_GAP)

-- Per-node filter verdict, computed on a node's first contact and reused for
-- every later one. Wheel-ness, node material and part origin never change for
-- a loaded vehicle (a part swap reloads this whole VM), so re-running the
-- material lookup + lowercase + 18-pattern part scan on every physics tick of
-- every contacting node was pure waste on the hottest path in the mod.
-- Values: a body material name (paintable) or one of the REJ_* sentinels.
local nodeClass = {}
local REJ_NO_NODE, REJ_WHEEL, REJ_BODY_MAT, REJ_PART = 1, 2, 3, 4

-- Per-node slide stream. Each entry is a small table of contact-point samples
-- collected while the node is in active slide contact. Flushed when the node
-- has been idle for STREAM_IDLE_TIMEOUT or the stream hits
-- STREAM_MAX_DURATION / STREAM_MAX_POINTS.
local nodeStreams = {}       -- nid -> { startTime, lastTime, points = {{x,y,z,nx,ny,nz}, ...} }

-- (G) Per-render-frame batch of impact / slide-fallback events.
-- updateGFX packages these AND every stream flushed this frame into ONE
-- queueGameEngineLua call (scratches_paint.ingest). Each event entry is
-- {x,y,z,nx,ny,nz,kind,sev} where kind is:
--   "i" — collision impact (world coords; sev = normalForce in N)
--   "s" — single-point slide fallback (world coords; sev = normalForce in N)
-- The GE side dispatches by kind; (I) scales synth-camera distance by sev.
local pendingDetectEvents = {}
-- Serialized streams flushed this frame, each already a "{{x,y,z,nx,ny,nz},...}"
-- literal. Shipped with pendingDetectEvents — one GE compile per frame instead
-- of one per stream (a big crash flushes dozens of streams a frame).
local pendingStreams = {}

-- aggregate stats since last dumpStats / since load
local stats = {
  totalCalls       = 0,  -- onNodeCollision calls reaching us
  filteredCalls    = 0,  -- passed all filters
  impactEvents     = 0,  -- impact-branch stamps fired (subset of filteredCalls)
  streamsFlushed   = 0,  -- slide brushStroke layers committed
  streamPointsTotal= 0,  -- total points across all flushed streams (avg = total/flushed)
  streamFallbacks  = 0,  -- streams that flushed with 1 point (fell back to single stamp)
  byBodyMat        = {}, -- bodyMatId -> count
  bySurfaceMat     = {}, -- surfaceMatId -> count
  maxSlipVel       = 0,
  maxPerpVel       = 0,
  maxNormalForce   = 0,
  -- reject reasons (so we can see WHY most events got filtered out)
  rejNoNode        = 0,
  rejWheel         = 0,
  rejBodyMat       = 0,
  rejSurfaceMat    = 0,
  rejPartExcluded  = 0,
  rejBelowThresh   = 0,
  rejNormalForce   = 0,
  rejNonFinite     = 0,
}

-- ---- thresholds (from particles.json) ----
-- Tuned more sensitive after H landed: stretched-decal streams are ~25x
-- cheaper than the old brushStroke pipeline, so we can afford to register
-- lighter scrapes / brushes / impacts without overrunning the bake budget.
local SLIP_THRESHOLD     = 0.6    -- m/s, sliding scrape (was 2.5)
local PERP_THRESHOLD     = 0.8    -- m/s, impact-style penetration speed (was 2.5)
local MIN_NORMAL_FORCE   = 10     -- N, reject grazing contacts (was 50)

-- ---- impact-branch params ----
-- Head-on smashes don't trip the slide/perpVel branches: BeamNG's solver
-- cushions perpendicular velocity to ~0 within one tick, so a hard front-end
-- hit produces slipVel≈0 and perpVel≈0 but normalForce in the kN range
-- (observed max ≈95 kN). This branch fires on raw normalForce so impacts
-- register at the moment of contact, not just during the followup grind.
-- 5 kN catches deformation-noise spikes during slides but those layer with
-- the slide stream rather than replacing it (impact and slide both fire
-- when both conditions hold), so the over-firing is desirable visual density.
local IMPACT_FORCE_THRESHOLD = 800    -- N (was 5000; lighter impacts now register)
local IMPACT_COOLDOWN        = 0.025  -- seconds, per-node (was 0.4; F+G+H made
                                       -- per-stamp cost low enough that a node
                                       -- re-impacting during a roll can fire
                                       -- ~4x more often than the original 1.0s)
-- Impact-onset re-arm gap. A genuine impact is the ONSET of contact — a node
-- that was contact-free and is now bearing force. A wrecked car AT REST does
-- the opposite: body nodes lean on the ground and sustain a kN-range
-- normalForce every physics tick indefinitely (observed ~1.4 kN on a settled
-- sideskirt node), which a force-LEVEL gate re-reads as a fresh impact
-- forever. So the impact branch additionally requires the node to have been
-- contact-free for this long before a contact counts as fresh. A resting node
-- fires exactly once (as it settles); a node re-impacting during a roll
-- re-arms each time it leaves and re-touches the ground; an uninterrupted
-- slide never trips the impact branch (its force spikes are slide texture,
-- already carried by the slide stream).
local IMPACT_REARM_GAP = 0.15  -- s; contact-free time before a contact re-arms

-- ---- continuous-slide stream params ----
-- Slide branch collects per-node samples while contact is active and flushes
-- as a single brushStroke layer when the node has been idle. The brushStroke
-- layer interpolates between samples for a continuous swept stroke instead
-- of stacking discrete stamps at body-relative points.
local STREAM_IDLE_TIMEOUT = 0.06  -- s; gap before we treat the slide as ended
local STREAM_MAX_DURATION = 0.25  -- s; force-flush so one camera covers the points
local STREAM_MAX_POINTS   = 80    -- safety cap; MAX_DURATION should bound this earlier
local STREAM_MIN_POINTS   = 2     -- below this, fall back to a single discrete stamp
-- Minimum world distance between kept samples. The GE side chops paths into
-- 0.22 m chunks, so 1.5 cm spacing keeps every bend it can use while a slow
-- grind (the contact barely moving) stops piling near-duplicate points into
-- the payload, the GE parse, and the segmentation pass.
local STREAM_MIN_SPACING_SQ = 0.015 * 0.015

local BODY_MATERIAL_NAMES = {
  "METAL", "PLASTIC", "GLASS",
}
-- Names must exist in lua/common/particles.json "materials" — the ground-model
-- list has no CONCRETE / ASPHALT_PREPPED / SAND_DENSE (concrete barriers and
-- kerbs report as ROCK or ASPHALT). buildSets resolves names exactly and warns
-- about any that don't exist instead of letting particles.getMaterialIDByName
-- silently fall back to id 3 (PLASTIC).
local SURFACE_MATERIAL_NAMES = {
  "ASPHALT", "ASPHALT_WET", "SLIPPERY", "ROCK",
  "METAL", "COBBLESTONE", "RUMBLE_STRIP", "GRAVEL", "SANDY_ROAD",
  -- Anything you might smash into on a typical map:
  "WOOD", "PLASTIC", "RUBBER",
  -- Off-road:
  "DIRT", "DIRT_DUSTY", "SAND", "ICE",
  -- Soft MUD/SNOW/GRASS can load body nodes heavily without abrading paint.
  -- Surface exposure is collected independently before this scratch filter.
  -- Rocks/gravel embedded in terrain still scratch when reported as such.
}

-- Part-name substring deny-list. Matched against node.partOrigin (case-insensitive).
-- A node passes the body-material filter if its `nodeMaterial` is one of
-- BODY_MATERIAL_NAMES — but mechanical parts are ALSO METAL/PLASTIC, so the
-- material filter alone isn't enough. Without this, an internal skidplate or
-- exhaust node firing onNodeCollision triggers a synthetic-camera projection
-- whose ray passes through the non-paintable part and lands on whatever
-- paintable surface is next — typically the windshield from below or the
-- inside of the hood. That's how the windshield spider-web happens.
local EXCLUDE_PART_PATTERNS = {
  "skidplate", "exhaust", "engine", "intake", "suspension",
  "wheel", "axle", "driveshaft", "halfshaft", "differential",
  "gearbox", "transmission", "radiator", "brakerotor", "brake_rotor",
  "fuel_tank", "battery",
  -- Glass nodes shatter into pieces that report wildly inconsistent slipVel
  -- (often 0 even when the rest of the body is sliding fast), and once
  -- broken they're no longer a paintable target — the synth-camera ray
  -- passes through and stamps land on whatever paintable surface is behind
  -- (typically the roof or hood). Excluding them removes both the false
  -- impact-branch hits and the misplaced stamps.
  "windshield", "doorglass",
}

local function buildSets()
  if materials then return true end
  if not particles or not particles.getMaterialsParticlesTable then return false end

  materials = particles.getMaterialsParticlesTable()
  if not materials then return false end

  nameById = {}
  local idByName = {}
  for id, mat in pairs(materials) do
    if type(mat) == "table" and mat.name then
      nameById[id] = mat.name
      idByName[mat.name] = id
    end
  end

  local function resolve(names)
    local set = {}
    for _, name in ipairs(names) do
      local id = idByName[name]
      if id then
        set[id] = name
      else
        log('W', logTag, "unknown ground-model material '" .. name .. "' ignored")
      end
    end
    return set
  end
  bodyMatSet    = resolve(BODY_MATERIAL_NAMES)
  surfaceMatSet = resolve(SURFACE_MATERIAL_NAMES)

  log('I', logTag, string.format(
    "material sets resolved: %d body materials, %d surface materials",
    tableSize(bodyMatSet), tableSize(surfaceMatSet)))
  return true
end

-- ---- stream flushing ----
-- Flush a node's collected stream to GE. Called from updateGFX (idle timeout)
-- and from the slide branch (force-flush at MAX_DURATION/MAX_POINTS).
--
-- 0 points: just clear the entry (nothing to draw).
-- 1 point:  fall back to a single discrete stamp — a stretched decal needs
--           >= 2 points to have a direction.
-- 2+:       serialize as a Lua table literal of {x,y,z,nx,ny,nz} entries onto
--           pendingStreams; updateGFX ships it with the frame's batch.
local function flushStream(id1)
  local s = nodeStreams[id1]
  if not s then return end
  nodeStreams[id1] = nil
  if not (paintEnabled and obj and obj.queueGameEngineLua) then return end

  local n = #s.points
  if n == 0 then return end
  if n < STREAM_MIN_POINTS then
    -- Fallback: 1-point "stream" becomes a single discrete stamp. Batch it
    -- alongside impacts via pendingDetectEvents — flushed in updateGFX as
    -- one queueGameEngineLua call.
    stats.streamFallbacks = stats.streamFallbacks + 1
    local p = s.points[1]
    pendingDetectEvents[#pendingDetectEvents + 1] = {
      p.x, p.y, p.z, p.nx, p.ny, p.nz, "s", p.f or 0,
    }
    return
  end

  -- Build a Lua table-literal payload like {{x,y,z,nx,ny,nz},{...},...}.
  -- Normals only steer the camera axis, so 3 decimals is plenty.
  local parts = {}
  for i, p in ipairs(s.points) do
    parts[i] = string.format("{%.4f,%.4f,%.4f,%.3f,%.3f,%.3f}",
      p.x, p.y, p.z, p.nx, p.ny, p.nz)
  end

  stats.streamsFlushed    = stats.streamsFlushed + 1
  stats.streamPointsTotal = stats.streamPointsTotal + n

  pendingStreams[#pendingStreams + 1] = "{" .. table.concat(parts, ",") .. "}"
end

-- NaN fails x == x; inf and absurd magnitudes fail the bound.
local function finite(x) return x == x and x > -1e9 and x < 1e9 end

-- Resolve (and cache) whether node id1 is a paintable body node. Returns the
-- body material name, or a REJ_* sentinel.
local function classifyNode(id1)
  local node = v.data.nodes and v.data.nodes[id1]
  if not node then return REJ_NO_NODE end
  if node.wheelID then return REJ_WHEEL end
  local bodyName = bodyMatSet[node.nodeMaterial]
  if not bodyName then return REJ_BODY_MAT end
  -- part deny-list (mechanical / non-paintable parts). find with the 4th arg
  -- `true` does plain (non-pattern) substring search.
  local partLower = (node.partOrigin or node.partPath or ""):lower()
  for _, pat in ipairs(EXCLUDE_PART_PATTERNS) do
    if partLower:find(pat, 1, true) then return REJ_PART end
  end
  return bodyName
end

-- Surface exposure is independent of scratch eligibility: tire contacts can
-- dirty the body, but still never create scratches. One sample per kind per
-- 0.25 simulated seconds, regardless of the physics contact rate.
local surfaceKinds = {MUD="mud", DIRT="dirt", DIRT_DUSTY="dirt",
  SAND="dirt", SANDY_ROAD="dirt", GRAVEL="dirt", SNOW="snow"}
local surfacePending, surfaceLast = {}, 0
local waterNodes = nil
local function resetSurface()
  surfacePending, surfaceLast, waterNodes = {}, 0, nil
end
local function surfaceContact(id, pos, normal, speed, force, material)
  if not paintEnabled or not finite(speed) or not finite(force)
      or force < 10 then return end
  local kind = surfaceKinds[nameById[material]]
  if not kind then return end
  local node = v.data.nodes and v.data.nodes[id]
  if not node or (not node.wheelID and type(classifyNode(id)) ~= "string") then return end
  local pending = surfacePending[kind]
  -- Rotate preference over the four standard wheels; retain the first
  -- available wheel as fallback. Body contacts must not starve tire samples.
  local preferredWheel = math.floor(surfaceLast*4)%4
  if pending and (node.wheelID == nil or (pending[7] == 1 and
      (pending[9] == preferredWheel or node.wheelID ~= preferredWheel))) then return end
  -- Vehicle translation admits rolling tires even when contact slip is zero.
  -- Require motion for wheels: stationary wheelspin is not driving buildup.
  if node.wheelID ~= nil then
    local velocity = obj:getVelocity()
    if not velocity or velocity:length() < 0.75 then return end
  elseif speed < 0.5 then return end
  if not (finite(pos.x) and finite(pos.y) and finite(pos.z)
      and finite(normal.x) and finite(normal.y) and finite(normal.z)) then return end
  surfacePending[kind] = {pos.x,pos.y,pos.z,normal.x,normal.y,normal.z,node.wheelID ~= nil and 1 or 0,id,node.wheelID}
end
local function flushSurface(now)
  if not enabled or not paintEnabled then resetSurface(); return end
  if now < surfaceLast then resetSurface() end
  if now - surfaceLast < 0.25 then return end
  surfaceLast = now
  -- Build once, then probe at most eight representative body nodes per tick.
  -- inWater(cid) is used by stock wheels/fire/thermals, not a guessed API.
  if not waterNodes and buildSets() then
    waterNodes = {}
    for id in pairs(v.data.nodes or {}) do
      if type(classifyNode(id)) == "string" then
        waterNodes[#waterNodes+1] = id
      end
    end
    table.sort(waterNodes)
    local all = waterNodes
    waterNodes = {}
    for i = 1, math.min(8, #all) do
      waterNodes[i] = all[math.floor((i-1)*#all/math.min(8,#all))+1]
    end
  end
  local wet, supported = false, type(obj.inWater) == "function"
  local submerged = 0
  if supported then
    for _, id in ipairs(waterNodes or {}) do
      local ok, value = pcall(obj.inWater, obj, id)
      if not ok then supported = false; break end
      wet = wet or value == true
      if value == true then submerged=submerged+1 end
    end
  end
  local parts = {}
  for _, kind in ipairs({"mud", "dirt", "snow"}) do
    local e = surfacePending[kind]
    if e and not wet then
      -- Refresh the emitting node at send time: queued world contacts trail
      -- a moving vehicle by up to a quarter second otherwise.
      if e[7] == 1 then
        local p = obj:getNodePosition(e[8]) + obj:getPosition()
        e[1],e[2],e[3] = p.x,p.y,p.z
      end
      parts[#parts+1] = string.format("{%q,%.4f,%.4f,%.4f,%.3f,%.3f,%.3f,%d}",kind,unpack(e,1,7))
    end
  end
  surfacePending = {}
  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.ingestSurface then scratches_paint.ingestSurface(%d,{%s},%s,%s,%.3f) end",
    obj:getId(), table.concat(parts,","), tostring(wet), tostring(supported),submerged/math.max(1,#(waterNodes or {}))))
end

-- Wheel-side scrapes: a wheel node sliding on a hard surface while the ground
-- normal is roughly parallel to that wheel's axle (the wheel's side faces the
-- ground: car on its side, or a rim grinding a kerb face). At most four per
-- second per wheel, shipped to GE as one batched call per frame.
local WHEEL_SCRAPE_SURFACES = {ASPHALT=true, ASPHALT_WET=true, ROCK=true, COBBLESTONE=true,
  METAL=true, RUMBLE_STRIP=true, GRAVEL=true, CONCRETE=true}
local wheelScrapeLast, pendingWheelScrapes = {}, {}
local function wheelSideScrape(id1, pos, normal, slipVel, normalForce, mat1)
  if not paintEnabled or #pendingWheelScrapes >= 8 then return end
  if not (finite(slipVel) and finite(normalForce)) or slipVel < 1.5 or normalForce < 60 then return end
  if not WHEEL_SCRAPE_SURFACES[nameById[mat1] or ""] then return end
  local node = v.data.nodes and v.data.nodes[id1]
  local wheelId = node and node.wheelID
  local wheel = wheelId ~= nil and v.data.wheels and v.data.wheels[wheelId]
  if not wheel or not wheel.node1 or not wheel.node2 then return end
  local now = (obj and obj.getSimTime and obj:getSimTime()) or 0
  local last = wheelScrapeLast[wheelId]
  if last and now >= last and now - last < 0.25 then return end
  if not (finite(pos.x) and finite(pos.y) and finite(pos.z)
      and finite(normal.x) and finite(normal.y) and finite(normal.z)) then return end
  local a, b = obj:getNodePosition(wheel.node1), obj:getNodePosition(wheel.node2)
  if not a or not b then return end
  local ax, ay, az = a.x - b.x, a.y - b.y, a.z - b.z
  local len = math.sqrt(ax*ax + ay*ay + az*az)
  local nlen = math.sqrt(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z)
  if len < 1e-4 or nlen < 1e-4 then return end
  local along = math.abs(ax*normal.x + ay*normal.y + az*normal.z) / (len * nlen)
  if along < 0.6 then return end
  wheelScrapeLast[wheelId] = now
  stats.wheelScrapes = (stats.wheelScrapes or 0) + 1
  pendingWheelScrapes[#pendingWheelScrapes + 1] = string.format("{%.4f,%.4f,%.4f,%.3f,%.3f,%.3f,%d,%.2f}",
    pos.x, pos.y, pos.z, normal.x/nlen, normal.y/nlen, normal.z/nlen, wheelId, slipVel)
end
local function flushWheelScrapes()
  if #pendingWheelScrapes == 0 then return end
  local body = table.concat(pendingWheelScrapes, ",")
  pendingWheelScrapes = {}
  if not (paintEnabled and obj and obj.queueGameEngineLua) then return end
  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.ingestWheelScrape then " ..
    "pcall(scratches_paint.ingestWheelScrape, %d, {%s}) end", obj:getId(), body))
end

-- ---- the filter ----
local function onScrapeContact(id1, pos, normal, nodeVel, perpVel, slipVec, slipVel,
                                slipForce, normalForce, depth, mat1, mat2)
  if not enabled then return end
  -- The painter only ever decorates the player's car, but this extension is
  -- auto-loaded into EVERY vehicle — AI traffic included. Without this gate
  -- each traffic car ran the full filter on every contact and shipped its
  -- world-space hits to GE, where they were converted with the PLAYER's
  -- matrix and stamped onto the player's body.
  if not playerInfo.firstPlayerSeated then return end
  stats.totalCalls = stats.totalCalls + 1

  if not buildSets() then return end

  surfaceContact(id1, pos, normal, slipVel, normalForce, mat1)

  local bodyName = nodeClass[id1]
  if bodyName == nil then
    bodyName = classifyNode(id1)
    nodeClass[id1] = bodyName
  end
  if bodyName == REJ_WHEEL then
    stats.rejWheel = stats.rejWheel + 1
    wheelSideScrape(id1, pos, normal, slipVel, normalForce, mat1)
    return
  end
  if bodyName == REJ_BODY_MAT then stats.rejBodyMat = stats.rejBodyMat + 1; return end
  if bodyName == REJ_PART then stats.rejPartExcluded = stats.rejPartExcluded + 1; return end
  if bodyName == REJ_NO_NODE then stats.rejNoNode = stats.rejNoNode + 1; return end
  local node = v.data.nodes[id1]

  -- surface material: materialId1 is what the node hit (the ground-model
  -- material, e.g. ASPHALT); materialId2 is the node's own material.
  -- Verified in game by tallying (mat1, mat2) pairs during a slide.
  local surfaceName = surfaceMatSet[mat1]
  if not surfaceName then stats.rejSurfaceMat = stats.rejSurfaceMat + 1; return end

  -- magnitude
  local now = (obj and obj.getSimTime and obj:getSimTime()) or 0
  local sliding   = slipVel >= SLIP_THRESHOLD
  local impacting = perpVel >= PERP_THRESHOLD
  -- Impact-onset gate. The impact branch fires on raw normalForce because a
  -- head-on smash cushions slipVel/perpVel to ~0 within a tick but spikes
  -- force into the kN range. The catch: a wrecked car AT REST produces the
  -- same signature — body nodes resting on the ground sustain kN-range
  -- normalForce every tick — so a force-level gate alone re-fires that
  -- "impact" forever. We additionally require the node to have been
  -- contact-free for IMPACT_REARM_GAP: a fresh contact is an impact, a
  -- sustained load is not. nodeLastContactTime is refreshed below for every
  -- body-vs-surface contact tick, so a continuously-loaded node never
  -- re-arms (and an uninterrupted slide, being continuous contact, no longer
  -- double-fires the impact branch — its texture is the slide stream's job).
  local prevContact  = nodeLastContactTime[id1]
  local freshContact = (prevContact == nil) or ((now - prevContact) >= IMPACT_REARM_GAP)
  nodeLastContactTime[id1] = now
  local impactHit = (normalForce >= IMPACT_FORCE_THRESHOLD) and freshContact
  if not (sliding or impacting or impactHit) then stats.rejBelowThresh = stats.rejBelowThresh + 1; return end
  -- Grazing-contact floor only applies to slide events. impactHit is
  -- already gated on a much higher normalForce, so this check is redundant
  -- (and would never reject) for it.
  if not impactHit and normalForce < MIN_NORMAL_FORCE then stats.rejNormalForce = stats.rejNormalForce + 1; return end

  -- passed all filters
  stats.filteredCalls = stats.filteredCalls + 1
  stats.byBodyMat[bodyName]      = (stats.byBodyMat[bodyName] or 0) + 1
  stats.bySurfaceMat[surfaceName] = (stats.bySurfaceMat[surfaceName] or 0) + 1
  if slipVel     > stats.maxSlipVel     then stats.maxSlipVel     = slipVel     end
  if perpVel     > stats.maxPerpVel     then stats.maxPerpVel     = perpVel     end
  if normalForce > stats.maxNormalForce then stats.maxNormalForce = normalForce end

  local n = (nodeEventCount[id1] or 0) + 1
  nodeEventCount[id1] = n

  -- logCandidates gates only this log line, never the paint coupling below.
  local shouldLog = logCandidates and verbose
  if logCandidates and not shouldLog then
    local last = nodeEventLast[id1] or 0
    if n - last >= logEveryNth then
      shouldLog = true
      nodeEventLast[id1] = n
    end
  end

  if shouldLog then
    local kind
    if impactHit then
      kind = "IMPACT"
    elseif sliding and impacting then
      kind = "SLIDE+HIT"
    elseif sliding then
      kind = "SLIDE"
    else
      kind = "HIT"
    end
    local part = node.partOrigin or node.partPath or "?"
    log('I', logTag, string.format(
      "%s n=%d (#%d) part=%s body=%s surf=%s slipVel=%.2f perpVel=%.2f normF=%.0f depth=%.4f pos=(%.2f,%.2f,%.2f)",
      kind, id1, n, part, bodyName, surfaceName,
      slipVel, perpVel, normalForce, depth, pos.x, pos.y, pos.z))
  end

  -- Paint coupling: queue GE-side stamps. Both branches can fire on the
  -- same tick (intentional layering — user wants density):
  --   (a) impactHit (high normalForce) — splat at the contact point with
  --       its own per-node cooldown so we don't get 2000 splats/sec.
  --   (b) slide/impacting (high slipVel or perpVel) — appends to the
  --       per-node brushStroke stream, which flushes on idle timeout.
  -- Fire-and-forget: we don't observe the result; failures will surface as
  -- silent missing decals (paint.lua logs its own diagnostics on stampAt).
  -- A NaN/inf sample (exploding node) would format as nan/inf, which the GE
  -- chunk reads as undefined globals — losing the WHOLE frame's batch, since
  -- streams and impacts share one call. Drop just the bad sample instead.
  if not (finite(pos.x) and finite(pos.y) and finite(pos.z)
          and finite(normal.x) and finite(normal.y) and finite(normal.z)
          and finite(normalForce)) then
    stats.rejNonFinite = stats.rejNonFinite + 1
    return
  end
  if paintEnabled and obj and obj.queueGameEngineLua then
    -- `now` is the simTime resolved in the magnitude section above.
    if impactHit then
      local lastImpact = nodeImpactLast[id1] or 0
      if now - lastImpact >= IMPACT_COOLDOWN then
        nodeImpactLast[id1] = now
        stats.impactEvents = stats.impactEvents + 1
        -- (G) Batch with other impacts/fallbacks; updateGFX flushes once per frame.
        -- (I) Pass normalForce so the GE synth camera can adapt distance to
        -- impact severity — heavy hits deform panels enough that a close
        -- camera plunges into the dent instead of grazing the outer edge.
        -- The slip velocity orients a glancing blow's marks (0,0,0 if unusable).
        local sx, sy, sz = 0, 0, 0
        if slipVec and finite(slipVec.x) and finite(slipVec.y) and finite(slipVec.z) then
          sx, sy, sz = slipVec.x, slipVec.y, slipVec.z
        end
        pendingDetectEvents[#pendingDetectEvents + 1] = {
          pos.x, pos.y, pos.z, normal.x, normal.y, normal.z, "i", normalForce, sx, sy, sz,
        }
      end
      -- Fall through — slide branch can also fire on this tick.
    end

    -- Slide branch: throttle sample collection to paintCooldown per node and
    -- append to the per-node stream. Real flush happens on idle timeout
    -- (updateGFX) or on force-flush below. The brushStroke layer the flush
    -- builds interpolates between samples for a continuous swept stroke.
    -- Gate on slide/perpVel — pure-impact events (impactHit only) should
    -- not feed the slide stream; they've already been stamped as splats.
    if not (sliding or impacting) then return end
    local last = nodePaintLast[id1] or 0
    if now - last >= paintCooldown then
      nodePaintLast[id1] = now

      -- Flush-and-restart if the existing stream has gone stale. updateGFX
      -- normally handles idle flushing per render frame, but a new slide
      -- event can arrive between render frames, so check inline too.
      local stream = nodeStreams[id1]
      if stream and (now - stream.lastTime) >= STREAM_IDLE_TIMEOUT then
        flushStream(id1)
        stream = nil
      end
      if not stream then
        stream = { startTime = now, lastTime = now, points = {} }
        nodeStreams[id1] = stream
      end
      stream.lastTime = now
      local pts  = stream.points
      local prev = pts[#pts]
      local px, py, pz = pos.x, pos.y, pos.z
      if prev then
        local dx, dy, dz = px - prev.x, py - prev.y, pz - prev.z
        if dx*dx + dy*dy + dz*dz < STREAM_MIN_SPACING_SQ then
          -- Contact hasn't moved enough to add shape; keep the stream alive
          -- (lastTime above) and remember the stronger force for the fallback.
          if normalForce > prev.f then prev.f = normalForce end
          return
        end
      end
      pts[#pts + 1] = {
        x = px, y = py, z = pz,
        nx = normal.x, ny = normal.y, nz = normal.z,
        f  = normalForce,  -- (I) force per sample; drives the fallback's
                           --     synth-camera distance if the stream ends
                           --     up <STREAM_MIN_POINTS.
      }

      -- Force-flush if the stream exceeds MAX_DURATION (camera coverage
      -- starts to fail for points spread over a large body extent) or hits
      -- MAX_POINTS (memory safety). A long continuous slide produces several
      -- adjacent brushStroke layers that visually stitch together.
      if (now - stream.startTime) >= STREAM_MAX_DURATION
         or #stream.points >= STREAM_MAX_POINTS then
        flushStream(id1)
      end
    end
  end
end

-- (G) Flush the frame's impact/fallback events AND flushed streams as ONE
-- queueGameEngineLua call. Empty case is the common one (cheap early-out).
-- The vehicle id rides along so GE can drop a batch that arrives after the
-- player has switched cars — it would otherwise be converted with the new
-- car's matrix and land on the wrong body.
local function flushDetectEvents()
  local n, ns = #pendingDetectEvents, #pendingStreams
  if n == 0 and ns == 0 then return end
  if not (paintEnabled and obj and obj.queueGameEngineLua) then
    pendingDetectEvents = {}
    pendingStreams = {}
    return
  end
  local parts = {}
  for i = 1, n do
    local e = pendingDetectEvents[i]
    parts[i] = string.format("{%.4f,%.4f,%.4f,%.3f,%.3f,%.3f,%q,%.0f,%.2f,%.2f,%.2f}",
      e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8] or 0, e[9] or 0, e[10] or 0, e[11] or 0)
  end
  local streams = table.concat(pendingStreams, ",")
  pendingDetectEvents = {}
  pendingStreams = {}
  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.ingest then " ..
    "  pcall(scratches_paint.ingest, %d, {%s}, {%s}) " ..
    "end",
    obj:getId(), table.concat(parts, ","), streams))
end

-- (K) Periodic stats push to GE so the IMGUI debug panel can read VLUA-side
-- counts and current threshold values without needing a query mechanism.
-- Pushed via queueGameEngineLua; cheap (one Lua compile per ~0.25s).
local lastStatsPush     = 0

-- ---- opt-in profiler (tools/bench.py) ----
-- Off by default, where it costs one boolean test per contact. On, every
-- contact and every updateGFX is timed with os.clockhp; frameMs is the
-- detector's total for one render frame (contacts since the last updateGFX
-- plus updateGFX itself).
local profiling = false
local clockhp = os.clockhp or os.clock
local prof = { contactMs = 0, contacts = 0, gfxMs = 0, frames = 0, frameMsMax = 0, frameMsPending = 0 }
local STATS_PUSH_PERIOD = 0.25  -- seconds

local function pushStatsToGE(now)
  if not (paintEnabled and obj and obj.queueGameEngineLua) then return end
  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.recordDetectStats then " ..
    "  pcall(scratches_paint.recordDetectStats, {" ..
    "totalCalls=%d,filteredCalls=%d,impactEvents=%d," ..
    "streamsFlushed=%d,slip=%.3f,perp=%.3f,minForce=%.0f," ..
    "impForce=%.0f,impCool=%.3f,paintCool=%.4f," ..
    "maxNormalForce=%.0f}) " ..
    "end",
    stats.totalCalls, stats.filteredCalls, stats.impactEvents,
    stats.streamsFlushed,
    SLIP_THRESHOLD, PERP_THRESHOLD, MIN_NORMAL_FORCE,
    IMPACT_FORCE_THRESHOLD, IMPACT_COOLDOWN, paintCooldown,
    stats.maxNormalForce))
end

-- (1.2) Ship VLUA log lines newer than logPushedSeq to GE so they land in the
-- shared log ring the debug panel reads. string.format("%q") escapes each
-- message safely for embedding in the generated Lua source. Capped per push.
local function pushLogsToGE()
  if not (obj and obj.queueGameEngineLua) then return end
  local parts, count = {}, 0
  for i = 1, #logRing do
    local e = logRing[i]
    if e.seq > logPushedSeq then
      parts[#parts + 1] = string.format("{%q,%q}", e.lvl or 'I', e.msg or '')
      logPushedSeq = e.seq
      count = count + 1
      if count >= LOG_PUSH_CAP then break end
    end
  end
  if count == 0 then return end
  obj:queueGameEngineLua(
    "if scratches_paint and scratches_paint.recordDetectLog then " ..
    "  pcall(scratches_paint.recordDetectLog, {" .. table.concat(parts, ",") .. "}) " ..
    "end")
end

-- ---- per-frame: idle-flush streams + flush event batch ----
-- Walks the stream table once per render frame; cheap because the table is
-- empty whenever no node is in slide contact. Any stream whose last sample
-- is older than STREAM_IDLE_TIMEOUT is flushed.
local function detectFrame(dt)
  if not (obj and obj.getSimTime) then return end
  -- Non-player vehicles (traffic, parked cars) do nothing at all. If the
  -- player just left this car, drop its half-built work instead of shipping
  -- it to a painter that is now decorating a different vehicle.
  if not playerInfo.firstPlayerSeated then
    resetSurface()
    if next(nodeStreams) ~= nil then table.clear(nodeStreams) end
    if #pendingDetectEvents > 0 then pendingDetectEvents = {} end
    if #pendingStreams > 0 then pendingStreams = {} end
    if #pendingWheelScrapes > 0 then pendingWheelScrapes = {} end
    return
  end
  local now = obj:getSimTime() or 0
  -- Idle-flush streams first so anything that ended this frame rides in the
  -- same GE call as the frame's impacts.
  if next(nodeStreams) ~= nil then
    for nid, s in pairs(nodeStreams) do
      if (now - s.lastTime) >= STREAM_IDLE_TIMEOUT then
        flushStream(nid)
      end
    end
  end
  flushSurface(now)
  flushDetectEvents()
  flushWheelScrapes()
  -- (K) Throttled stats push to drive the GE-side IMGUI panel.
  if (now - lastStatsPush) >= STATS_PUSH_PERIOD then
    pushStatsToGE(now)
    pushLogsToGE()
    lastStatsPush = now
  end
end

local function updateGFX(dt)
  if not profiling then return detectFrame(dt) end
  local t = clockhp()
  detectFrame(dt)
  local ms = (clockhp() - t) * 1000
  prof.gfxMs = prof.gfxMs + ms
  prof.frames = prof.frames + 1
  local frameMs = prof.frameMsPending + ms
  if frameMs > prof.frameMsMax then prof.frameMsMax = frameMs end
  prof.frameMsPending = 0
end

-- ---- wrap / unwrap ----
local function install()
  if origOnNodeCollision then return end  -- already wrapped, idempotent
  origOnNodeCollision = _G.onNodeCollision
  if type(origOnNodeCollision) ~= "function" then
    log('E', logTag, "global onNodeCollision is not a function; cannot install")
    origOnNodeCollision = nil
    return
  end
  _G.onNodeCollision = function(...)
    origOnNodeCollision(...)
    if profiling then
      local t = clockhp()
      onScrapeContact(...)
      local ms = (clockhp() - t) * 1000
      prof.contactMs = prof.contactMs + ms
      prof.contacts = prof.contacts + 1
      prof.frameMsPending = prof.frameMsPending + ms
    else
      onScrapeContact(...)
    end
  end
  log('I', logTag, "detect installed (wrapping onNodeCollision)")
end

local function uninstall()
  if not origOnNodeCollision then return end
  -- only restore if no one else has wrapped on top of us
  -- (best-effort; if a third party also wrapped, we can't safely unwind)
  _G.onNodeCollision = origOnNodeCollision
  origOnNodeCollision = nil
  log('I', logTag, "detect uninstalled")
end

-- ---- public probes (call from in-game ~ console as
--      `scratches_detect.dumpStats()` etc.) ----
M.dumpStats = function()
  log('I', logTag, "----- stats -----")
  log('I', logTag, string.format("totalCalls    = %d", stats.totalCalls))
  log('I', logTag, string.format("filteredCalls = %d", stats.filteredCalls))
  log('I', logTag, string.format("impactEvents  = %d  (threshold %.0f N, cooldown %.2fs)",
    stats.impactEvents, IMPACT_FORCE_THRESHOLD, IMPACT_COOLDOWN))
  log('I', logTag, string.format("streams       = %d flushed, %d fallbacks, avg %.1f points/stream",
    stats.streamsFlushed, stats.streamFallbacks,
    stats.streamsFlushed > 0 and (stats.streamPointsTotal / stats.streamsFlushed) or 0))
  log('I', logTag, string.format("active streams= %d", (function()
    local n = 0; for _ in pairs(nodeStreams) do n = n + 1 end; return n
  end)()))
  log('I', logTag, string.format("max slipVel   = %.2f m/s", stats.maxSlipVel))
  log('I', logTag, string.format("max perpVel   = %.2f m/s", stats.maxPerpVel))
  log('I', logTag, string.format("max normalForce = %.0f N", stats.maxNormalForce))
  log('I', logTag, "rejected by reason:")
  log('I', logTag, string.format("  noNode        = %d", stats.rejNoNode))
  log('I', logTag, string.format("  wheel         = %d", stats.rejWheel))
  log('I', logTag, string.format("  bodyMat       = %d", stats.rejBodyMat))
  log('I', logTag, string.format("  partExcluded  = %d", stats.rejPartExcluded))
  log('I', logTag, string.format("  surfaceMat    = %d", stats.rejSurfaceMat))
  log('I', logTag, string.format("  belowThresh   = %d", stats.rejBelowThresh))
  log('I', logTag, string.format("  normalForce   = %d", stats.rejNormalForce))
  log('I', logTag, string.format("  nonFinite     = %d", stats.rejNonFinite))
  log('I', logTag, "by body material:")
  for n, c in pairs(stats.byBodyMat) do log('I', logTag, string.format("  %-12s %d", n, c)) end
  log('I', logTag, "by surface material:")
  for n, c in pairs(stats.bySurfaceMat) do log('I', logTag, string.format("  %-12s %d", n, c)) end
  log('I', logTag, "top nodes by event count:")
  local sorted = {}
  for nid, c in pairs(nodeEventCount) do table.insert(sorted, {nid = nid, c = c}) end
  table.sort(sorted, function(a, b) return a.c > b.c end)
  for i = 1, math.min(10, #sorted) do
    local e = sorted[i]
    local node = v.data.nodes and v.data.nodes[e.nid]
    local part = node and (node.partOrigin or node.partPath) or "?"
    log('I', logTag, string.format("  node %-5d  events=%-6d  part=%s", e.nid, e.c, part))
  end
end

-- (M) Build the dumpStats output as one multi-line string and push it to GE
-- so the IMGUI debug panel can render it inline. Lets the user grab a single
-- screenshot of UI + full stats instead of UI + console.
M.pushFullDumpToGE = function()
  if not (obj and obj.queueGameEngineLua) then return end
  local lines = {}
  local function add(s) lines[#lines + 1] = s end
  add(string.format("totalCalls    = %d", stats.totalCalls))
  add(string.format("filteredCalls = %d", stats.filteredCalls))
  add(string.format("impactEvents  = %d  (threshold %.0f N, cooldown %.2fs)",
    stats.impactEvents, IMPACT_FORCE_THRESHOLD, IMPACT_COOLDOWN))
  add(string.format("streams       = %d flushed, %d fallbacks, avg %.1f pts/stream",
    stats.streamsFlushed, stats.streamFallbacks,
    stats.streamsFlushed > 0 and (stats.streamPointsTotal / stats.streamsFlushed) or 0))
  local active = 0; for _ in pairs(nodeStreams) do active = active + 1 end
  add(string.format("active streams= %d", active))
  add(string.format("max slipVel   = %.2f m/s", stats.maxSlipVel))
  add(string.format("max perpVel   = %.2f m/s", stats.maxPerpVel))
  add(string.format("max normForce = %.0f N", stats.maxNormalForce))
  add("rejected by reason:")
  add(string.format("  noNode       = %d", stats.rejNoNode))
  add(string.format("  wheel        = %d", stats.rejWheel))
  add(string.format("  bodyMat      = %d", stats.rejBodyMat))
  add(string.format("  partExcluded = %d", stats.rejPartExcluded))
  add(string.format("  surfaceMat   = %d", stats.rejSurfaceMat))
  add(string.format("  belowThresh  = %d", stats.rejBelowThresh))
  add(string.format("  normalForce  = %d", stats.rejNormalForce))
  add(string.format("  nonFinite    = %d", stats.rejNonFinite))
  add("by body material:")
  for n, c in pairs(stats.byBodyMat) do add(string.format("  %-12s %d", n, c)) end
  add("by surface material:")
  for n, c in pairs(stats.bySurfaceMat) do add(string.format("  %-12s %d", n, c)) end
  add("top nodes by event count:")
  local sorted = {}
  for nid, c in pairs(nodeEventCount) do table.insert(sorted, {nid = nid, c = c}) end
  table.sort(sorted, function(a, b) return a.c > b.c end)
  for i = 1, math.min(10, #sorted) do
    local e = sorted[i]
    local nd = v.data.nodes and v.data.nodes[e.nid]
    local part = nd and (nd.partOrigin or nd.partPath) or "?"
    add(string.format("  node %-5d events=%-5d %s", e.nid, e.c, part))
  end
  local text = table.concat(lines, "\n")
  -- %q safely escapes quotes/backslashes/newlines for Lua source.
  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.recordFullDump then " ..
    "  pcall(scratches_paint.recordFullDump, %q) " ..
    "end", text))
end

M.resetStats = function()
  stats = {
    totalCalls = 0, filteredCalls = 0, impactEvents = 0,
    streamsFlushed = 0, streamPointsTotal = 0, streamFallbacks = 0,
    byBodyMat = {}, bySurfaceMat = {},
    maxSlipVel = 0, maxPerpVel = 0, maxNormalForce = 0,
    rejNoNode = 0, rejWheel = 0, rejBodyMat = 0,
    rejSurfaceMat = 0, rejPartExcluded = 0,
    rejBelowThresh = 0, rejNormalForce = 0, rejNonFinite = 0,
  }
  table.clear(nodeEventCount)
  table.clear(nodeEventLast)
  log('I', logTag, "stats reset")
end

M.setProfile = function(b)
  profiling = b and true or false
  for k in pairs(prof) do prof[k] = 0 end
  log('I', logTag, "profiling = " .. tostring(profiling))
end

-- Lua table literal of numbers and number maps (stats + prof), for shipping
-- to GE in one queueGameEngineLua call.
local function numLiteral(t)
  local parts = {}
  for k, v in pairs(t) do
    local key = string.format("[%q]", tostring(k))
    if type(v) == "number" then
      parts[#parts + 1] = key .. "=" .. string.format("%.17g", v)
    elseif type(v) == "table" then
      parts[#parts + 1] = key .. "=" .. numLiteral(v)
    end
  end
  return "{" .. table.concat(parts, ",") .. "}"
end

-- Send stats + profile to a GE callback, e.g. "scratches_bench.recvDetect".
-- Only a plain module.function name is accepted; it is spliced into GE code.
M.sendStatsTo = function(geFn)
  local mod, fn = tostring(geFn):match("^([%a_][%w_]*)%.([%a_][%w_]*)$")
  if not (mod and obj and obj.queueGameEngineLua) then return end
  obj:queueGameEngineLua(string.format("if %s and %s.%s then %s.%s(%s, %s) end",
    mod, mod, fn, mod, fn, numLiteral(stats), numLiteral(prof)))
end

M.setEnabled = function(b)
  enabled = b and true or false
  if not enabled then resetSurface() end
  log('I', logTag, "enabled = " .. tostring(enabled))
end

M.setLog = function(b)
  logCandidates = b and true or false
  log('I', logTag, "logCandidates = " .. tostring(logCandidates))
end

M.setVerbose = function(b)
  verbose = b and true or false
  log('I', logTag, "verbose = " .. tostring(verbose))
end

M.setThresholds = function(slip, perp, normalForce)
  if slip        then SLIP_THRESHOLD   = slip end
  if perp        then PERP_THRESHOLD   = perp end
  if normalForce then MIN_NORMAL_FORCE = normalForce end
  log('I', logTag, string.format("thresholds: slipVel>=%.2f perpVel>=%.2f normalForce>=%.0f",
    SLIP_THRESHOLD, PERP_THRESHOLD, MIN_NORMAL_FORCE))
end

M.setPaintEnabled = function(b)
  paintEnabled = b and true or false
  if not paintEnabled then resetSurface() end
  log('I', logTag, "paintEnabled = " .. tostring(paintEnabled))
end

M.setPaintCooldown = function(secs)
  paintCooldown = math.max(0, tonumber(secs) or 0)
  log('I', logTag, string.format("paintCooldown = %.3fs (per node)", paintCooldown))
end

M.setImpactParams = function(threshold, cooldown)
  if threshold then IMPACT_FORCE_THRESHOLD = math.max(0, tonumber(threshold) or 0) end
  if cooldown  then IMPACT_COOLDOWN        = math.max(0, tonumber(cooldown)  or 0) end
  log('I', logTag, string.format("impact: threshold>=%.0f N, cooldown=%.2fs",
    IMPACT_FORCE_THRESHOLD, IMPACT_COOLDOWN))
end

M.dumpMaterials = function()
  if not buildSets() then log('I', logTag, "materials not yet available"); return end
  log('I', logTag, "----- material id -> name -----")
  local ids = {}
  for id in pairs(nameById) do table.insert(ids, id) end
  table.sort(ids)
  for _, id in ipairs(ids) do log('I', logTag, string.format("  %3d  %s", id, nameById[id])) end
  log('I', logTag, "active body set:")
  for id, n in pairs(bodyMatSet) do log('I', logTag, string.format("  %3d  %s", id, n)) end
  log('I', logTag, "active surface set:")
  for id, n in pairs(surfaceMatSet) do log('I', logTag, string.format("  %3d  %s", id, n)) end
end

M.dumpNode = function(cid)
  local node = v.data.nodes and v.data.nodes[cid]
  if not node then log('I', logTag, "no node with cid " .. tostring(cid)); return end
  log('I', logTag, "----- node " .. cid .. " -----")
  dump(node)
end

-- ---- lifecycle ----

-- Bootstrap the GELUA painter. extensions.load is idempotent so it's safe to
-- call from multiple lifecycle hooks. We need this because:
--   - GELUA has no auto-load directory equivalent to vehicle/extensions/auto/.
--   - onExtensionLoaded only fires on fresh extension load (initial spawn or
--     full game restart), NOT on Ctrl+R reset.
-- So we also fire from onReset so a Ctrl+R picks up the painter after a code
-- edit even if the VLUA extension itself was already resident.
local function bootstrapPainter()
  if obj and obj.queueGameEngineLua then
    obj:queueGameEngineLua("extensions.load('scratches_paint')")
  end
end

local function onExtensionLoaded()
  install()
  bootstrapPainter()
  log('I', logTag, "loaded. probes: scratches_detect.{dumpStats,pushFullDumpToGE,dumpMaterials,dumpNode,setLog,setVerbose,setEnabled,setThresholds,setImpactParams,setPaintEnabled,setPaintCooldown,resetStats}")
  return true
end

local function onExtensionUnloaded()
  uninstall()
end

local function onReset()
  resetSurface()
  -- vehicle reset (Ctrl+R)
  log('I', logTag, "onReset (Ctrl+R) - clearing detect state, requesting GE clearStamps")
  M.resetStats()
  table.clear(nodePaintLast)
  table.clear(nodeImpactLast)
  table.clear(nodeLastContactTime)
  table.clear(nodeStreams)
  pendingDetectEvents = {}
  pendingStreams = {}
  bootstrapPainter()
  -- Wipe baked decals on the GE side so the reset cleans up cosmetics too.
  -- pcall-guarded on GE because scratches_paint may not be loaded yet on a
  -- very early reset (just after vehicle spawn, before bootstrap completes).
  -- Only the player's own reset may do this: the painter decorates the
  -- player's car, so a traffic car resetting must not wipe it.
  if playerInfo.firstPlayerSeated and obj and obj.queueGameEngineLua then
    obj:queueGameEngineLua(
      "if scratches_paint and scratches_paint.clearStamps then " ..
      "  pcall(scratches_paint.clearStamps) " ..
      "end")
  end
end

local function onInit()
  -- fired once per vehicle init, after extensions are loaded
  bootstrapPainter()
end

M.onExtensionLoaded   = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onReset             = onReset
M.onInit              = onInit
M.updateGFX           = updateGFX

return M
