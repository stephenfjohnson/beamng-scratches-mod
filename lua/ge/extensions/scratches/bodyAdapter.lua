-- Generic runtime body-material adapter. Never writes source materials/config.
--
-- For any vehicle that ships a Dynamic Textures skin, the "body keys" are the
-- mesh material keys that have a `<key>.skin.dynamicTextures` variant loaded from
-- that vehicle's own folder (the engine's own paintable-body definition). For
-- each body key we clone the material the engine would render -- the one mapped
-- to `<key>.skin.<skinName>` when a paint design is chosen, else `<key>` -- and
-- append a damage stage and a soil stage. A construction-time flexbody material
-- override points the meshes at the clones. The original stages, palette,
-- PBR channels and livery artwork are copied unchanged. Anything unexpected
-- (non-PBR or full materials, foreign overrides, editor-owned designs) is
-- rejected so the car keeps its original paint.
local M = {}
local skipFields = {name=true,mapTo=true,persistentId=true,parentGroup=true,
  internalName=true,class=true,className=true,superClass=true,hidden=true,
  locked=true,canSave=true,canSaveDynamicFields=true}
local OWNER = "bodyAdapter-v2"
local LEGACY_OWNER = "etkAdapter-v1"
local DT_SUFFIX = ".skin.dynamicTextures"
local prepared = {}
local rejected = {}
local clones = {}
local privateApi -- reuse the private damage target across attachments
local damageWidth = 4096
local soilTarget -- one reusable soil projection for this painter, not per vehicle

function M.editorActive()
  return (editor and editor.active) or (DecalShapeRenderApp and DecalShapeRenderApp.getActiveApp and DecalShapeRenderApp:getActiveApp()) or false
end
local function getUpvalue(fn,wanted)
  for i=1,100 do
    local name,value=debug.getupvalue(fn,i)
    if not name then break end
    if name==wanted then return value end
  end
  error("engine API changed: missing " .. wanted)
end

-- A vehicle can use the adapter only if it ships Dynamic Textures materials.
function M.modelSupported(model)
  return type(model)=="string" and FS ~= nil and FS:directoryExists("/vehicles/" .. model .. "/dynamicDecals") or false
end

-- The player's own Dynamic Textures design is editor artwork: never adopt it.
function M.isEditorDesign(part)
  return type(part)=="string" and part:match("_skin_dynamicTextures$") ~= nil
end

function M.cloneName(vid,key) return "scratches_" .. vid .. "_" .. key end

-- mapTo -> {Material objects}. Material object names are not mapTo keys
-- (ETK: `etk800_main` maps to `etk800`; an object named `etk800` maps to
-- `etk800_old`), so everything resolves through mapTo like the renderer does.
local function materialIndex()
  local index = {}
  for _,id in ipairs(scenetree.findClassObjects("Material")) do
    local mat = scenetree.findObject(id)
    local key = mat and mat:getField("mapTo",0)
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
  for _,mat in ipairs(list) do
    if tonumber(mat:getField("version",0)) == 1.5 then return mat end
  end
  return list[1]
end

