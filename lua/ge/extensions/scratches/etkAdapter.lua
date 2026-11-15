-- Narrow ETK 800 runtime material adapter. Never writes source materials/config.
local M = {}
local skipFields = {name=true,mapTo=true,persistentId=true,parentGroup=true,
  internalName=true,class=true,className=true,superClass=true,hidden=true,
  locked=true,canSave=true,canSaveDynamicFields=true}
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

local function cloneMaterial(veh,part)
  assert(veh.JBeam == "etk800" and (part == "" or part == "etk800_skin_police"))
  local sourceName = part == "" and "etk800_main" or "etk800.skin.police"
  local source = assert(scenetree.findObject(sourceName), "source material missing")
  local count = tonumber(source:getField("activeLayers",0))
  assert(count == 2 and tonumber(source:getField("version",0)) == 1.5, "unexpected stock material layout")
  if part ~= "" then
    assert(source:getField("baseColorMap",1) == "vehicles/etk800/etk800_skin_police_b.color.png", "non-stock police material")
  end
  local name = "scratches_etk800_" .. veh:getId() .. (part == "" and "_plain" or "_police")
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
  mat:setField("scratchesOwner",0,"etkAdapter-v1")
  clones[name] = {mat=mat,count=count}
  local function set(f,v) mat:setField(f,count,tostring(v)) end
  set("baseColorMap","@DynamicTextureBaseColor")
  set("diffuseMapUseUV",1)
  -- Keep coverage from the authored brush, but mute its diffuse response.
  set("baseColorFactor","0.75 0.75 0.75 1")
  set("instanceDiffuse",false)
  set("colorPaletteMap","")
  set("opacityMap","@DynamicTextureBaseColor")
  set("opacityMapUseUV",1)
  set("opacityFactor",1)
  set("metallicMap","")
  set("roughnessMap","")
  set("metallicFactor",0)
  set("roughnessFactor",0.65)
  set("clearCoatFactor",0)
  set("normalMap",source:getField("normalMap",0))
  mat:setField("activeLayers",0,tostring(count))
  if not registered then mat:registerObject(name) end
  mat:flush(); mat:reload()
  return {material=mat,source=source,sourceName=sourceName,stage=count,part=part}
end

