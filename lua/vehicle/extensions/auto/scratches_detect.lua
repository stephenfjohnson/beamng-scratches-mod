-- scratches_mod / detect.lua
-- Per-vehicle (VLUA) scrape & impact detector. Wraps the global onNodeCollision
-- callback, filters for body-vs-hard-surface contacts, and logs candidate
-- events to the console. Phase 1: log only, no painter calls.

local M = {}

local logTag = "scratches"

-- ---- debug log ring buffer (Phase 1.2) ----
-- Mirrors every mod log line into a fixed-size ring. The GE-side debug panel
-- can't read this VM's console, so updateGFX ships new lines to GE piggybacked
-- on the 0.25s stats push. The local `log` below shadows the global logger so
-- every existing call site in this file is captured for free.
local LOG_RING_MAX = 160
local LOG_PUSH_CAP = 30   -- max lines shipped to GE per push (bounds payload)
local logRing      = {}   -- {seq, lvl, msg}; oldest at [1], newest at [#]
local logRingSeq   = 0    -- monotonic id, survives drops
local logPushedSeq = 0    -- highest seq already shipped to GE
local _log         = log  -- the real global logger, captured before shadowing

local function ringPush(lvl, msg)
  logRingSeq = logRingSeq + 1
  logRing[#logRing + 1] = { seq = logRingSeq, lvl = lvl, msg = msg }
  if #logRing > LOG_RING_MAX then table.remove(logRing, 1) end
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
local logCandidates = true
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

-- Per-node slide stream. Each entry is a small table of contact-point samples
-- collected while the node is in active slide contact. Flushed as a single
-- brushStroke layer when the node has been idle for STREAM_IDLE_TIMEOUT or
-- the stream hits STREAM_MAX_DURATION / STREAM_MAX_POINTS.
local nodeStreams = {}       -- nid -> { startTime, lastTime, points = {{x,y,z,nx,ny,nz}, ...} }

-- (G) Per-render-frame batch of impact / slide-fallback events.
-- updateGFX packages all of these into one queueGameEngineLua call as
-- scratches_paint.stampBatch({...}). Each entry is {x,y,z,nx,ny,nz,kind,sev}
-- where kind is:
--   "i" — collision impact (world coords; sev = normalForce in N)
--   "s" — single-point slide fallback (world coords; sev = normalForce in N)
-- The GE side dispatches by kind; (I) scales synth-camera distance by sev.
local pendingDetectEvents = {}

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

-- ---- continuous-slide stream params ----
-- Slide branch collects per-node samples while contact is active and flushes
-- as a single brushStroke layer when the node has been idle. The brushStroke
-- layer interpolates between samples for a continuous swept stroke instead
-- of stacking discrete stamps at body-relative points.
local STREAM_IDLE_TIMEOUT = 0.06  -- s; gap before we treat the slide as ended
local STREAM_MAX_DURATION = 0.25  -- s; force-flush so one camera covers the points
local STREAM_MAX_POINTS   = 80    -- safety cap; MAX_DURATION should bound this earlier
local STREAM_MIN_POINTS   = 2     -- below this, fall back to a single discrete stamp

local BODY_MATERIAL_NAMES = {
  "METAL", "PLASTIC", "GLASS",
}
local SURFACE_MATERIAL_NAMES = {
  "ASPHALT", "ASPHALT_WET", "ASPHALT_PREPPED", "SLIPPERY", "ROCK",
  "METAL", "COBBLESTONE", "RUMBLE_STRIP", "GRAVEL",
  -- Anything you might smash into on a typical map:
  "CONCRETE", "WOOD", "PLASTIC", "RUBBER",
  -- Off-road:
  "DIRT", "DIRT_DUSTY", "GRASS", "MUD", "SAND", "SAND_DENSE",
  "ICE", "SNOW",
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
  for id, mat in pairs(materials) do
    if type(mat) == "table" and mat.name then
      nameById[id] = mat.name
    end
  end

  bodyMatSet = {}
  for _, name in ipairs(BODY_MATERIAL_NAMES) do
    local id = particles.getMaterialIDByName(materials, name)
    if id then bodyMatSet[id] = name end
  end

  surfaceMatSet = {}
  for _, name in ipairs(SURFACE_MATERIAL_NAMES) do
    local id = particles.getMaterialIDByName(materials, name)
    if id then surfaceMatSet[id] = name end
  end

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
-- 1 point:  fall back to a single discrete stamp via stampAt — the brushStroke
--           layer needs >= 2 dataPoints to interpolate.
-- 2+:       serialize as a Lua table literal of {x,y,z,nx,ny,nz} entries and
--           queue a single scratches_paint.stampStream(points) call.
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
  local parts = {}
  for i, p in ipairs(s.points) do
    parts[i] = string.format("{%.4f,%.4f,%.4f,%.4f,%.4f,%.4f}",
      p.x, p.y, p.z, p.nx, p.ny, p.nz)
  end

  stats.streamsFlushed    = stats.streamsFlushed + 1
  stats.streamPointsTotal = stats.streamPointsTotal + n

  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.stampStream then " ..
    "  pcall(scratches_paint.stampStream, {%s}) " ..
    "end",
    table.concat(parts, ",")))
end

-- ---- the filter ----
local function onScrapeContact(id1, pos, normal, nodeVel, perpVel, slipVec, slipVel,
                                slipForce, normalForce, depth, mat1, mat2)
  if not enabled then return end
  stats.totalCalls = stats.totalCalls + 1

  if not buildSets() then return end

  -- node lookup; reject if missing or a wheel
  local node = v.data.nodes and v.data.nodes[id1]
  if not node then stats.rejNoNode = stats.rejNoNode + 1; return end
  if node.wheelID then stats.rejWheel = stats.rejWheel + 1; return end

  -- body material
  local bodyName = bodyMatSet[node.nodeMaterial]
  if not bodyName then stats.rejBodyMat = stats.rejBodyMat + 1; return end

  -- part deny-list (mechanical / non-paintable parts). Strings.find with the
  -- 4th arg `true` does plain (non-pattern) substring search.
  local part = node.partOrigin or node.partPath or ""
  local partLower = part:lower()
  for _, pat in ipairs(EXCLUDE_PART_PATTERNS) do
    if partLower:find(pat, 1, true) then
      stats.rejPartExcluded = stats.rejPartExcluded + 1
      return
    end
  end

  -- surface material
  local surfaceName = surfaceMatSet[mat2]
  if not surfaceName then stats.rejSurfaceMat = stats.rejSurfaceMat + 1; return end

  -- magnitude
  local sliding   = slipVel >= SLIP_THRESHOLD
  local impacting = perpVel >= PERP_THRESHOLD
  -- Impact gate is force-only. Hard slides routinely spike normalForce
  -- past the threshold; rather than try to suppress those (the velocity-
  -- discriminator approach we tried earlier dropped real impacts during
  -- slides too), we let both branches fire when both conditions hold and
  -- accept the layered density as visual richness.
  local impactHit = normalForce >= IMPACT_FORCE_THRESHOLD
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

  if not logCandidates then return end

  local shouldLog = verbose
  if not shouldLog then
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
  if paintEnabled and obj and obj.queueGameEngineLua then
    local now = obj:getSimTime() or 0

    if impactHit then
      local lastImpact = nodeImpactLast[id1] or 0
      if now - lastImpact >= IMPACT_COOLDOWN then
        nodeImpactLast[id1] = now
        stats.impactEvents = stats.impactEvents + 1
        -- (G) Batch with other impacts/fallbacks; updateGFX flushes once per frame.
        -- (I) Pass normalForce so the GE synth camera can adapt distance to
        -- impact severity — heavy hits deform panels enough that a close
        -- camera plunges into the dent instead of grazing the outer edge.
        pendingDetectEvents[#pendingDetectEvents + 1] = {
          pos.x, pos.y, pos.z, normal.x, normal.y, normal.z, "i", normalForce,
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
      table.insert(stream.points, {
        x = pos.x, y = pos.y, z = pos.z,
        nx = normal.x, ny = normal.y, nz = normal.z,
        f  = normalForce,  -- (I) force per sample; the highest one drives the
                           --     fallback's synth-camera distance if the
                           --     stream ends up <STREAM_MIN_POINTS.
      })

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

-- (G) Flush the per-frame impact+fallback batch as ONE queueGameEngineLua
-- call. Empty case is the common one (cheap early-out). Builds a Lua table-
-- literal payload that scratches_paint.stampBatch unpacks on the GE side.
local function flushDetectEvents()
  local n = #pendingDetectEvents
  if n == 0 then return end
  if not (paintEnabled and obj and obj.queueGameEngineLua) then
    pendingDetectEvents = {}
    return
  end
  local parts = {}
  for i = 1, n do
    local e = pendingDetectEvents[i]
    parts[i] = string.format("{%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%q,%.0f}",
      e[1], e[2], e[3], e[4], e[5], e[6], e[7], e[8] or 0)
  end
  pendingDetectEvents = {}
  obj:queueGameEngineLua(string.format(
    "if scratches_paint and scratches_paint.stampBatch then " ..
    "  pcall(scratches_paint.stampBatch, {%s}) " ..
    "end",
    table.concat(parts, ",")))
end

-- (K) Periodic stats push to GE so the IMGUI debug panel can read VLUA-side
-- counts and current threshold values without needing a query mechanism.
-- Pushed via queueGameEngineLua; cheap (one Lua compile per ~0.25s).
local lastStatsPush     = 0
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
local function updateGFX(dt)
  if not (obj and obj.getSimTime) then return end
  flushDetectEvents()
  local now = obj:getSimTime() or 0
  -- (K) Throttled stats push to drive the GE-side IMGUI panel.
  if (now - lastStatsPush) >= STATS_PUSH_PERIOD then
    pushStatsToGE(now)
    pushLogsToGE()
    lastStatsPush = now
  end
  if next(nodeStreams) == nil then return end
  for nid, s in pairs(nodeStreams) do
    if (now - s.lastTime) >= STREAM_IDLE_TIMEOUT then
      flushStream(nid)
    end
  end
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
    onScrapeContact(...)
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
    rejBelowThresh = 0, rejNormalForce = 0,
  }
  table.clear(nodeEventCount)
  table.clear(nodeEventLast)
  log('I', logTag, "stats reset")
end

M.setEnabled = function(b)
  enabled = b and true or false
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
  -- vehicle reset (Ctrl+R)
  M.resetStats()
  table.clear(nodePaintLast)
  table.clear(nodeImpactLast)
  table.clear(nodeStreams)
  pendingDetectEvents = {}
  bootstrapPainter()
  -- Wipe baked decals on the GE side so the reset cleans up cosmetics too.
  -- pcall-guarded on GE because scratches_paint may not be loaded yet on a
  -- very early reset (just after vehicle spawn, before bootstrap completes).
  if obj and obj.queueGameEngineLua then
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