-- Body keys: keys with a Dynamic Textures variant authored in this vehicle's folder.
function M.bodyKeys(index,vehicleDirectory)
  local keys = {}
  local prefix = vehicleDirectory
  if prefix and prefix:sub(-1) ~= "/" then prefix = prefix .. "/" end
  for key,list in pairs(index) do
    local base = key:match("^(.*)" .. DT_SUFFIX:gsub("%.","%%.") .. "$")
    if base then
      for _,mat in ipairs(list) do
        local file = mat.getFilename and mat:getFilename() or ""
        if not prefix or file:sub(1,#prefix) == prefix then keys[#keys+1] = base; break end
      end
    end
  end
  table.sort(keys)
  return keys
end

-- The material the renderer uses for a mesh key under the chosen skin.
function M.resolveSource(index,key,skin)
  if skin and skin ~= "" then
    local variant = pick(index[key .. ".skin." .. skin])
    if variant then return variant end
  end
  return pick(index[key])
end

local function cloneMaterial(vid,key,source,part)
  local count = tonumber(source:getField("activeLayers",0))
  assert(tonumber(source:getField("version",0)) == 1.5, "body material " .. source:getName() .. " is not PBR v1.5")
  assert(count and count >= 1 and count <= 2, "body material " .. source:getName() .. " has no room for damage and soil stages")
  local name = M.cloneName(vid,key)
  local mat = scenetree.findObject(name) or createObject("Material")
  local registered = mat:getName() == name
  for field in pairs(source:getFields()) do
    if not skipFields[field] then
      for st=0,3 do mat:setField(field,st,source:getField(field,st)) end
    end
  end
  mat:setField("name",0,name)
  mat:setField("mapTo",0,name)
  mat.canSave = false
  mat:setField("scratchesOwner",0,OWNER)
  clones[name] = {mat=mat,count=count}
  local function set(f,v) mat:setField(f,count,tostring(v)) end
  set("baseColorMap","@DynamicTextureBaseColor")
  set("diffuseMapUseUV",1)
  -- Keep the authored brush detail visible at normal driving distance.
  set("baseColorFactor","1 1 1 1")
  set("instanceDiffuse",false)
  set("colorPaletteMap","")
  set("opacityMap","@DynamicTextureBaseColor")
  set("opacityMapUseUV",1)
  set("opacityFactor",1.6)
  set("metallicMap","")
  set("roughnessMap","")
  set("metallicFactor",0)
  set("roughnessFactor",0.65)
  set("clearCoatFactor",0)
  set("normalMap",source:getField("normalMap",0))
  mat:setField("activeLayers",0,tostring(count))
  if not registered then mat:registerObject(name) end
  mat:flush(); mat:reload()
  return {material=mat,source=source,sourceName=source:getName(),stage=count,part=part,key=key}
end

local function cloneBodyMaterials(vid,keys,skin,part,index)
  index = index or materialIndex()
  local entries = {}
  for _,key in ipairs(keys) do
    local source = M.resolveSource(index,key,skin)
    assert(source, "no source material for body key " .. key)
    entries[#entries+1] = cloneMaterial(vid,key,source,part)
  end
  assert(#entries > 0, "vehicle has no body materials")
  return {entries=entries,keys=keys,skin=skin,part=part,material=entries[1].material,
    source=entries[1].source,sourceName=entries[1].sourceName,stage=entries[1].stage}
end

local function paintPart(cfg)
  local part
  local function walk(n)
    if type(n)~="table" or part then return end
    if n.id=="paint_design" then part=n.chosenPartName or ""; return end
    for _,child in pairs(n.children or {}) do walk(child) end
  end
  walk(cfg and cfg.partsTree)
  return part or ""
end

local function skinOf(activePartsData,part)
  if part == "" then return "" end
  local data = activePartsData and activePartsData[part]
  if not data then return nil end
  -- Engine rule (jbeam/sections/licenseplatesSkins): a design without a skin
  -- name selects no variant; its artwork comes from its own overlay meshes.
  return data.skinName or data.globalSkin or ""
end

function M.prepare(_,vid,vdata,_,cfg)
  prepared[vid] = nil
  rejected[vid] = nil
  if not vdata or not M.modelSupported(vdata.model) or M.editorActive() then return end
  local part = paintPart(cfg)
  if M.isEditorDesign(part) then return end
  local skin = skinOf(vdata.activePartsData,part)
  if skin == nil then rejected[vid] = "paint design " .. part .. " has no skin name"; return end
  local index = materialIndex()
  local keys = M.bodyKeys(index,vdata.vehicleDirectory or ("/vehicles/" .. vdata.model .. "/"))
  if #keys == 0 then return end -- materials not loaded yet; create() retries once
  local isBody = {}
  for _,key in ipairs(keys) do isBody[key] = true end
  for _,flex in pairs(vdata.flexbodies or {}) do
    for _,override in pairs(flex.materialOverride or {}) do
      if isBody[override[1]] and not tostring(override[2]):match("^scratches_") then
        rejected[vid] = "existing body material override; adapter skipped"
        return
      end
    end
  end
  local ok,prep=pcall(cloneBodyMaterials,vid,keys,skin,part,index)
  if not ok then rejected[vid]=tostring(prep); return end
  prepared[vid]=prep
  for _,flex in pairs(vdata.flexbodies or {}) do
    local overrides={}
    for _,override in ipairs(flex.materialOverride or {}) do
      if not isBody[override[1]] then overrides[#overrides+1]=override end
    end
    for _,entry in ipairs(prep.entries) do
      overrides[#overrides+1]={entry.key,entry.material:getName()}
    end
    flex.materialOverride=overrides
  end
end

-- Whether trySetup should route this vehicle through the adapter.
function M.wants(veh,part)
  if not veh or M.isEditorDesign(part) then return false end
  local vid = veh:getId()
  if rejected[vid] then return false end
  return M.modelSupported(veh.JBeam or veh.jbeam)
end

function M.rejection(vid) return rejected[vid] end

function M.invalidateConstructionCache()
  assert(not M.editorActive(), "editor owns rendering")
  -- Installed loader caches Phase2 flexbody overrides by config, not vehicle ID.
  -- Invalidate before supported construction, including background spawns.
  -- Retrying only the selected vehicle leaves inactive meshes sharing a clone.
  require("jbeam/loader").onFileChanged()
end

local function ownerOf(name)
  return tonumber(name:match("^scratches_(%d+)_")) or tonumber(name:match("^scratches_etk800_(%d+)_"))
end

function M.collectUnusedMaterials()
  if M.editorActive() then return false end
  local liveIds, referenced = {}, {}
  for _, veh in ipairs(getAllVehicles()) do
    liveIds[veh:getId()] = true
    for _, name in pairs(veh:getMaterialNames()) do referenced[name] = true end
  end
  -- Ownership marker survives extension reload; never touch a source material
  -- or a clone referenced by any live mesh, including a stale cached bundle.
  for _, id in ipairs(scenetree.findClassObjects("Material")) do
    local mat = scenetree.findObject(id)
    local name = mat and mat:getName()
    local owner = name and ownerOf(name)
    local tag = owner and mat:getField("scratchesOwner",0)
    if owner and not liveIds[owner] and not referenced[name] and (tag==OWNER or tag==LEGACY_OWNER) then
      mat:delete()
      clones[name] = nil
    end
  end
  for vid in pairs(prepared) do if not liveIds[vid] then prepared[vid]=nil end end
  for vid in pairs(rejected) do if not liveIds[vid] then rejected[vid]=nil end end
  return true
end

local function runtimeSkin(vid,part)
  if part == "" then return "" end
  local data = core_vehicle_manager and core_vehicle_manager.getVehicleData and core_vehicle_manager.getVehicleData(vid)
  return skinOf(data and data.vdata and data.vdata.activePartsData,part)
end

function M.create(veh,part)
  assert(not M.editorActive(), "editor owns rendering; adapter skipped")
  local vid = veh:getId()
  assert(not rejected[vid], rejected[vid])
  local prep=prepared[vid]
  local present={}
  for _,name in pairs(veh:getMaterialNames()) do present[name]=true end
  if not prep or prep.part~=part then
    -- A hot reload can adopt already constructed private materials without
    -- respawning/repairing the car. No editor-owned design is eligible here.
    local index = materialIndex()
    local keys = {}
    for _,key in ipairs(M.bodyKeys(index,"/vehicles/" .. (veh.JBeam or veh.jbeam) .. "/")) do
      if present[M.cloneName(vid,key)] then keys[#keys+1]=key end
    end
    if #keys == 0 then return nil end
    local skin = runtimeSkin(vid,part)
    assert(skin ~= nil, "paint design " .. tostring(part) .. " has no skin name")
    prep=cloneBodyMaterials(vid,keys,skin,part,index)
    prepared[vid]=prep
  end
  -- Every clone must be on the constructed meshes: a stale cached bundle can
  -- carry another vehicle's clones, and a partial binding would split panels.
  for _,entry in ipairs(prep.entries) do
    if not present[entry.material:getName()] then return nil end
  end
  local entries = prep.entries
  local count = prep.stage
  for _,entry in ipairs(entries) do
    assert(entry.stage == count, "body materials disagree on stage count")
  end
  local soilStage = count + 1
  -- Execute the installed API into a private Lua table: no extension hooks,
  -- editor layer stack or editor projection is shared. setup does bind the
  -- private set to this eligible vehicle; no unowned design reaches this path.
  local api = privateApi or dofile("/lua/ge/extensions/editor/api/dynamicDecals.lua")
  -- Engine sandbox forbids debug.setupvalue. Let this private API construct
  -- its own projection; then customize its app table (getupvalue is supported).
  assert(not M.editorActive(), "editor owns rendering")
  api.updateVehicleMaterials = function() end -- no delayed heuristic may replace our exact indices
  api.setup()
  privateApi = api
  local projection = getUpvalue(api.bakeLayers,"decalProjection")
  local app = getUpvalue(api.onUpdate_,"app")
  if api.getTextureResolution().x ~= damageWidth then
    api.setTextureResolution(Point2I(damageWidth,damageWidth/2))
  end
  local textureSet = app.textureSet
  function app:onUpdate()
    projection:setShape(veh:getDecalProjectionShape())
    projection:setWorldTransform(veh:getRefNodeMatrix())
    projection:setTransform(veh:getRefNodeMatrix():copy():setPosition(vec3(0,0,0)):inverse())
    veh:setTextureSet("@DynamicTexture", textureSet)
  end
  function app:setTextureSet(_,set) veh:setTextureSet("@DynamicTexture",set) end
  api.onVehicleSwitched = function() app:onUpdate() end
  app:onUpdate()
  local names={}
  for _,entry in ipairs(entries) do names[entry.material:getName()]=true end
  local indices = {}
  for idx, materialName in pairs(api.getShapeMaterialNames()) do
    if names[materialName] then indices[#indices+1] = idx end
  end
  assert(#indices >= 1,"body materials not in projection shape")
  table.sort(indices)
  api.clearMaterialIdx()
  api.setMaterialIdx(indices[1])
  for i=2,#indices do api.addMaterialIdx(indices[i]) end
  projection:clearBakedTextures(); projection:flushDynamicTextures()
  projection:combineTextures(textureSet)
  -- Separate, bounded 1024x512 soil target; damage remains in its original set.
  soilTarget = soilTarget or DecalProjection("", Point2I(1024,512), 1, indices[1])
  local soil = soilTarget
  local soilSet = soil:getTextureSet()
  local function syncSoil()
    soil:setShape(veh:getDecalProjectionShape())
    soil:setWorldTransform(veh:getRefNodeMatrix())
    soil:setTransform(veh:getRefNodeMatrix():copy():setPosition(vec3(0,0,0)):inverse())
    veh:setTextureSet("@ScratchesSoil",soilSet)
  end
  syncSoil()
  soil:clearMaterialIdx(); soil:setMaterialIdx(indices[1])
  for i=2,#indices do soil:addMaterialIdx(indices[i]) end
  soil:clearBakedTextures(); soil:flushDynamicTextures(); soil:combineTextures(soilSet)
  for _,entry in ipairs(entries) do
    local mat=entry.material
    for f in pairs(mat:getFields()) do mat:setField(f,soilStage,mat:getField(f,count)) end
    mat:setField("baseColorMap",soilStage,"@ScratchesSoilBaseColor")
    mat:setField("baseColorFactor",soilStage,"1 1 1 1")
    mat:setField("opacityMap",soilStage,"@ScratchesSoilBaseColor")
    -- Static micro-relief is blended by this stage's dynamic soil opacity.
    -- Retain the factory normalMap; no unsupported dynamic-normal binding.
    mat:setField("detailNormalMap",soilStage,"/art/dynamicDecals/textures/soil_relief_detail.normal.png")
    mat:setField("normalDetailMapUseUV",soilStage,"1")
    mat:setField("detailScale",soilStage,"8 8")
    mat:setField("detailNormalMapStrength",soilStage,"0.65")
    mat:setField("activeLayers",0,tostring(count+2))
    mat:flush(); mat:reload()
  end
  -- Material is selected at construction via the flexbody override.
  local result = {api=api,projection=projection,material=prep.material,source=prep.source,
    sourceName=prep.sourceName,stage=count,soilStage=soilStage,part=part,skin=prep.skin,
    indices=indices,vid=vid,materials=entries,keys=prep.keys}
  function result:setDamageWidth(width)
    assert(width==4096 or width==2048 or width==1024, "unsupported damage resolution")
    assert(not M.editorActive(), "editor owns rendering")
    api.setTextureResolution(Point2I(width,width/2))
    textureSet=app.textureSet
    app:onUpdate()
    assert(api.getTextureResolution().x==width, "native resolution change failed")
    damageWidth=width
  end
  function result:getDamageWidth() return api.getTextureResolution().x end
  for _,entry in ipairs(entries) do
    local originalWet = {}
    for st=0,count-1 do
      originalWet[st]={}
      for _,f in ipairs({"clearCoatFactor","clearCoatRoughnessFactor"}) do
        originalWet[st][f]=entry.source:getField(f,st)
      end
    end
    entry.originalWet=originalWet
  end
  local wetBucket, soilBucket = 0, 20
  function result:bakeSoil(layers)
    syncSoil()
    soil:bakeLayers(layers,veh.JBeam)
    soil:combineTextures(soilSet)
  end
  function result:clearSoil()
    soil:clearBakedTextures(); soil:flushDynamicTextures(); soil:combineTextures(soilSet)
  end
  function result:appearance(wet, remaining)
    local w,s = math.floor(wet*10+0.5), math.floor(remaining*20+0.5)
    if w==wetBucket and s==soilBucket then return end
    wetBucket,soilBucket=w,s
    for _,entry in ipairs(entries) do
      local mat,originalWet=entry.material,entry.originalWet
      for st=0,count-1 do
        for _,f in ipairs({"clearCoatFactor","clearCoatRoughnessFactor"}) do
          local original=originalWet[st][f]
          local value=tonumber(original) or (f=="clearCoatFactor" and 0 or 0.1)
          local target=f=="clearCoatFactor" and 1 or 0.025
          mat:setField(f,st,w==0 and original or tostring(value+(target-value)*w/10))
        end
      end
      mat:setField("roughnessFactor",soilStage,tostring(0.65-0.45*w/10))
      mat:setField("opacityFactor",soilStage,tostring(s/20))
      mat:flush(); mat:reload()
    end
  end
  function result:damageTone(luminance)
    -- Plain light paint needs darker exposed coating. Liveries contain both
    -- light and dark texels, so keep their neutral compromise. Setup/reset only.
    local factor = self.part == "" and luminance and luminance >= 0.5 and 0.15 or 1
    local value = string.format("%.2f %.2f %.2f 1",factor,factor,factor)
    for _,entry in ipairs(entries) do
      local mat=entry.material
      if mat:getField("baseColorFactor",count) ~= value then
        mat:setField("baseColorFactor",count,value); mat:flush(); mat:reload()
      end
    end
  end
  function result:clear()
    self:clearSoil(); self:appearance(0,1)
    projection:clearBakedTextures(); projection:flushDynamicTextures()
    projection:combineTextures(textureSet)
  end
  function result:detach()
    -- Disable only our appended stages. Original channels in the clone remain
    -- identical, even if its mesh instance outlives this extension.
    for _,entry in ipairs(entries) do
      local live = scenetree.findObject(entry.material:getName())
      if live then
        for st=0,count-1 do
          for _,f in ipairs({"clearCoatFactor","clearCoatRoughnessFactor"}) do
            live:setField(f,st,entry.originalWet[st][f])
          end
        end
        live:setField("activeLayers",0,tostring(count))
        live:flush(); live:reload()
      end
    end
  end
  return result
end
function M.disableAll()
  for name,c in pairs(clones) do
    -- Level teardown may delete scene materials before extension unload.
    local live = scenetree.findObject(name)
    if live then
      live:setField("activeLayers",0,tostring(c.count))
      live:flush(); live:reload()
    end
  end
end
return M
