-- scratches_mod / patches.lua  (GELUA, pure logic)
-- Contact-patch aggregation. The detector reports every contacting node
-- several times a second; baking one decal per report cost a full-canvas pass
-- each (hundreds per crash) and drew a scatter of small unrelated marks.
--
-- Here contacts are folded into patches: a slide patch is an oriented box on
-- one panel that grows over the nodes scraping there, an impact patch is a
-- disc over nearby hits. A patch is painted as ONE decal sized to its extent,
-- and repainted only when it has been worn a tier deeper or has grown past
-- what was painted. `next` hands out at most one decal per interval, so the
-- painter bakes a bounded trickle no matter how violent the crash is.
--
-- No engine calls: positions, normals and directions are vehicle-local vec3s
-- supplied by the painter.
local M = {}

local SLIDE_MAX_LENGTH   = 0.95  -- m, extent of one patch along the slide
local SLIDE_MAX_WIDTH    = 0.30  -- m, extent across it
local SLIDE_JOIN_ALONG   = 0.34  -- m, gap along the slide that still joins a patch
local SLIDE_JOIN_ACROSS  = 0.15  -- m, gap across it
local SLIDE_JOIN_OFFSET  = 0.22  -- m, distance off the patch plane
local SLIDE_TIER_ENERGY  = { 1.2, 6.0 }  -- slid metres (summed over nodes) for tier 2 / 3
local SLIDE_GROW_ALONG   = 0.14  -- m of new extent that earns a repaint
local SLIDE_GROW_ACROSS  = 0.07
local SLIDE_RIPEN        = 0.22  -- s a new patch gathers contacts before its first decal
local SLIDE_IDLE         = 0.10  -- s without contact also makes it ripe
local SLIDE_REPAINT_GAP  = 0.45  -- s between decals on one patch
local SLIDE_MAX_EMITS    = 5

local IMPACT_JOIN_RADIUS = 0.17  -- m
local IMPACT_MAX_RADIUS  = 0.20
local IMPACT_TIER_ENERGY = { 0.7, 2.2 }
local IMPACT_RIPEN       = 0.12
local IMPACT_REPAINT_GAP = 0.40
local IMPACT_MAX_EMITS   = 3

local MAX_PATCHES        = 220

local function tierOf(energy, thresholds)
  if energy >= thresholds[2] then return 3 end
  if energy >= thresholds[1] then return 2 end
  return 1
end

local Agg = {}
Agg.__index = Agg

function M.new(opts)
  opts = opts or {}
  return setmetatable({
    interval = opts.interval or 0.07,  -- s between emitted decals
    slides = {}, impacts = {}, lastEmit = -math.huge, seq = 0,
    counts = { slideSamples = 0, impactSamples = 0, slidePatches = 0, impactPatches = 0,
               emitted = 0, evicted = 0 },
  }, Agg)
end

function Agg:clear()
  self.slides, self.impacts, self.lastEmit = {}, {}, -math.huge
end

local function evict(list, counts)
  if #list <= MAX_PATCHES then return end
  local oldest, at = math.huge, nil
  for i, p in ipairs(list) do
    if p.last < oldest then oldest, at = p.last, i end
  end
  table.remove(list, at)
  counts.evicted = counts.evicted + 1
end

