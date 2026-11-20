-- Paint left behind on the ground. A panel scraping along the road leaves a
-- streak of the car's own paint where it scraped; a wheel dragged on its side
-- leaves a dark rubber / bare-metal mark; a hard hit on the ground leaves a
-- scatter of chips.
--
-- Marks are world-space records in a bounded ring buffer (oldest go first).
-- They are drawn with Engine.Render.DynamicDecalMgr.addDecals, the ground
-- decal batcher the game uses for route arrows and mission markers. That API
-- is immediate-mode: the game re-submits its pool every frame, so update()
-- re-submits the marks near the camera from a reused pool (no per-frame
-- allocation). Nothing is created in the scene, so there is nothing to clean
-- up beyond forgetting the records.
--
-- Every engine call is nil-checked or pcall'd; a missing API switches the
-- drawing off and never reaches the painter.
local M = {}

local MAX_MARKS    = 400     -- ring size
local LIFE         = 240     -- seconds a mark stays
local FADE         = 25      -- it fades out over its last seconds
local DRAW_DIST    = 150     -- metres from the camera
local SEG_MIN      = 0.25    -- one decal per 0.25-0.40 m of scrape
local SEG_MAX      = 0.40
local MIN_STEP     = 0.08    -- a stream shorter than this laid nothing
local UP_NORMAL    = 0.6     -- |nz| above this = ground, below = wall
local DEPTH        = 0.5     -- decal projection depth (m)
local MAX_PER_CALL = 24      -- marks one stream may lay
local WEAR_PRIMER  = 5       -- metres of recent scraping before primer shows
local WEAR_METAL   = 14      -- ... before bare metal shows
local WEAR_COOL    = 1.5     -- metres of scrape memory forgotten per second
local IMPACT_MIN   = 2500    -- N; softer ground hits leave nothing

local TEX_DIR  = "art/scratches/ground/"
local STREAKS  = { TEX_DIR .. "streak_1.png", TEX_DIR .. "streak_2.png", TEX_DIR .. "streak_3.png" }
local RUBBER   = TEX_DIR .. "rubber_1.png"
local CHIPS    = TEX_DIR .. "chips_1.png"
local PRIMER   = { 0.56, 0.56, 0.54 }
local METAL    = { 0.30, 0.31, 0.33 }
local DEFAULT_PAINT = { 0.6, 0.6, 0.6 }

local enabled = true
local now     = 0
local marks   = {}   -- [1..MAX_MARKS] reused records; .born == nil means empty
local head    = 0    -- last slot written
local alive   = 0
local wearRun = 0    -- metres scraped recently (drives paint -> primer -> metal)
local stats   = { alive = 0, submitted = 0, dropped = 0, added = 0, culled = 0, drawErrors = 0 }

local pool       = {}   -- decal structs handed to the engine, reused
local backend           -- function(pool, n); nil = resolve from the engine
local backendFailed = false
local colorCtor         -- ColorF or a plain-table stand-in

local wheelTracks = {}  -- up to 4 {x,y,z,t}: where each dragged wheel last was
local scratch = { 0, 0, 0 }

-- Small deterministic generator: marks must not look stamped, but the module
-- should not disturb math.random for anything else.
local seed = 12345
local function rnd()
  seed = (seed * 1103515245 + 12345) % 2147483648
  return seed / 2147483648
end

local function finite(n) return type(n) == "number" and n == n and n > -1e9 and n < 1e9 end
local function clamp01(n) return n < 0 and 0 or (n > 1 and 1 or n) end

local function addMark(x, y, z, dx, dy, dz, len, width, r, g, b, a, tex)
  if not (finite(x) and finite(y) and finite(z)) then return false end
  local dl = math.sqrt(dx * dx + dy * dy + dz * dz)
  if not finite(dl) or dl < 1e-6 then dx, dy, dz, dl = 0, 1, 0, 1 end
  head = head % MAX_MARKS + 1
  local m = marks[head]
  if not m then m = {}; marks[head] = m end
  if m.born then stats.dropped = stats.dropped + 1 else alive = alive + 1 end
  m.x, m.y, m.z = x, y, z
  m.dx, m.dy, m.dz = dx / dl, dy / dl, dz / dl
  m.len, m.width = len, width
  m.r, m.g, m.b, m.a = r, g, b, a
  m.tex = tex
  m.born = now
  stats.added = stats.added + 1
  stats.alive = alive
  return true
