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
local paintCooldown = 0.05   -- seconds between paints per node (rate-limit a sliding node)

-- per-node counters
local nodeEventCount = {}    -- nid -> total candidate events seen
local nodeEventLast  = {}    -- nid -> count at time of last log
local nodePaintLast  = {}    -- nid -> simTime of last queued paint

-- aggregate stats since last dumpStats / since load
local stats = {
  totalCalls       = 0,  -- onNodeCollision calls reaching us
  filteredCalls    = 0,  -- passed all filters
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
local SLIP_THRESHOLD     = 2.5    -- m/s, sliding scrape
local PERP_THRESHOLD     = 2.5    -- m/s, impact-style penetration speed
local MIN_NORMAL_FORCE   = 50     -- N, reject grazing contacts

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
  if not (sliding or impacting) then stats.rejBelowThresh = stats.rejBelowThresh + 1; return end
  if normalForce < MIN_NORMAL_FORCE then stats.rejNormalForce = stats.rejNormalForce + 1; return end

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
    local kind = (sliding and impacting) and "SLIDE+HIT" or (sliding and "SLIDE" or "HIT")
    local part = node.partOrigin or node.partPath or "?"
    log('I', logTag, string.format(
      "%s n=%d (#%d) part=%s body=%s surf=%s slipVel=%.2f perpVel=%.2f normF=%.0f depth=%.4f pos=(%.2f,%.2f,%.2f)",
      kind, id1, n, part, bodyName, surfaceName,
      slipVel, perpVel, normalForce, depth, pos.x, pos.y, pos.z))
  end

  -- Paint coupling: queue a GE-side stamp at the impact point.
  -- Per-node cooldown so a sliding contact doesn't fire 2000 stamps/sec.
  -- Fire-and-forget: we don't observe the result; failures will surface as
  -- silent missing decals (paint.lua logs its own diagnostics on stampAt).
  if paintEnabled and obj and obj.queueGameEngineLua then
    local now = obj:getSimTime() or 0
    local last = nodePaintLast[id1] or 0
    if now - last >= paintCooldown then
      nodePaintLast[id1] = now
      -- Guard against scratches_paint being nil (e.g. mid-Ctrl+L when GE is
      -- between unload and reload). The pcall handles any other transient
      -- error inside stampAt without taking down the queued chain.
      obj:queueGameEngineLua(string.format(
        "if scratches_paint and scratches_paint.stampAt then " ..
        "  pcall(scratches_paint.stampAt, vec3(%.4f,%.4f,%.4f), vec3(%.4f,%.4f,%.4f)) " ..
        "end",
        pos.x, pos.y, pos.z, normal.x, normal.y, normal.z))
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

M.resetStats = function()
  stats = {
    totalCalls = 0, filteredCalls = 0,
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
  log('I', logTag, "loaded. probes: scratches_detect.{dumpStats,dumpMaterials,dumpNode,setLog,setVerbose,setEnabled,setThresholds,setPaintEnabled,setPaintCooldown,resetStats}")
  return true
end

local function onExtensionUnloaded()
  uninstall()
end

local function onReset()
  -- vehicle reset (Ctrl+R)
  M.resetStats()
  table.clear(nodePaintLast)
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

return M