function M.prepare(_,vid,vdata,_,cfg)
  prepared[vid] = nil
  rejected[vid] = nil
  if vdata.model ~= "etk800" or M.editorActive() then return end
  local part
  local function walk(n)
    if type(n)~="table" then return end
    if n.id=="paint_design" then part=n.chosenPartName or "" end
    for _,child in pairs(n.children or {}) do walk(child) end
  end
  walk(cfg.partsTree)
  if part~="" and part~="etk800_skin_police" then return end
  local veh=scenetree.findObjectById(vid)
  for _,flex in pairs(vdata.flexbodies or {}) do
    for _,override in pairs(flex.materialOverride or {}) do
      if override[1] == "etk800" and not tostring(override[2]):match("^scratches_etk800_") then
        rejected[vid] = "existing ETK body override; adapter skipped"
        return
      end
    end
  end
  local ok,prep=pcall(cloneMaterial,veh,part)
  if not ok then rejected[vid]=tostring(prep); return end
  prepared[vid]=prep
  for _,flex in pairs(vdata.flexbodies or {}) do
    local overrides={}
    for _,override in ipairs(flex.materialOverride or {}) do
      if override[1] ~= "etk800" then overrides[#overrides+1]=override end
    end
    overrides[#overrides+1]={"etk800",prep.material:getName()}
    flex.materialOverride=overrides
  end
end

function M.invalidateConstructionCache()
  assert(not M.editorActive(), "editor owns rendering")
  -- Installed loader caches Phase2 flexbody overrides by config, not vehicle ID.
  -- Invalidate before ETK construction, including background spawns. Retrying
  -- only the selected vehicle leaves inactive meshes sharing an active clone.
  require("jbeam/loader").onFileChanged()
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
    local owner = name and tonumber(name:match("^scratches_etk800_(%d+)_"))
    if owner and not liveIds[owner] and not referenced[name]
       and mat:getField("scratchesOwner",0)=="etkAdapter-v1" then
      mat:delete()
      clones[name] = nil
    end
  end
  for vid in pairs(prepared) do if not liveIds[vid] then prepared[vid]=nil end end
  for vid in pairs(rejected) do if not liveIds[vid] then rejected[vid]=nil end end
  return true
end

function M.create(veh,part)
  assert(not M.editorActive(), "editor owns rendering; adapter skipped")
  assert(not rejected[veh:getId()], rejected[veh:getId()])
  local prep=prepared[veh:getId()]
  local expected="scratches_etk800_" .. veh:getId() .. (part=="" and "_plain" or "_police")
  local present=false
  for _,name in pairs(veh:getMaterialNames()) do if name==expected then present=true end end
  if not present then return nil end
  if not prep or prep.part~=part then
    -- A hot reload can adopt an already constructed private material without
    -- respawning/repairing the car. No editor-owned design is eligible here.
    prep=cloneMaterial(veh,part)
    prepared[veh:getId()]=prep
  end
  local source, sourceName, count=prep.source,prep.sourceName,prep.stage
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
  local mat = prep.material
  local name = mat:getName()
  local indices = {}
  for idx, materialName in pairs(api.getShapeMaterialNames()) do
    if materialName == name then indices[#indices+1] = idx end
  end
  assert(#indices > 0,"ETK body material not in projection shape")
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
  for f in pairs(mat:getFields()) do mat:setField(f,3,mat:getField(f,2)) end
  mat:setField("baseColorMap",3,"@ScratchesSoilBaseColor")
  mat:setField("baseColorFactor",3,"1 1 1 1")
  mat:setField("opacityMap",3,"@ScratchesSoilBaseColor")
  mat:setField("activeLayers",0,tostring(count+2))
  mat:flush(); mat:reload()
  -- Material is selected at construction via the flexbody override.
  local result = {api=api,projection=projection,material=mat,source=source,
    sourceName=sourceName,stage=count,part=part,indices=indices,vid=veh:getId()}
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
  local originalWet = {}
  for st=0,count-1 do
    originalWet[st]={}
    for _,f in ipairs({"clearCoatFactor","clearCoatRoughnessFactor"}) do
      originalWet[st][f]=source:getField(f,st)
    end
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
    for st=0,count-1 do
      for _,f in ipairs({"clearCoatFactor","clearCoatRoughnessFactor"}) do
        local original=originalWet[st][f]
        local value=tonumber(original) or (f=="clearCoatFactor" and 0 or 0.1)
        local target=f=="clearCoatFactor" and 1 or 0.025
        mat:setField(f,st,w==0 and original or tostring(value+(target-value)*w/10))
      end
    end
    mat:setField("roughnessFactor",3,tostring(0.65-0.45*w/10))
    mat:setField("opacityFactor",3,tostring(s/20))
    mat:flush(); mat:reload()
  end
  function result:damageTone(luminance)
    -- Plain light paint needs darker exposed coating. Police contains both
    -- light and dark texels, so keep its neutral compromise. Setup/reset only.
    local factor = self.part == "" and luminance and luminance >= 0.5 and 0.15 or 0.75
    local value = string.format("%.2f %.2f %.2f 1",factor,factor,factor)
    if mat:getField("baseColorFactor",count) ~= value then
      mat:setField("baseColorFactor",count,value); mat:flush(); mat:reload()
    end
  end
  function result:clear()
    self:clearSoil(); self:appearance(0,1)
    projection:clearBakedTextures(); projection:flushDynamicTextures()
    projection:combineTextures(textureSet)
  end
  local materialName = mat:getName()
  function result:detach()
    -- Disable only our appended stage. Original channels in the clone remain
    -- identical, even if its mesh instance outlives this extension.
    local live = scenetree.findObject(materialName)
    if live then
      for st=0,count-1 do
        for _,f in ipairs({"clearCoatFactor","clearCoatRoughnessFactor"}) do
          live:setField(f,st,originalWet[st][f])
        end
      end
      live:setField("activeLayers",0,tostring(count))
      live:flush(); live:reload()
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
