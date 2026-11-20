-- Wheel and tyre soiling: a material-level overlay, not a per-texel canvas.
--
-- Wheels and tyres are separate flexbody meshes with shared art and no
-- dynamic-texture UVs, so decals cannot land on them. Instead each vehicle gets
-- its own clone of every tyre/rim material it renders (bound through the same
-- construction-time flexbody material override bodyAdapter uses) with one
-- appended tiling dirt stage, and on rims a second abrasion stage. A single
-- quantised number per stage drives opacityFactor; the material is only
-- touched when a step changes. Source materials are never written.
local M = {}
local OWNER = "wheelAdapter-v1"
local STEPS = 10
local TEX = "/art/scratches/wheels/"
local MIN_APPLY_INTERVAL = 0.3
local skipFields = {name=true,mapTo=true,persistentId=true,parentGroup=true,
  internalName=true,class=true,className=true,superClass=true,hidden=true,
  locked=true,canSave=true,canSaveDynamicFields=true}
-- Per quarter-second soil sample: tyres foul fast, rims take a lighter dusting.
-- "under" is the undercarriage: suspension, skid plates, exhaust, running boards.
local GAIN = {mud={tyre=0.04,rim=0.014,under=0.03}, dirt={tyre=0.02,rim=0.007,under=0.012}, snow={tyre=0.035,rim=0.014,under=0.025}}
local DEFAULT_TINT = {mud={0.23,0.17,0.11}, dirt={0.45,0.38,0.29}, snow={0.92,0.94,0.97}}
local MAX_OPACITY = {tyre=0.95, rim=0.7, under=0.88}

local enabled = true
local state
local keysByVid, keysByModel = {}, {}
local prepared, skipped, clones = {}, {}, {}
local attached = nil
local applied = nil
local sinceApply = 1
-- Set by anything that can move a step; lets the per-frame sync return
-- without building the step table when nothing has changed.
local dirty = true

local function newState()
  return {tyre=0, rim=0, under=0, underScrape=0, scrape=0, tint={0.4,0.33,0.25}, tinted=false, samples=0,
    scrapes=0, perWheel={}, applies=0, tintResolves=0}
end
state = newState()

local function clamp01(n) return math.max(0, math.min(1, n)) end
local function quantise(n) return math.floor(clamp01(n) * STEPS + 0.5) end
M.quantise = quantise
M.STEPS = STEPS

local function colourOf(c)
  if type(c) ~= "table" then return nil end
  local r, g, b = c[1] or c.r or c.x, c[2] or c.g or c.y, c[3] or c.b or c.z
  if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then return nil end
  if r ~= r or g ~= g or b ~= b then return nil end
  return {clamp01(r), clamp01(g), clamp01(b)}
end

local function tintKey(t)
  return string.format("%d/%d/%d", math.floor(t[1]*8+0.5), math.floor(t[2]*8+0.5), math.floor(t[3]*8+0.5))
end

function M.steps()
  return {tyre=quantise(state.tyre), rim=quantise(state.rim), scrape=quantise(state.scrape),
    under=quantise(state.under), underScrape=quantise(state.underScrape), tint=tintKey(state.tint)}
end

-- ---- strength accounting (pure) ----

-- kind: "mud" | "dirt" | "snow". resolveTint is only called when the tint is
-- actually refreshed (first sample, a change of kind, then every 8th sample).
function M.expose(kind, resolveTint)
  if not enabled then return false end
  local gain = GAIN[kind]
  if not gain then return false end
  state.tyre = math.min(1, state.tyre + gain.tyre)
  state.rim = math.min(1, state.rim + gain.rim)
  state.under = math.min(1, state.under + gain.under)
  state.samples = state.samples + 1
  dirty = true
  if kind ~= state.lastKind or state.samples % 8 == 1 then
    local c
    if kind ~= "snow" and type(resolveTint) == "function" then
      local ok, value = pcall(resolveTint)
      if ok then c = colourOf(value) end
      state.tintResolves = state.tintResolves + 1
    end
    c = c or DEFAULT_TINT[kind]
    if not state.tinted then
      state.tint = {c[1], c[2], c[3]}
    else
      for i = 1, 3 do state.tint[i] = state.tint[i] + (c[i] - state.tint[i]) * 0.35 end
    end
    state.tinted = true
    state.lastKind = kind
  end
  return true
