-- scratches_mod / detect.lua
-- Per-vehicle (VLUA) scrape & impact detector. Wraps the global onNodeCollision
-- callback, filters for body-vs-hard-surface contacts, and logs candidate
-- events to the console. Phase 1: log only, no painter calls.

local M = {}

local logTag = "scratches"

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
local paintCooldown = 0.015  -- seconds between paints per node (~66 samples/sec/node)

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

-- (G) Per-render-frame batch of impact / slide-fallback / deformation events.
-- updateGFX packages all of these into one queueGameEngineLua call as
-- scratches_paint.stampBatch({...}). Each entry is {x,y,z,nx,ny,nz,kind,sev}
-- where kind is:
--   "i" — collision impact (world coords; sev = normalForce in N)
--   "s" — single-point slide fallback (world coords; sev = normalForce in N)
--   "d" — deformation event (vehicle-local coords; sev = magnitude in m)
-- The GE side dispatches by kind; (I) scales synth-camera distance by sev.
local pendingDetectEvents = {}

-- (J) Deformation-driven stamp source. Per-frame round-robin scan of body
-- skin nodes; when a node's distance from rest position crosses a tier, emit
-- a stamp at its current (deformed) location. Catches the case the user
-- raised: outer skin pushed in by an internal frame node that itself was
-- deny-listed (skidplate/exhaust/etc) — collision detection misses that, but
-- the visible skin-node movement is real.
local bodySkinNodes      = nil   -- list of {nid, rx, ry, rz} body-skin rest positions
local nodeDeformTier     = {}    -- nid -> highest tier already fired (0..#DEFORM_TIERS)
local deformScanCursor   = 1     -- round-robin pointer into bodySkinNodes
local DEFORM_TIERS       = {0.04, 0.10, 0.20}  -- meters; 4cm/10cm/20cm progression
local DEFORM_SCAN_PER_FRAME = 12 -- nodes scanned per render frame
-- Settle delay before scanning starts. Right after spawn / Ctrl+R the JBeam
-- nodes haven't equilibrated yet — getNodePosition returns transient poses
-- that differ from the eventual rest by tens of cm. Capturing a baseline
-- there fires phantom tier-2/3 events as the vehicle settles into its real
-- pose. 1.5s is comfortably past suspension settling for any normal car.
local DEFORM_CALIBRATION_DELAY = 1.5  -- seconds
local deformAnchorTime         = nil  -- simTime when settle window started
local deformLogsRemaining      = 5    -- one-time diagnostic on first calibrations
-- Gate deformation event emission on recent collision activity. Body flex
-- under cornering / acceleration legitimately moves skin nodes 3-5cm in
-- vehicle-local frame; without this gate, a hard slide turn fires tier 1
-- on every flexing panel even with no actual damage.
--
-- Two layers:
--   (a) time gate: lastFilteredEventTime — anything outside the window
--       short-circuits the whole scan emit.
--   (b) proximity gate: recentCollisionNodes — even within the time window,
--       only nodes near a recent collision can emit. Stops the case where
--       hitting one side of the car causes opposite-side body strain to
--       paint as damage on a panel that never touched anything.
local lastFilteredEventTime    = -1e9
local DEFORM_COLLISION_WINDOW  = 3.0  -- seconds
-- (M) 0.4m is panel-sized — enough that the actual struck panel's deform
-- events fire, but small enough that proximity doesn't chain via chassis-
-- internal contact nodes (body_sedan spine, transmission tunnel) to door /
-- quarterpanel skin nodes that never took a hit. Was 1.0m, which let a
-- frontal-bumper smash propagate visible deform stamps to the rear doors.
local DEFORM_PROX_RADIUS       = 0.4
local recentCollisionNodes     = {}   -- nid -> {rx, ry, rz, time} (vehicle-local rest pos cached for cheap proximity test)

-- aggregate stats since last dumpStats / since load
local stats = {
  totalCalls       = 0,  -- onNodeCollision calls reaching us
  filteredCalls    = 0,  -- passed all filters
  impactEvents     = 0,  -- impact-branch stamps fired (subset of filteredCalls)
  deformEvents     = 0,  -- (J) deformation-tier crossings emitted as stamps
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
local SLIP_THRESHOLD     = 1.5    -- m/s, sliding scrape (was 2.5)
local PERP_THRESHOLD     = 2.0    -- m/s, impact-style penetration speed (was 2.5)
local MIN_NORMAL_FORCE   = 30     -- N, reject grazing contacts (was 50)

-- ---- impact-branch params ----
-- Head-on smashes don't trip the slide/perpVel branches: BeamNG's solver
-- cushions perpendicular velocity to ~0 within one tick, so a hard front-end
-- hit produces slipVel≈0 and perpVel≈0 but normalForce in the kN range
-- (observed max ≈95 kN). This branch fires on raw normalForce so impacts
-- register at the moment of contact, not just during the followup grind.
-- 5 kN catches deformation-noise spikes during slides but those layer with
-- the slide stream rather than replacing it (impact and slide both fire
-- when both conditions hold), so the over-firing is desirable visual density.
local IMPACT_FORCE_THRESHOLD = 3000   -- N (was 5000; lighter impacts now register)
local IMPACT_COOLDOWN        = 0.25   -- seconds, per-node (was 0.4; F+G+H made
                                       -- per-stamp cost low enough that a node
                                       -- re-impacting during a roll can fire
                                       -- ~4x more often than the original 1.0s)

-- ---- continuous-slide stream params ----
-- Slide branch collects per-node samples while contact is active and flushes
-- as a single brushStroke layer when the node has been idle. The brushStroke
-- layer interpolates between samples for a continuous swept stroke instead
-- of stacking discrete stamps at body-relative points.
local STREAM_IDLE_TIMEOUT = 0.10  -- s; gap before we treat the slide as ended
local STREAM_MAX_DURATION = 0.45  -- s; force-flush so one camera covers the points
local STREAM_MAX_POINTS   = 30    -- safety cap; MAX_DURATION should bound this earlier
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

-- (M) Chassis-internal part patterns. These nodes pass the EXCLUDE_PART_PATTERNS
-- filter (they're not mechanical) but their JBeam REST positions are inside
-- the body — frame rails, transmission tunnel, B-pillar internals. They
-- legitimately fire onNodeCollision during major impacts via chassis
-- self-collision (interior nodes touching each other as the body crumples),
-- but using them to drive deform-gate proximity bleeds the gate to outer-skin
-- panels far from the actual external impact point. A frontal-bumper hit on
-- a 2m-long Pigeon ends up "near" every door panel via the spine.
--
-- Used ONLY for the deform-gate population. Slide and impact stamping on
-- these nodes still fires as before — chassis bottom-out scrape marks remain.
local DEFORM_GATE_INTERNAL_PATTERNS = {
  "body_sedan", "body_3w", "body_lcv", "body_truck",
  "body_pickup", "body_van", "body_coupe", "body_wagon",
  "frame", "chassis", "subframe", "unibody",
  -- Underbody panels: technically outer skin, but located right under the
  -- sideskirt on the ETK800 (Z≈-0.05) — within 0.4m proximity of door
  -- bottom skin nodes (Z≈0.3-0.4). Off-road / sand grinding fills these
  -- with filtered contacts that chain to door panels.
  "undertray", "splitter", "diffuser",
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
  -- (J/M) Open the deformation gate window AND record the contact node's
  -- rest position so the proximity filter can match nearby skin nodes.
  -- Keyed by nid so re-impacts on the same node just refresh the timer
  -- (table stays small even during a long roll).
  --
  -- (M) Force-gated: only impactHit-level contacts (>= IMPACT_FORCE_THRESHOLD)
  -- open the deform window. Pure slides and gentle ground contacts (sand
  -- grinding, curb taps, undertray scuff) don't represent damage events;
  -- letting them populate recentCollisionNodes had a 3-second residual
  -- effect after every off-road excursion that re-opened the gate for
  -- nodes near the underbody, chaining proximity to body skin panels.
  local _now = obj and obj.getSimTime and obj:getSimTime() or 0
  if impactHit then
    lastFilteredEventTime = _now
    -- (M) Only outer-skin parts populate the deform gate. Chassis-internal
    -- nodes (body_sedan/body_3w/frame/...) report contacts during major
    -- impacts via self-collision but their rest positions are inside the body
    -- and would chain proximity to far-side panels.
    local isInternal = false
    for _, ipat in ipairs(DEFORM_GATE_INTERNAL_PATTERNS) do
      if partLower:find(ipat, 1, true) then isInternal = true; break end
    end
    if not isInternal and node.pos then
      recentCollisionNodes[id1] = {
        rx = node.pos.x, ry = node.pos.y, rz = node.pos.z,
        time = _now,
      }
    end
  end
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

-- (J) Enumerate body skin nodes once. Same filters as onScrapeContact uses
-- for the impact branch: must have a body material (METAL/PLASTIC/GLASS),
-- must not be a wheel, must not match an EXCLUDE_PART_PATTERNS substring.
-- Caches the result; returns nil while v.data isn't yet ready.
local function buildBodySkinNodes()
  if bodySkinNodes then return bodySkinNodes end
  if not (v and v.data and v.data.nodes) then return nil end
  if not buildSets() then return nil end

  bodySkinNodes = {}
  for nid, node in pairs(v.data.nodes) do
    if not node.wheelID
       and node.nodeMaterial and bodyMatSet[node.nodeMaterial]
       and node.pos then
      local part = (node.partOrigin or node.partPath or ""):lower()
      local excluded = false
      for _, pat in ipairs(EXCLUDE_PART_PATTERNS) do
        if part:find(pat, 1, true) then excluded = true; break end
      end
      if not excluded then
        bodySkinNodes[#bodySkinNodes + 1] = {
          nid = nid,
          rx  = node.pos.x, ry = node.pos.y, rz = node.pos.z,
        }
      end
    end
  end
  log('I', logTag, "deform scan: registered " .. #bodySkinNodes .. " body skin nodes")
  return bodySkinNodes
end

-- (J) Per-frame round-robin deformation scan.
--
-- Diagnostic confirmed: obj:getNodePosition(nid) returns vehicle-local
-- coordinates already (close to v.data.nodes[nid].pos for an undeformed
-- node). No world->local conversion needed — direct comparison to a
-- captured baseline gives true deformation magnitude.
--
-- Pipeline:
--   1. Skip until DEFORM_CALIBRATION_DELAY has elapsed since spawn/reset
--      (physics need ~1.5s to settle into rest pose; capturing baseline
--      mid-settle fired phantom events).
--   2. First observation of each node captures pos as the rest baseline.
--      Subsequent observations measure |current - baseline|.
--   3. Tiers (4cm/10cm/20cm by default) fire one stamp each per node.
--   4. Sanity cap >1.5m skips any unforeseen garbage.
--
-- Diagnostic log on the first 5 calibrations prints jbeam_rest vs the
-- captured pos so we can confirm they're close (small offset is normal —
-- jbeam_rest is unsettled rest, pos is settled-under-gravity rest).
local function scanDeformations()
  if not (enabled and paintEnabled) then return end
  if not obj or not obj.getNodePosition or not obj.getSimTime then return end
  local nodes = buildBodySkinNodes()
  if not nodes or #nodes == 0 then return end

  local now = obj:getSimTime() or 0
  if not deformAnchorTime then deformAnchorTime = now end
  if now - deformAnchorTime < DEFORM_CALIBRATION_DELAY then return end

  -- (J) Collision gate: only emit events while we're within the recent-
  -- collision window. Outside the window we still scan and capture
  -- baselines (so the scan never falls behind), but tier crossings are
  -- silently consumed instead of producing stamps. This kills body-flex
  -- false positives during pure driving while still firing during real
  -- crashes (which always have nearby collision events).
  local timeGateOpen = (now - lastFilteredEventTime) <= DEFORM_COLLISION_WINDOW

  -- Prune stale entries from recentCollisionNodes once per slice (cheap
  -- amortized cost). After pruning, this table holds only nodes that took
  -- a contact event in the last DEFORM_COLLISION_WINDOW seconds.
  if timeGateOpen then
    for cid, c in pairs(recentCollisionNodes) do
      if (now - c.time) > DEFORM_COLLISION_WINDOW then
        recentCollisionNodes[cid] = nil
      end
    end
  else
    -- Time gate closed; nothing to do, table will get pruned next time it opens.
  end
  local proxR2 = DEFORM_PROX_RADIUS * DEFORM_PROX_RADIUS

  local n = #nodes
  local sliceSize = math.min(DEFORM_SCAN_PER_FRAME, n)
  for k = 1, sliceSize do
    local i = ((deformScanCursor - 1 + k - 1) % n) + 1
    local entry = nodes[i]
    local nid = entry.nid

    local pos = obj:getNodePosition(nid)
    if pos then
      -- Lazy baseline. First observation establishes rest; thereafter we
      -- measure deviation from THAT, not from JBeam's unsettled rest pos.
      if not entry.bx then
        entry.bx, entry.by, entry.bz = pos.x, pos.y, pos.z
        if deformLogsRemaining > 0 then
          log('I', logTag, string.format(
            "deform calibrate nid=%d  jbeam_rest=(%.3f,%.3f,%.3f)  captured_pos=(%.3f,%.3f,%.3f)  delta=(%.3f,%.3f,%.3f)",
            nid, entry.rx, entry.ry, entry.rz, pos.x, pos.y, pos.z,
            pos.x - entry.rx, pos.y - entry.ry, pos.z - entry.rz))
          deformLogsRemaining = deformLogsRemaining - 1
        end
      end

      local dx = pos.x - entry.bx
      local dy = pos.y - entry.by
      local dz = pos.z - entry.bz
      local mag = math.sqrt(dx*dx + dy*dy + dz*dz)

      if mag <= 1.5 then
        local newTier = 0
        for t = #DEFORM_TIERS, 1, -1 do
          if mag >= DEFORM_TIERS[t] then newTier = t; break end
        end

        local prevTier = nodeDeformTier[nid] or 0
        -- Proximity check: this skin node must be within DEFORM_PROX_RADIUS
        -- of at least one collision node from the recent window. JBeam rest
        -- positions (cnode.rx/ry/rz vs entry.rx/ry/rz) are both vehicle-local
        -- so the distance test is direct.
        local emitAllowed = false
        if timeGateOpen then
          for _, c in pairs(recentCollisionNodes) do
            local cdx = entry.rx - c.rx
            local cdy = entry.ry - c.ry
            local cdz = entry.rz - c.rz
            if (cdx*cdx + cdy*cdy + cdz*cdz) <= proxR2 then
              emitAllowed = true
              break
            end
          end
        end
        if newTier > prevTier and emitAllowed then
          local nx, ny, nz
          if mag > 1e-6 then
            nx, ny, nz = dx/mag, dy/mag, dz/mag
          else
            nx, ny, nz = 0, 0, 1
          end
          -- pos is vehicle-local; the GE side dispatches "d" through
          -- stampAtLocal which expects vehicle-local.
          pendingDetectEvents[#pendingDetectEvents + 1] = {
            pos.x, pos.y, pos.z, nx, ny, nz, "d", mag,
          }
          nodeDeformTier[nid] = newTier
          stats.deformEvents = stats.deformEvents + 1
        end
        -- Note: when emitAllowed is false, we DON'T mark prevTier consumed.
        -- The flex magnitude will return to ~0 after the maneuver ends,
        -- and a future real damage at this same magnitude will still fire.
      end
    end
  end

  deformScanCursor = deformScanCursor + sliceSize
  if deformScanCursor > n then deformScanCursor = 1 end
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
    "totalCalls=%d,filteredCalls=%d,impactEvents=%d,deformEvents=%d," ..
    "streamsFlushed=%d,slip=%.3f,perp=%.3f,minForce=%.0f," ..
    "impForce=%.0f,impCool=%.3f,paintCool=%.4f," ..
    "defT1=%.4f,defT2=%.4f,defT3=%.4f," ..
    "skinNodes=%d,maxNormalForce=%.0f}) " ..
    "end",
    stats.totalCalls, stats.filteredCalls, stats.impactEvents, stats.deformEvents,
    stats.streamsFlushed,
    SLIP_THRESHOLD, PERP_THRESHOLD, MIN_NORMAL_FORCE,
    IMPACT_FORCE_THRESHOLD, IMPACT_COOLDOWN, paintCooldown,
    DEFORM_TIERS[1], DEFORM_TIERS[2], DEFORM_TIERS[3],
    bodySkinNodes and #bodySkinNodes or 0, stats.maxNormalForce))
end

-- ---- per-frame: deform scan + idle-flush streams + flush event batch ----
-- (J) scanDeformations runs FIRST so its emissions ride out in the same
-- flushDetectEvents call as collision impacts and fallbacks.
-- Walks the stream table once per render frame; cheap because the table is
-- empty whenever no node is in slide contact. Any stream whose last sample
-- is older than STREAM_IDLE_TIMEOUT is flushed.
local function updateGFX(dt)
  if not (obj and obj.getSimTime) then return end
  scanDeformations()
  flushDetectEvents()
  local now = obj:getSimTime() or 0
  -- (K) Throttled stats push to drive the GE-side IMGUI panel.
  if (now - lastStatsPush) >= STATS_PUSH_PERIOD then
    pushStatsToGE(now)
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
  log('I', logTag, string.format("deformEvents  = %d  (tiers %.2fm/%.2fm/%.2fm, %d skin nodes, proxR=%.2fm, force-gated, outer-skin-only)",
    stats.deformEvents,
    DEFORM_TIERS[1] or 0, DEFORM_TIERS[2] or 0, DEFORM_TIERS[3] or 0,
    bodySkinNodes and #bodySkinNodes or 0,
    DEFORM_PROX_RADIUS))
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
  add(string.format("deformEvents  = %d  (tiers %.2f/%.2f/%.2fm, %d nodes, proxR=%.2fm, force-gated, outer-skin-only)",
    stats.deformEvents,
    DEFORM_TIERS[1] or 0, DEFORM_TIERS[2] or 0, DEFORM_TIERS[3] or 0,
    bodySkinNodes and #bodySkinNodes or 0, DEFORM_PROX_RADIUS))
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
    totalCalls = 0, filteredCalls = 0, impactEvents = 0, deformEvents = 0,
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

-- (J) Tune the deformation-tier thresholds. Pass any of t1/t2/t3 in meters;
-- nil leaves that tier unchanged. Lower values = more sensitive = more stamps.
M.setDeformTiers = function(t1, t2, t3)
  if t1 then DEFORM_TIERS[1] = math.max(0.005, tonumber(t1) or 0.04) end
  if t2 then DEFORM_TIERS[2] = math.max(0.01,  tonumber(t2) or 0.10) end
  if t3 then DEFORM_TIERS[3] = math.max(0.02,  tonumber(t3) or 0.20) end
  log('I', logTag, string.format("deform tiers: %.3fm / %.3fm / %.3fm",
    DEFORM_TIERS[1], DEFORM_TIERS[2], DEFORM_TIERS[3]))
  -- Reset the tier-fired memory so we re-evaluate every node against the new tiers.
  table.clear(nodeDeformTier)
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
  log('I', logTag, "loaded. probes: scratches_detect.{dumpStats,pushFullDumpToGE,dumpMaterials,dumpNode,setLog,setVerbose,setEnabled,setThresholds,setImpactParams,setDeformTiers,setPaintEnabled,setPaintCooldown,resetStats}")
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
  -- (J) Reset deformation state — fresh-spawn vehicle has no damage, so
  -- per-node tier history is wrong now. Also clear the per-node baselines
  -- so they recalibrate against the post-respawn pose on the next scan.
  -- Node IDs DON'T change on respawn, so keep bodySkinNodes itself.
  -- And re-anchor the calibration delay so the post-Ctrl+R settle window
  -- gets the same protection as a fresh spawn.
  if bodySkinNodes then
    for _, e in ipairs(bodySkinNodes) do
      e.bx, e.by, e.bz = nil, nil, nil
    end
  end
  table.clear(nodeDeformTier)
  table.clear(recentCollisionNodes)
  deformScanCursor       = 1
  deformAnchorTime       = nil
  deformLogsRemaining    = 5
  lastFilteredEventTime  = -1e9
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