end

-- Paint transfer is thinner and chalkier than the paint on the car: a little
-- desaturated, a little lighter. Result in the reused `scratch` triple.
local function transferTone(c)
  local r, g, b = c[1] or 0.6, c[2] or 0.6, c[3] or 0.6
  local luma = 0.299 * r + 0.587 * g + 0.114 * b
  r, g, b = r + (luma - r) * 0.25, g + (luma - g) * 0.25, b + (luma - b) * 0.25
  scratch[1] = clamp01(r + (1 - r) * 0.12)
  scratch[2] = clamp01(g + (1 - g) * 0.12)
  scratch[3] = clamp01(b + (1 - b) * 0.12)
  return scratch
end

-- 0 = paint, 1 = primer, 2 = bare metal, for the scraping done recently. The
-- boundaries are blurred per mark so the change is ragged, not a clean step.
local function wearTier()
  local w = wearRun * (0.75 + rnd() * 0.5)
  if w >= WEAR_METAL then return 2 end
  if w >= WEAR_PRIMER then return 1 end
  return 0
end

local function layStreak(ax, ay, az, bx, by, bz, colour, widthScale)
  local dx, dy, dz = bx - ax, by - ay, bz - az
  local len = math.sqrt(dx * dx + dy * dy + dz * dz)
  if len < 1e-4 then return false end
  local tier = wearTier()
  local tone, alpha = transferTone(colour), 0.42 + rnd() * 0.2
  if tier == 1 then tone, alpha = PRIMER, 0.38 + rnd() * 0.15
  elseif tier == 2 then tone, alpha = METAL, 0.45 + rnd() * 0.2 end
  -- Sideways jitter (perpendicular in the ground plane) and a varied width.
  local j = (rnd() - 0.5) * 0.03
  local px, py = -dy / len * j, dx / len * j
  local width = (0.06 + rnd() * 0.07) * (widthScale or 1)
  return addMark((ax + bx) * 0.5 + px, (ay + by) * 0.5 + py, (az + bz) * 0.5,
    dx, dy, dz, len * (1.2 + rnd() * 0.25), width,
    tone[1], tone[2], tone[3], alpha, STREAKS[1 + math.floor(rnd() * #STREAKS) % #STREAKS])
end

-- points: world-space {x,y,z,nx,ny,nz} along one slide. colour: {r,g,b} paint.
-- Returns the number of marks laid.
M.addStream = function(points, colour, widthScale)
  if not enabled or type(points) ~= "table" or #points < 2 then return 0 end
  colour = type(colour) == "table" and colour or DEFAULT_PAINT
  -- Ground, not a wall: the contact normal must be mostly vertical. Either
  -- sign counts, so the detector's normal convention cannot switch this off.
  local nzSum, n = 0, 0
  for i = 1, #points do
    local p = points[i]
    if type(p) ~= "table" or not (finite(p[1]) and finite(p[2]) and finite(p[3])) then return 0 end
    if finite(p[6]) then nzSum = nzSum + math.abs(p[6]); n = n + 1 end
  end
  if n == 0 or nzSum / n < UP_NORMAL then return 0 end

  local laid = 0
  local ax, ay, az = points[1][1], points[1][2], points[1][3]
  local seg = SEG_MIN + rnd() * (SEG_MAX - SEG_MIN)
  for i = 2, #points do
    local p = points[i]
    local dx, dy, dz = p[1] - ax, p[2] - ay, p[3] - az
    local d = math.sqrt(dx * dx + dy * dy + dz * dz)
    while d >= seg and laid < MAX_PER_CALL do
      local k = seg / d
      local bx, by, bz = ax + dx * k, ay + dy * k, az + dz * k
      if layStreak(ax, ay, az, bx, by, bz, colour, widthScale) then laid = laid + 1 end
      wearRun = wearRun + seg
      ax, ay, az = bx, by, bz
      dx, dy, dz = p[1] - ax, p[2] - ay, p[3] - az
      d = math.sqrt(dx * dx + dy * dy + dz * dz)
      seg = SEG_MIN + rnd() * (SEG_MAX - SEG_MIN)
    end
    if laid >= MAX_PER_CALL then break end
  end
  -- The tail shorter than one segment still happened.
  local last = points[#points]
  local dx, dy, dz = last[1] - ax, last[2] - ay, last[3] - az
  local d = math.sqrt(dx * dx + dy * dy + dz * dz)
  if d >= MIN_STEP and laid < MAX_PER_CALL then
    if layStreak(ax, ay, az, last[1], last[2], last[3], colour, widthScale) then laid = laid + 1 end
    wearRun = wearRun + d
  end
  return laid
end

-- A hard hit on the ground: a small smear plus a scatter of chips.
M.addImpact = function(x, y, z, nx, ny, nz, force, colour)
  if not enabled or not finite(nz) or math.abs(nz) < UP_NORMAL then return 0 end
  if not finite(force) or force < IMPACT_MIN then return 0 end
  colour = type(colour) == "table" and colour or DEFAULT_PAINT
  local tone = transferTone(colour)
  local r, g, b = tone[1], tone[2], tone[3]
  local strength = clamp01((force - IMPACT_MIN) / 20000)
  local laid = 0
  local ang = rnd() * math.pi * 2
  local size = 0.16 + strength * 0.22
  if addMark(x, y, z, math.cos(ang), math.sin(ang), 0, size, size, r, g, b, 0.5 + strength * 0.25, CHIPS) then
    laid = laid + 1
  end
  for _ = 1, 1 + math.floor(strength * 2.99) do
    ang = rnd() * math.pi * 2
    local off = 0.03 + rnd() * 0.08
    if addMark(x + math.cos(ang) * off, y + math.sin(ang) * off, z, math.cos(ang), math.sin(ang), 0,
      0.07 + rnd() * 0.09, 0.03 + rnd() * 0.03, r, g, b, 0.4 + rnd() * 0.2, STREAKS[1 + math.floor(rnd() * #STREAKS) % #STREAKS]) then
      laid = laid + 1
    end
  end
  return laid
end

local function readXYZ(v) return v.x, v.y, v.z end
local function readPaint(veh) local c = veh.color; return c.x, c.y, c.z end
local function readVehiclePos() local p = getPlayerVehicle(0):getPosition(); return p.x, p.y, p.z end

-- x,y,z of a vec3 or a {x,y,z} / {[1],[2],[3]} table; nothing if it is neither.
local function xyz(v)
  local tv = type(v)
  if tv == "table" and v.x == nil then
    if finite(v[1]) and finite(v[2]) and finite(v[3]) then return v[1], v[2], v[3] end
    return nil
  end
  if tv == "table" or tv == "cdata" or tv == "userdata" then
    local ok, x, y, z = pcall(readXYZ, v)
    if ok and finite(x) and finite(y) and finite(z) then return x, y, z end
  end
end

-- A wheel dragged on its side (rim / sidewall on the road). worldPos and
-- worldNormal are vec3 or {x,y,z}; slipSpeed in m/s. Call it as often as the
-- contact is reported: marks are laid by distance travelled, not per call.
M.addWheelScrape = function(worldPos, worldNormal, slipSpeed)
  if not enabled then return 0 end
  local x, y, z = xyz(worldPos)
  if not x then return 0 end
  local _, _, nz = xyz(worldNormal)
  if nz and math.abs(nz) < UP_NORMAL then return 0 end
  slipSpeed = finite(slipSpeed) and math.abs(slipSpeed) or 3

  -- Which dragged wheel is this? The nearest recent track within a metre.
  local track, stale
  for i = 1, 4 do
    local t = wheelTracks[i]
    if not t then t = { t = -1e9 }; wheelTracks[i] = t end
    if now - t.t < 0.75 then
      local dx, dy, dz = x - t.x, y - t.y, z - t.z
      local d2 = dx * dx + dy * dy + dz * dz
      -- Reach grows with how far the wheel can have slid since its last
      -- report, so a fast drag reported in batches still joins up.
      local reach = 1 + slipSpeed * (now - t.t) * 1.5
      if d2 < reach * reach and (not track or d2 < track.d2) then track = t; t.d2 = d2 end
    end
    if not stale or t.t < stale.t then stale = t end
  end
  if not track then
    stale.x, stale.y, stale.z, stale.t = x, y, z, now
    return 0
  end
  local d = math.sqrt(track.d2)
  if d < 0.18 then track.t = now; return 0 end
  local hard = clamp01(slipSpeed / 12)
  local r, g, b, a, tex = 0.04, 0.04, 0.045, 0.3 + hard * 0.4, RUBBER
  local width = 0.05 + rnd() * 0.04
  -- A rim grinding fast enough cuts a bright line of metal now and then.
  if hard > 0.6 and rnd() < 0.3 then
    r, g, b, a, tex = 0.5, 0.5, 0.52, 0.4, STREAKS[1 + math.floor(rnd() * #STREAKS) % #STREAKS]
    width = 0.025 + rnd() * 0.02
  end
  local ok = addMark((x + track.x) * 0.5, (y + track.y) * 0.5, (z + track.z) * 0.5,
    x - track.x, y - track.y, z - track.z, d * 1.25, width, r, g, b, a, tex)
  track.x, track.y, track.z, track.t = x, y, z, now
  return ok and 1 or 0
end

-- The car's paint as {r,g,b}. veh.color is a Point4F (x,y,z = rgb).
M.vehicleColour = function(veh)
  local ok, r, g, b = pcall(readPaint, veh)
  if ok and finite(r) and finite(g) and finite(b) then
    return { clamp01(r), clamp01(g), clamp01(b) }
  end
  return DEFAULT_PAINT
end

-- One call for the painter's ingest: world-space events and slide streams,
-- before they are converted to the car's frame.
M.ingestWorld = function(veh, events, streams)
  if not enabled then return 0 end
  local colour
  local laid = 0
  if type(streams) == "table" then
    -- One batch is many nodes of the same panel scraping side by side. The
    -- wear memory is metres the CAR scraped, so it advances by the longest
    -- stream of the batch, not the sum (the sum reached bare metal within a
    -- few frames and the car's own colour never showed).
    local base, longest = wearRun, 0
    for i = 1, #streams do
      colour = colour or M.vehicleColour(veh)
      wearRun = base
      laid = laid + M.addStream(streams[i], colour)
      if wearRun - base > longest then longest = wearRun - base end
    end
    wearRun = base + longest
  end
  if type(events) == "table" then
    for i = 1, #events do
      local e = events[i]
      if type(e) == "table" and e[7] == "i" and finite(e[6]) and math.abs(e[6]) >= UP_NORMAL
        and finite(e[8]) and e[8] >= IMPACT_MIN then
        colour = colour or M.vehicleColour(veh)
        laid = laid + M.addImpact(e[1], e[2], e[3], e[4], e[5], e[6], e[8], colour)
      end
    end
  end
  return laid
end

local function resolveBackend()
  if backend then return backend end
  if backendFailed then return nil end
  local ok, fn = pcall(function() return _G.Engine.Render.DynamicDecalMgr.addDecals end)
  local ctor = _G.ColorF
  if not ok or not fn or not ctor or not vec3 then backendFailed = true; return nil end
  colorCtor = ctor
  backend = fn
  return backend
end

local function poolEntry(i)
  local d = pool[i]
  if not d then
    local ctor = colorCtor or function(r, g, b, a) return { r = r, g = g, b = b, a = a } end
    d = { texture = STREAKS[1], position = vec3(0, 0, 0), forwardVec = vec3(0, 1, 0),
          color = ctor(1, 1, 1, 1), scale = vec3(1, 1, DEPTH),
          fadeStart = DRAW_DIST * 0.8, fadeEnd = DRAW_DIST }
    pool[i] = d
  end
  return d
end

local function cameraXYZ()
  local cam = _G.core_camera
  if cam and cam.getPosition then
    local ok, p = pcall(cam.getPosition)
    if ok and p then local x, y, z = xyz(p); if x then return x, y, z end end
  end
  local ok, x, y, z = pcall(readVehiclePos)
  if ok and finite(x) then return x, y, z end
end

-- Once a frame: age the marks and re-submit the ones near the camera.
M.update = function(dt)
  stats.submitted = 0
  stats.culled = 0
  if not enabled then return 0 end
  dt = finite(dt) and dt > 0 and dt or 0
  now = now + dt
  wearRun = math.max(0, wearRun - WEAR_COOL * dt)
  if alive == 0 then return 0 end
  local draw = resolveBackend()
  local cx, cy, cz
  if draw then cx, cy, cz = cameraXYZ() end
  local n, far2 = 0, DRAW_DIST * DRAW_DIST
  for i = 1, MAX_MARKS do
    local m = marks[i]
    if m and m.born then
      local age = now - m.born
      if age >= LIFE then
        m.born = nil; alive = alive - 1
      elseif draw then
        local dx, dy, dz = m.x - (cx or m.x), m.y - (cy or m.y), m.z - (cz or m.z)
        if dx * dx + dy * dy + dz * dz <= far2 then
          n = n + 1
          local d = poolEntry(n)
          local fade = age > LIFE - FADE and (LIFE - age) / FADE or 1
          d.texture = m.tex
          d.position.x, d.position.y, d.position.z = m.x, m.y, m.z + 0.05
          d.forwardVec.x, d.forwardVec.y, d.forwardVec.z = m.dx, m.dy, m.dz
          d.color.r, d.color.g, d.color.b, d.color.a = m.r, m.g, m.b, m.a * fade
          d.scale.x, d.scale.y, d.scale.z = m.width, m.len, DEPTH
        else
          stats.culled = stats.culled + 1
        end
      end
    end
  end
  stats.alive = alive
  if n > 0 and draw then
    local ok = pcall(draw, pool, n)
    if ok then
      stats.submitted = n
    else
      stats.drawErrors = stats.drawErrors + 1
      -- A decal manager that keeps throwing is not coming back this session.
      if stats.drawErrors >= 3 then backend = nil; backendFailed = true end
    end
  end
  return stats.submitted
end

-- Forget every mark (level change, extension unload). A vehicle reset does
-- NOT call this: the car is repaired, the road is not.
M.clear = function()
  for i = 1, MAX_MARKS do
    if marks[i] then marks[i].born = nil end
  end
  for i = 1, #wheelTracks do wheelTracks[i].t = -1e9 end
  alive, head, wearRun = 0, 0, 0
  stats.alive, stats.submitted, stats.culled = 0, 0, 0
end

M.setEnabled = function(on)
  enabled = on and true or false
  if not enabled then M.clear() end
end
M.isEnabled = function() return enabled end

M.getStats = function()
  return { enabled = enabled, alive = alive, submitted = stats.submitted, dropped = stats.dropped,
           added = stats.added, culled = stats.culled, drawErrors = stats.drawErrors,
           capacity = MAX_MARKS, wearRun = wearRun, drawable = not backendFailed }
end

-- Test seam: draw through `fn(pool, n)` instead of the engine (nil restores
-- engine lookup). Read-only view of the mark records for the harness.
M._setBackend = function(fn) backend = fn; backendFailed = false; stats.drawErrors = 0 end
M._marks = function() return marks end
M._limits = { max = MAX_MARKS, life = LIFE, fade = FADE, drawDist = DRAW_DIST }

return M