end

-- A wheel dragged on its side: abrasion is permanent until reset.
function M.scrape(wheelId, slipSpeed)
  if not enabled then return false end
  local slip = tonumber(slipSpeed) or 0
  if slip ~= slip then slip = 0 end
  state.scrape = math.min(1, state.scrape + 0.02 + 0.02 * clamp01(slip / 8))
  state.scrapes = state.scrapes + 1
  dirty = true
  local id = tonumber(wheelId) or -1
  state.perWheel[id] = (state.perWheel[id] or 0) + 1
  return true
end

-- The belly grounding out (a kerb, a crest, a rock): abrades the undercarriage
-- materials. Permanent until reset, like rim abrasion.
function M.scrapeUnder(amount)
  if not enabled then return false end
  state.underScrape = math.min(1, state.underScrape + (tonumber(amount) or 0.03))
  dirty = true
  return true
end

-- ---- engine side ----

local function materialIndex()
  local index = {}
  for _, id in ipairs(scenetree.findClassObjects("Material")) do
    local mat = scenetree.findObject(id)
    local key = mat and mat:getField("mapTo", 0)
    if key and key ~= "" and not tostring(mat:getName()):match("^scratches_") then
      local list = index[key] or {}
      list[#list+1] = mat
      index[key] = list
    end
  end
  return index
end

local function pick(list)
  if not list then return nil end
  for _, mat in ipairs(list) do
    if tonumber(mat:getField("version", 0)) == 1.5 then return mat end
  end
  return list[1]
end

-- "tyre", "rim" or nil for a mesh material name and the file that defines it.
function M.classify(name, file)
  local l = tostring(name or ""):lower()
  local f = tostring(file or ""):lower()
  for _, no in ipairs({"steering", "flywheel", "wheelwell", "wheelhouse", "wheelarch", "glass", "fifthwheel"}) do
    if l:find(no, 1, true) then return nil end
  end
  if f:find("^/?vehicles/common/tires/") or l:find("tire", 1, true) or l:find("tyre", 1, true) then return "tyre" end
  if f:find("^/?vehicles/common/wheels/") or l:find("wheel", 1, true) or l:find("hubcap", 1, true)
      or l:find("^rim_") or l:find("_rim") then return "rim" end
  for _, yes in ipairs({"mechanical", "skidplate", "skid_plate", "exhaust", "suspension", "subframe",
      "underbody", "undercarriage", "runningboard", "running_board", "sidestep", "side_step",
      "nerfbar", "mudflap", "rallyparts"}) do
    if l:find(yes, 1, true) then return "under" end
  end
  return nil
end

function M.cloneName(vid, key) return "scratches_" .. vid .. "_whl_" .. key end

local function eligible(mat, role)
  if tonumber(mat:getField("version", 0)) ~= 1.5 then return false, "not PBR v1.5" end
  local count = tonumber(mat:getField("activeLayers", 0))
  if not count or count < 1 or count > 3 then return false, "no free stage" end
  if tostring(mat:getField("translucent", 0)) == "1" then return false, "translucent" end
  return true, count
end

-- Which wheel/tyre mesh keys this constructed vehicle renders, and which are
-- already on our clones. Records the keys so the next build can clone them.
local function discover(veh)
  local vid = veh:getId()
  local prefix = "scratches_" .. vid .. "_whl_"
  local keys, cloned, uncloned, seen = {}, {}, 0, {}
  for _, name in pairs(veh:getMaterialNames()) do
    if not seen[name] then
      seen[name] = true
      if name:sub(1, #prefix) == prefix then
        local key = name:sub(#prefix + 1)
        cloned[key] = true
      elseif not name:match("^scratches_") then
        local mat = scenetree.findObject(name)
        if mat and mat.getField then
          local key = mat:getField("mapTo", 0)
          if not key or key == "" then key = name end
          local role = M.classify(key, mat.getFilename and mat:getFilename() or "")
          if role and eligible(mat, role) then
            keys[key] = role
            uncloned = uncloned + 1
          end
        end
      end
    end
  end
  local known = keysByVid[vid] or {}
  for key, role in pairs(keys) do known[key] = role end
  for key in pairs(cloned) do
    if not known[key] then known[key] = M.classify(key, "") or "rim" end
  end
  keysByVid[vid] = known
  local model = veh.JBeam or veh.jbeam
  if model and next(known) then keysByModel[model] = known end
  return known, cloned, uncloned
end

local function cloneWheel(vid, key, role, source)
  local ok, count = eligible(source, role)
  assert(ok, "wheel material " .. tostring(source:getName()) .. " skipped: " .. tostring(count))
  local name = M.cloneName(vid, key)
  local mat = scenetree.findObject(name) or createObject("Material")
  local registered = mat:getName() == name
  for field in pairs(source:getFields()) do
    if not skipFields[field] then
      for st = 0, 3 do mat:setField(field, st, source:getField(field, st)) end
    end
  end
  mat:setField("name", 0, name)
  mat:setField("mapTo", 0, name)
  mat.canSave = false
  mat:setField("scratchesOwner", 0, OWNER)
  local dirtStage = count
  local scrapeStage = (role ~= "tyre" and count + 1 <= 3) and count + 1 or nil
  local normal = source:getField("normalMap", 0)
  local function stage(st, fields)
    for f, value in pairs(fields) do mat:setField(f, st, tostring(value)) end
  end
  stage(dirtStage, {baseColorMap=TEX .. "wheel_dirt.color.png", diffuseMapUseUV=0,
    baseColorFactor="0.4 0.33 0.25 1", instanceDiffuse="false", colorPaletteMap="",
    opacityMap=TEX .. "wheel_dirt_o.data.png", opacityMapUseUV=0, opacityFactor=0,
    metallicFactor=0, roughnessFactor=0.85, clearCoatFactor=0, normalMap=normal or ""})
  if scrapeStage then
    stage(scrapeStage, {baseColorMap=TEX .. "wheel_scrape.color.png", diffuseMapUseUV=0,
      baseColorFactor="0.78 0.78 0.8 1", instanceDiffuse="false", colorPaletteMap="",
      opacityMap=TEX .. "wheel_scrape_o.data.png", opacityMapUseUV=0, opacityFactor=0,
      metallicFactor=1, roughnessFactor=0.42, clearCoatFactor=0, normalMap=normal or ""})
  end
  -- Appended stages stay switched off until there is something to show.
  mat:setField("activeLayers", 0, tostring(count))
  if not registered then mat:registerObject(name) end
  mat:flush(); mat:reload()
  clones[name] = count
  return {name=name, key=key, role=role, count=count, dirtStage=dirtStage, scrapeStage=scrapeStage,
    sourceName=source:getName()}
end

-- Jbeam Phase2: clone the known wheel materials and point the flexbodies at them.
function M.prepare(_, vid, vdata)
  prepared[vid] = nil
  skipped[vid] = nil
  -- A rebuild re-clones this vehicle's materials clean; forget what was written.
  if attached and attached.vid == vid then applied = nil end
  if not enabled or not vdata then return end
  local keys = keysByVid[vid] or keysByModel[vdata.model]
  if not keys or not next(keys) then
    skipped[vid] = "wheel materials not known before the first build"
    return
  end
  local index = materialIndex()
  local entries, notes = {}, {}
  for key, role in pairs(keys) do
    local foreign = false
    for _, flex in pairs(vdata.flexbodies or {}) do
      for _, override in pairs(flex.materialOverride or {}) do
        if override[1] == key and not tostring(override[2]):match("^scratches_") then foreign = true end
      end
    end
    local source = pick(index[key])
    if foreign then notes[#notes+1] = key .. ": existing override"
    elseif not source then notes[#notes+1] = key .. ": no source material"
    else
      local ok, entry = pcall(cloneWheel, vid, key, role, source)
      if ok then entries[#entries+1] = entry else notes[#notes+1] = key .. ": " .. tostring(entry) end
    end
  end
  if #entries == 0 then skipped[vid] = table.concat(notes, "; "); return end
  for _, flex in pairs(vdata.flexbodies or {}) do
    local overrides = {}
    local mine = {}
    for _, entry in ipairs(entries) do mine[entry.key] = true end
    for _, override in ipairs(flex.materialOverride or {}) do
      if not mine[override[1]] then overrides[#overrides+1] = override end
    end
    for _, entry in ipairs(entries) do overrides[#overrides+1] = {entry.key, entry.name} end
    flex.materialOverride = overrides
  end
  prepared[vid] = {entries=entries, notes=notes}
end

-- True when this constructed vehicle renders wheel materials that are not on
-- our clones yet (one rebuild binds them).
function M.needsRebuild(veh)
  if not enabled or not veh then return false end
  local ok, _, _, uncloned = pcall(discover, veh)
  return ok and (uncloned or 0) > 0
end

local function applyEntry(entry, steps, tint)
  local mat = scenetree.findObject(entry.name)
  if not mat then return false end
  local dirt = entry.role == "tyre" and steps.tyre or (entry.role == "under" and (steps.under or 0) or steps.rim)
  local scrape = entry.role == "under" and (steps.underScrape or 0) or steps.scrape
  mat:setField("opacityFactor", entry.dirtStage, tostring(dirt / STEPS * MAX_OPACITY[entry.role]))
  mat:setField("baseColorFactor", entry.dirtStage, string.format("%.3f %.3f %.3f 1", tint[1], tint[2], tint[3]))
  local layers = entry.count
  if dirt > 0 then layers = entry.count + 1 end
  if entry.scrapeStage then
    mat:setField("opacityFactor", entry.scrapeStage, tostring(scrape / STEPS * 0.9))
    if scrape > 0 then layers = entry.count + 2 end
  end
  mat:setField("activeLayers", 0, tostring(layers))
  -- setField, then flush, then reload: skipping flush re-reads stale state.
  mat:flush(); mat:reload()
  return true
end

local function sync(force)
  if not attached then return false end
  if not force and not dirty and applied then return false end
  local steps = M.steps()
  if not force and applied and applied.tyre == steps.tyre and applied.rim == steps.rim
      and applied.scrape == steps.scrape and applied.tint == steps.tint
      and applied.under == steps.under and applied.underScrape == steps.underScrape then dirty = false; return false end
  if not force and sinceApply < MIN_APPLY_INTERVAL then return false end
  -- Tint alone is invisible while nothing is soiled.
  if not force and applied and steps.tyre == 0 and steps.rim == 0 and steps.under == 0
      and applied.tyre == 0 and applied.rim == 0 and applied.under == 0
      and applied.scrape == steps.scrape and applied.underScrape == steps.underScrape then
    dirty = false
    return false
  end
  for _, entry in ipairs(attached.entries) do pcall(applyEntry, entry, steps, state.tint) end
  applied = steps
  dirty = false
  sinceApply = 0
  state.applies = state.applies + 1
  return true
end

-- Per frame: washing fades soil at the body's rate; abrasion survives.
function M.update(dt, washFraction)
  dt = math.max(0, math.min(0.25, tonumber(dt) or 0))
  sinceApply = sinceApply + dt
  if not enabled then return false end
  local wash = clamp01(tonumber(washFraction) or 0)
  if wash > 0 and (state.tyre > 0 or state.rim > 0) then
    dirty = true
    state.tyre = math.max(0, state.tyre - dt * wash / 8)
    state.rim = math.max(0, state.rim - dt * wash / 8)
    state.under = math.max(0, state.under - dt * wash / 8)
    if state.tyre == 0 and state.rim == 0 and state.under == 0 then state.tinted = false; state.lastKind = nil end
  end
  return sync(false)
end

-- Bind to the player's constructed vehicle. Returns the number of materials.
function M.attach(veh)
  M.detach()
  if not enabled or not veh then return 0 end
  local vid = veh:getId()
  local known, cloned = discover(veh)
  local entries = {}
  local prep = prepared[vid]
  local byKey = {}
  for _, entry in ipairs(prep and prep.entries or {}) do byKey[entry.key] = entry end
  local index
  for key in pairs(cloned) do
    local entry = byKey[key]
    if not entry then
      -- Hot reload: adopt a clone that is already on the meshes.
      index = index or materialIndex()
      local source = pick(index[key])
      if source then
        local ok, adopted = pcall(cloneWheel, vid, key, known[key] or "rim", source)
        if ok then entry = adopted end
      end
    end
    if entry then entries[#entries+1] = entry end
  end
  if #entries == 0 then
    skipped[vid] = skipped[vid] or (next(known) and "wheel clones are not on the meshes; reload the vehicle once"
      or "no wheel or tyre materials recognised")
    return 0
  end
  table.sort(entries, function(a, b) return a.name < b.name end)
  skipped[vid] = nil
  attached = {vid=vid, entries=entries}
  applied = nil
  sync(true)
  return #entries
end

function M.detach()
  if not attached then return end
  for _, entry in ipairs(attached.entries) do
    pcall(function()
      local live = scenetree.findObject(entry.name)
      if live then
        live:setField("activeLayers", 0, tostring(entry.count))
        live:flush(); live:reload()
      end
    end)
  end
  attached, applied = nil, nil
end

-- Reset clears soil and abrasion alike, like body damage.
function M.reset()
  state = newState()
  -- Immediate, but only when the materials actually show something: reset
  -- runs on every vehicle reset and a forced write reloads every clone.
  dirty = true
  if attached then sinceApply = MIN_APPLY_INTERVAL; sync(false) end
end

function M.disableAll()
  attached, applied = nil, nil
  for name, count in pairs(clones) do
    pcall(function()
      local live = scenetree.findObject(name)
      if live then
        live:setField("activeLayers", 0, tostring(count))
        live:flush(); live:reload()
      end
    end)
  end
end

-- Delete our clones of vehicles that no longer exist and that no mesh uses.
function M.collectUnused()
  local liveIds, referenced = {}, {}
  for _, veh in ipairs(getAllVehicles()) do
    liveIds[veh:getId()] = true
    for _, name in pairs(veh:getMaterialNames()) do referenced[name] = true end
  end
  for _, id in ipairs(scenetree.findClassObjects("Material")) do
    local mat = scenetree.findObject(id)
    local name = mat and mat:getName()
    local owner = name and tonumber(tostring(name):match("^scratches_(%d+)_whl_"))
    if owner and not liveIds[owner] and not referenced[name] and mat:getField("scratchesOwner", 0) == OWNER then
      mat:delete()
      clones[name] = nil
    end
  end
  for _, t in ipairs({prepared, skipped, keysByVid}) do
    for vid in pairs(t) do if not liveIds[vid] then t[vid] = nil end end
  end
  return true
end

function M.setEnabled(on)
  on = on and true or false
  if not on then
    state = newState()
    if attached then pcall(sync, true) end
    M.detach()
  end
  enabled = on
end
function M.isEnabled() return enabled end

function M.snapshot()
  local out = {enabled=enabled, tyre=state.tyre, rim=state.rim, scrape=state.scrape,
    under=state.under, underScrape=state.underScrape,
    steps=M.steps(), tint={state.tint[1], state.tint[2], state.tint[3]}, samples=state.samples,
    scrapes=state.scrapes, applies=state.applies, tintResolves=state.tintResolves,
    lastKind=state.lastKind, attached=attached and #attached.entries or 0, materials={}, perWheel={}}
  for id, n in pairs(state.perWheel) do out.perWheel[id] = n end
  for i, entry in ipairs(attached and attached.entries or {}) do
    out.materials[i] = entry.name .. " (" .. entry.role .. ", from " .. tostring(entry.sourceName) .. ")"
  end
  if attached then
    out.vid = attached.vid
    out.skipped = prepared[attached.vid] and table.concat(prepared[attached.vid].notes or {}, "; ") or ""
  else
    local reasons = {}
    for vid, why in pairs(skipped) do reasons[#reasons+1] = vid .. ": " .. tostring(why) end
    table.sort(reasons)
    out.skipped = table.concat(reasons, "; ")
  end
  return out
end

-- Harness hook: bind the accounting to named materials without an engine.
function M._attachEntries(vid, entries)
  attached = {vid=vid, entries=entries}
  applied = nil
  sinceApply = 1
  return sync(true)
end

return M