-- One slide report: `pos` is where the body point is now, `dir` the slide
-- direction flattened onto the panel (unit), `dist` how far it was dragged.
function Agg:addSlide(pos, normal, dir, dist, now)
  self.counts.slideSamples = self.counts.slideSamples + 1
  local best, bestGap, bu, bv
  for _, p in ipairs(self.slides) do
    if p.normal:dot(normal) >= 0.7 and math.abs(p.dir:dot(dir)) >= 0.6 then
      local rel = pos - p.origin
      local u, v, w = rel:dot(p.dir), rel:dot(p.side), rel:dot(p.normal)
      local gu = math.max(0, p.umin - u, u - p.umax)
      local gv = math.max(0, p.vmin - v, v - p.vmax)
      if math.abs(w) <= SLIDE_JOIN_OFFSET and gu <= SLIDE_JOIN_ALONG and gv <= SLIDE_JOIN_ACROSS
          and math.max(p.umax, u) - math.min(p.umin, u) <= SLIDE_MAX_LENGTH
          and math.max(p.vmax, v) - math.min(p.vmin, v) <= SLIDE_MAX_WIDTH then
        local gap = gu + gv * 2
        if not bestGap or gap < bestGap then best, bestGap, bu, bv = p, gap, u, v end
      end
    end
  end
  if best then
    local p = best
    p.umin, p.umax = math.min(p.umin, bu), math.max(p.umax, bu)
    p.vmin, p.vmax = math.min(p.vmin, bv), math.max(p.vmax, bv)
    p.energy, p.samples, p.last = p.energy + dist, p.samples + 1, now
    return p
  end
  local side = normal:cross(dir)
  local slen = side:length()
  if slen < 1e-4 then return nil end
  self.seq = self.seq + 1
  local p = { kind = "slide", id = self.seq, origin = vec3(pos.x, pos.y, pos.z),
    normal = vec3(normal.x, normal.y, normal.z), dir = vec3(dir.x, dir.y, dir.z),
    side = side * (1 / slen), umin = 0, umax = 0, vmin = 0, vmax = 0,
    energy = dist, samples = 1, first = now, last = now, emits = 0, tier = 0 }
  self.slides[#self.slides + 1] = p
  self.counts.slidePatches = self.counts.slidePatches + 1
  evict(self.slides, self.counts)
  return p
end

-- One impact: `severity` 0..1 from the contact force; `slip` is the optional
-- vehicle-local slide velocity at the hit (m/s), which orients a glancing blow.
function Agg:addImpact(pos, normal, severity, slip, now)
  self.counts.impactSamples = self.counts.impactSamples + 1
  local best, bestD
  for _, p in ipairs(self.impacts) do
    if p.normal:dot(normal) >= 0.7 then
      local d = (pos - p.centre):length()
      if d <= IMPACT_JOIN_RADIUS and math.max(p.radius, d) <= IMPACT_MAX_RADIUS
          and (not bestD or d < bestD) then
        best, bestD = p, d
      end
    end
  end
  local gain = 0.18 + severity
  if best then
    local p = best
    p.radius = math.max(p.radius, bestD)
    p.energy, p.samples, p.last = p.energy + gain, p.samples + 1, now
    if slip then p.slip = p.slip + slip end
    return p
  end
  self.seq = self.seq + 1
  local p = { kind = "impact", id = self.seq, centre = vec3(pos.x, pos.y, pos.z),
    normal = vec3(normal.x, normal.y, normal.z), radius = 0, slip = slip and (slip * 1) or vec3(0, 0, 0),
    energy = gain, samples = 1, first = now, last = now, emits = 0, tier = 0 }
  self.impacts[#self.impacts + 1] = p
  self.counts.impactPatches = self.counts.impactPatches + 1
  evict(self.impacts, self.counts)
  return p
end

-- When (if ever) patch p next deserves a decal; nil = nothing to paint.
local function slideDue(p, now)
  if p.emits == 0 then
    if now - p.first >= SLIDE_RIPEN or now - p.last >= SLIDE_IDLE then return p.first end
    return nil
  end
  if p.emits >= SLIDE_MAX_EMITS or now - p.emitAt < SLIDE_REPAINT_GAP then return nil end
  local grew = (p.painted.umin - p.umin) + (p.umax - p.painted.umax) >= SLIDE_GROW_ALONG
            or (p.painted.vmin - p.vmin) + (p.vmax - p.painted.vmax) >= SLIDE_GROW_ACROSS
  if grew or tierOf(p.energy, SLIDE_TIER_ENERGY) > p.tier then return p.emitAt end
  return nil
end

local function impactDue(p, now)
  if p.emits == 0 then
    if now - p.first >= IMPACT_RIPEN then return p.first end
    return nil
  end
  if p.emits >= IMPACT_MAX_EMITS or now - p.emitAt < IMPACT_REPAINT_GAP then return nil end
  if tierOf(p.energy, IMPACT_TIER_ENERGY) > p.tier or p.radius >= p.paintedRadius + 0.06 then
    return p.emitAt
  end
  return nil
end

-- True while any patch still has a decal coming, whenever it becomes due.
function Agg:pending()
  for _, p in ipairs(self.slides) do if slideDue(p, math.huge) then return true end end
  for _, p in ipairs(self.impacts) do if impactDue(p, math.huge) then return true end end
  return false
end

-- Which brush family a patch would be painted with right now.
local function slideKey(p) return "slide" .. tierOf(p.energy, SLIDE_TIER_ENERGY) end
local function impactKey(p)
  local scored = p.slip:length() / p.samples >= 1.5
  return (scored and "score" or "chip") .. tierOf(p.energy, IMPACT_TIER_ENERGY)
end
M.SAME_BRUSH_WINDOW = 0.35  -- s a patch may jump the queue to reuse the loaded brush

-- The next decal to paint, or nil. At most one per `interval`; the patch that
-- has waited longest goes first, except that a patch needing the brush family
-- `hot` (the one the engine still has loaded) goes ahead of patches that have
-- waited up to SAME_BRUSH_WINDOW longer: a brush change costs a texture reload.
function Agg:next(now, hot)
  if now - self.lastEmit < self.interval then return nil end
  local pick, pickAt, same, sameAt
  local function consider(p, due, key)
    if not due then return end
    if not pickAt or due < pickAt then pick, pickAt = p, due end
    if hot and key(p) == hot and (not sameAt or due < sameAt) then same, sameAt = p, due end
  end
  for _, p in ipairs(self.slides) do consider(p, slideDue(p, now), slideKey) end
  for _, p in ipairs(self.impacts) do consider(p, impactDue(p, now), impactKey) end
  if not pick then return nil end
  if same and sameAt - pickAt <= M.SAME_BRUSH_WINDOW then pick = same end
  self.lastEmit = now
  self.counts.emitted = self.counts.emitted + 1
  local p = pick
  p.emits, p.emitAt = p.emits + 1, now
  if p.kind == "slide" then
    p.tier = tierOf(p.energy, SLIDE_TIER_ENERGY)
    p.painted = { umin = p.umin, umax = p.umax, vmin = p.vmin, vmax = p.vmax }
    local centre = p.origin + p.dir * ((p.umin + p.umax) * 0.5) + p.side * ((p.vmin + p.vmax) * 0.5)
    return { kind = "slide", id = p.id, pass = p.emits, tier = p.tier, energy = p.energy, key = "slide" .. p.tier,
      centre = centre, normal = p.normal, dir = p.dir, queuedAt = p.first,
      under = p.under, underPart = p.underPart,   -- painter tags (underside patch)
      length = math.min(1.35, (p.umax - p.umin) + 0.26 + 0.10 * p.tier),
      width  = math.min(0.44, (p.vmax - p.vmin) + 0.09 + 0.035 * p.tier) }
  end
  p.tier = tierOf(p.energy, IMPACT_TIER_ENERGY)
  p.paintedRadius = p.radius
  local slipSpeed = p.slip:length() / p.samples
  return { kind = "impact", id = p.id, pass = p.emits, tier = p.tier, energy = p.energy,
    key = (slipSpeed >= 1.5 and "score" or "chip") .. p.tier,
    centre = p.centre, normal = p.normal, queuedAt = p.first,
    under = p.under, underPart = p.underPart,
    dir = slipSpeed >= 1.5 and (p.slip * (1 / p.slip:length())) or nil,
    size = math.min(0.62, 2 * p.radius + 0.20 + 0.07 * p.tier + 0.05 * math.min(3, p.energy)) }
end

function Agg:stats()
  local out = {}
  for k, v in pairs(self.counts) do out[k] = v end
  out.slidesLive, out.impactsLive = #self.slides, #self.impacts
  return out
end

return M
