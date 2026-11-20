-- Material preservation/lifecycle checks using the real generic body adapter.
local n=0
local function check(ok,msg) assert(ok,msg); n=n+1 end
local objects={}
local function material(name,mapTo,file,layers,version)
  local m={name=name or '',data={},file=file or ''}
  function m:getName() return self.name end
  function m:getFilename() return self.file end
  function m:getFields() local t={};for f in pairs(self.data) do t[f]={} end;return t end
  function m:getField(f,s) return self.data[f] and self.data[f][s] or '' end
  function m:setField(f,s,v) self.data[f]=self.data[f] or {}; self.data[f][s]=v end
  function m:registerObject(v) self.name=v;objects[v]=self end
  function m:flush() end
  function m:reload() end
  function m:delete() objects[self.name]=nil end
  if name then
    objects[name]=m
    m:setField('mapTo',0,mapTo or name)
    m:setField('activeLayers',0,tostring(layers or 2));m:setField('version',0,version or '1.5')
    for _,f in ipairs({'metallicFactor','roughnessFactor','normalMap','colorPaletteMap','detailNormalMap','clearCoatRoughnessFactor'}) do
      m:setField(f,0,name..f..'0');m:setField(f,1,name..f..'1')
    end
  end
  return m
end
local COMMON='/vehicles/common/etk/etk.materials.json'
local DT='/vehicles/etk800/dynamicDecals/main.materials.json'
material('etk800_main','etk800',COMMON)
material('etk800.skin.police','etk800.skin.police','/vehicles/etk800/skins.materials.json')
material('etk800_extra','etk800_extra','/vehicles/etk800/extra/etk800_extra.materials.json')
material('etk800_extra.skin.police','etk800_extra.skin.police','/vehicles/etk800/skins.materials.json')
material('etk800.skin.rennspecht','etk800.skin.rennspecht','/vehicles/etk800/skins.materials.json')
material('etk800.skin.dynamicTextures','etk800.skin.dynamicTextures',DT)
material('etk800_extra.skin.dynamicTextures','etk800_extra.skin.dynamicTextures',DT)
-- Name trap: an object NAMED etk800 is a legacy material mapped elsewhere.
material('etk800','etk800_old',COMMON,1,'1')
-- Another vehicle's paintable body must not leak into the ETK's body keys.
material('pessima.skin.dynamicTextures','pessima.skin.dynamicTextures','/vehicles/pessima/dynamicDecals/main.materials.json')
-- A non-body ETK material with no Dynamic Textures variant.
material('etk800_glass','etk800_glass','/vehicles/etk800/etk800.materials.json')

local identity={}
for _,f in ipairs({'copy','setPosition','inverse'}) do identity[f]=function(self) return self end end
local function vehicle(jbeam,id,names)
  local v={JBeam=jbeam}
  function v:getId() return id end
  function v:getRefNodeMatrix() return identity end
  function v:getDecalProjectionShape() return {} end
  function v:setTextureSet() end
  function v:getMaterialNames() return names end
  return v
end
local veh=vehicle('etk800',42,{'etk800_glass','scratches_42_etk800','scratches_42_etk800_extra'})
createObject=function() return material() end
scenetree={findObject=function(name) return objects[name] end,findObjectById=function() return veh end,
  findClassObjects=function() local names={};for name in pairs(objects) do names[#names+1]=name end;table.sort(names);return names end}
FS={directoryExists=function(_,path) return path=='/vehicles/etk800/dynamicDecals' or path=='/vehicles/vivace/dynamicDecals' end}
vec3=function() return {} end
editor={active=false}
DecalShapeRenderApp=nil
local realDofile=dofile
local clears=0
local damageAllocations=0
local shapeNames={[5]='etk800_glass',[7]='scratches_42_etk800',[9]='scratches_42_etk800_extra',[11]='scratches_77_vivace'}
local function engineAPI()
  damageAllocations=damageAllocations+1
  local decalProjection={}
  function decalProjection:clearBakedTextures() clears=clears+1 end
  for _,f in ipairs({'flushDynamicTextures','combineTextures','setShape','setWorldTransform','setTransform'}) do decalProjection[f]=function() end end
  local app={textureSet={}}
  local api={}
  api.bakeLayers=function() return decalProjection end
  api.onUpdate_=function() return app end
  local width=4096
  api.getTextureResolution=function() return {x=width,y=width/2} end
  api.setTextureResolution=function(r) width=r.x end
  api.setup=function() api.updateVehicleMaterials() end
  api.updateVehicleMaterials=function() error('unsafe heuristic called') end
  api.getShapeMaterialNames=function() return shapeNames end
  api.setMaterialIdx=function(i) api.index=i end
  api.addMaterialIdx=function() end
  api.clearMaterialIdx=function() api.index=nil end
  return api
end
dofile=function(path)
  if path:find('editor/api/dynamicDecals') then return engineAPI() end
  return realDofile(path)
end
Point2I=function(x,y) return {x=x,y=y} end
local soilAllocations=0
DecalProjection=function()
  soilAllocations=soilAllocations+1
  local p={}
  for _,f in ipairs({'flushDynamicTextures','combineTextures','setShape','setWorldTransform','setTransform','bakeLayers','clearMaterialIdx','setMaterialIdx','addMaterialIdx'}) do p[f]=function() end end
  local hasShape=false
  p.setShape=function() hasShape=true end
  p.setMaterialIdx=function() assert(hasShape,'native API needs shape before material selection') end
  p.getTextureSet=function() return {} end
  p.clearBakedTextures=function() clears=clears+1 end
  return p
end
local ADAPTER='lua/ge/extensions/scratches/bodyAdapter.lua'
local adapter=realDofile(ADAPTER)
local etkParts={etk800_skin_police={skinName='police'},etk800_skin_rennspecht={globalSkin='rennspecht'}}
local function etkData(over)
  return {model='etk800',vehicleDirectory='/vehicles/etk800/',activePartsData=etkParts,flexbodies=over or {{materialOverride={{'wheel','custom-wheel'}}},{}}}
end

-- Body keys come from this vehicle's own Dynamic Textures materials only.
local keys=adapter.bodyKeys((function()
  local idx={}
  for name,m in pairs(objects) do local k=m:getField('mapTo',0); idx[k]=idx[k] or {}; table.insert(idx[k],m) end
  return idx end)(),'/vehicles/etk800/')
check(#keys==2 and keys[1]=='etk800' and keys[2]=='etk800_extra','body keys: exactly the ETK main + extra, not glass or another vehicle')

local cfg={partsTree={id='paint_design',chosenPartName='etk800_skin_police'}}
local data=etkData()
adapter.prepare(nil,42,data,nil,cfg)
check(cfg.partsTree.chosenPartName=='etk800_skin_police','configured livery untouched')
check(data.flexbodies[1].materialOverride[1][2]=='custom-wheel','unrelated override retained')
check(data.flexbodies[1].materialOverride[2][1]=='etk800' and data.flexbodies[1].materialOverride[2][2]=='scratches_42_etk800','main body key overridden with its clone')
check(data.flexbodies[1].materialOverride[3][1]=='etk800_extra','extra body material receives its own override')
local a=adapter.create(veh,'etk800_skin_police')
check(a.api.index==7,'bind exact clone index, not base material')
check(#a.indices==2 and a.indices[2]==9,'projection includes the separate rear-quarter material')
check(a.sourceName=='etk800.skin.police','Police main body clones the skin variant')
check(a.materials[2].sourceName=='etk800_extra.skin.police','rear quarter retains its correct stock Police material')
for _,entry in ipairs(a.materials) do
  for field in pairs(entry.source:getFields()) do
    if field~='activeLayers' and field~='mapTo' then
      for stage=0,1 do check(entry.material:getField(field,stage)==entry.source:getField(field,stage),'both body materials preserve stock stage '..stage..' '..field) end
    end
  end
end
check(a.material:getField('activeLayers',0)=='4','separate damage and soil stages enabled')
check(a.material:getField('baseColorFactor',2)=='0.62 0.62 0.63 1','damage stage shows exposed material at mid grey')
check(a.material:getField('opacityFactor',2)=='1','damage opacity equals canvas coverage (no overshoot)')
check(a.material:getField('metallicMap',2)=='@DynamicTextureMetallic' and a.material:getField('roughnessMap',2)=='@DynamicTextureRoughness','damage stage reads per-pixel metal and roughness from the decals')
check(a.material:getField('metallicMap',3)=='' and a.material:getField('roughnessMap',3)=='' and a.material:getField('opacityDetailMap',3)=='','soil stage does not inherit the damage metal, roughness or break-up maps')
check(a.material:getField('opacityDetailMap',2)=='/art/dynamicDecals/textures/w2_grit_o.data.png','damage stage breaks up with static detail')
check(a.material:getField('baseColorFactor',3)=='1 1 1 1','soil retains original color response')
check(a.material:getField('detailNormalMap',3)=='/art/dynamicDecals/textures/soil_relief_detail.normal.png','soil uses static detail relief')
check(a.material:getField('normalMap',3)==a.source:getField('normalMap',0),'soil relief retains factory body normals')
check(a.material:getField('detailNormalMap',2)=='/art/dynamicDecals/textures/w2_grit.normal.png','soil relief does not affect damage stage')
check(a.material:getField('opacityMap',2)=='@DynamicTextureBaseColor','damage uses proven empty-transparent color mask')
for _,f in ipairs({'metallicFactor','roughnessFactor','normalMap','colorPaletteMap','detailNormalMap','clearCoatRoughnessFactor'}) do
  check(a.material:getField(f,0)==a.source:getField(f,0) and a.material:getField(f,1)==a.source:getField(f,1),'preserve '..f)
end
local beforeSoil=clears
a:clearSoil();check(clears==beforeSoil+1,'washing clears soil target only')
a:damageTone(0.9)
check(a.material:getField('baseColorFactor',2)=='0.62 0.62 0.63 1','livery mixed paint keeps the mid-grey damage tone')
local original=a.source:getField('clearCoatFactor',0)
a:appearance(1,0.5)
check(a.material:getField('opacityFactor',3)=='0.5','washing fades only soil stage')
check(a.materials[2].material:getField('opacityFactor',3)=='0.5','washing fades rear quarter soil too')
check(a.material:getField('opacityFactor',2)=='1','washing leaves damage opacity alone')
check(a.source:getField('clearCoatFactor',0)==original,'wetness never writes shared source')
a:appearance(0,1)
-- Soil opacity is the soil canvas red channel, so soil is baked at full red
-- and its brightness is carried by the soil stage's colour factor.
check(a:soilTone(0.43)==0.45 and a.material:getField('baseColorFactor',3)=='0.45 0.45 0.45 1'
  and a.materials[2].material:getField('baseColorFactor',3)=='0.45 0.45 0.45 1','soil tone is carried by the soil stage factor on every body material')
check(a.material:getField('baseColorFactor',2)~='0.45 0.45 0.45 1','soil tone leaves the damage stage alone')
check(a:soilTone(1)==1 and a.material:getField('baseColorFactor',3)=='1.00 1.00 1.00 1','soil tone returns to full for snow')
check(a.material:getField('clearCoatFactor',0)==original,'drying restores exact original string')
a:appearance(1,0.25);a:detach()
check(a.material:getField('clearCoatFactor',0)==original,'detach restores wet clone')
local before=clears;a:clear();check(clears==before+2,'clear both private projections')
a:detach();check(a.material:getField('activeLayers',0)=='2','detach original stages only')
check(a.materials[2].material:getField('activeLayers',0)=='2','detach disables rear quarter overlays too')
check(a.source:getField('activeLayers',0)=='2','source material never modified')
local reload=realDofile(ADAPTER)
core_vehicle_manager={getVehicleData=function() return {vdata={activePartsData=etkParts}} end}
local adopted=reload.create(veh,'etk800_skin_police')
check(adopted.material==a.material and adopted.sourceName=='etk800.skin.police','reload adopts private clone with the same livery source')
reload.disableAll();check(a.material:getField('activeLayers',0)=='2','unload restores original rendering')
editor.active=true
check(not pcall(adapter.create,veh,'etk800_skin_police'),'editor ownership blocks setup')
editor.active=false
local conflict=etkData({{materialOverride={{'etk800','user-body'}}}})
adapter.prepare(nil,42,conflict,nil,cfg)
check(not pcall(adapter.create,veh,'etk800_skin_police'),'conflicting body override rejected')
check(not adapter.wants(veh,'etk800_skin_police'),'rejected vehicle falls back instead of adapting')
check(conflict.flexbodies[1].materialOverride[1][2]=='user-body','conflicting override not changed')
local extraConflict=etkData({{materialOverride={{'etk800_extra','user-quarter'}}}})
adapter.prepare(nil,42,extraConflict,nil,cfg)
check(not pcall(adapter.create,veh,'etk800_skin_police'),'custom rear-quarter override also rejected')

-- Any livery with a skin variant is preserved, not just Police.
cfg.partsTree.chosenPartName='etk800_skin_rennspecht'
local renn=etkData();adapter.prepare(nil,42,renn,nil,cfg)
check(adapter.wants(veh,'etk800_skin_rennspecht'),'default Rennspecht livery is now eligible')
local r=adapter.create(veh,'etk800_skin_rennspecht')
check(r.sourceName=='etk800.skin.rennspecht','Rennspecht clones its own livery material')
check(r.materials[2].sourceName=='etk800_extra','missing livery variant falls back to the base material like the renderer')
check(r.material:getField('colorPaletteMap',0)==objects['etk800.skin.rennspecht']:getField('colorPaletteMap',0),'livery artwork stages copied unchanged')
-- The player's own Dynamic Textures design is editor artwork: never adopted.
check(not adapter.wants(veh,'etk800_skin_dynamicTextures'),'editor Dynamic Textures design not adopted')
cfg.partsTree.chosenPartName='etk800_skin_dynamicTextures'
local dtd=etkData();adapter.prepare(nil,42,dtd,nil,cfg)
check(dtd.flexbodies[2].materialOverride==nil,'editor design gets no override')

cfg.partsTree.chosenPartName=''
local plain=etkData({{}});adapter.prepare(nil,42,plain,nil,cfg)
local p=adapter.create(veh,'')
check(p.sourceName=='etk800_main','plain resolves through mapTo to current PBR etk800_main, not the legacy object named etk800')
check(p.api.index==7,'plain clone projected')
p:damageTone(0.75)
check(p.material:getField('baseColorFactor',2)=='0.46 0.46 0.47 1','light plain paint uses a darker exposed tone')
check(p.material:getField('baseColorFactor',3)=='1 1 1 1','adaptive damage tone leaves soil alone')
p:damageTone(0.025)
check(p.material:getField('baseColorFactor',2)=='0.62 0.62 0.63 1','dark plain paint restores the mid-grey tone')
check(damageAllocations==2,'one damage projection per adapter module, reused on switch')
check(p.api==a.api,'same private API across supported attachments')
check(soilAllocations==2,'one soil projection per adapter module, reused on switch')
p:setDamageWidth(2048)
check(p:getDamageWidth()==2048,'explicit half-resolution private quality setting')
check(p.source:getField('activeLayers',0)=='2','quality never changes original source')
check(soilAllocations==2 and damageAllocations==2,'quality reuses private projections without soil allocation')
check(not pcall(function() p:setDamageWidth(1536) end),'unsupported resolution is rejected')
p:setDamageWidth(4096)

-- A different vehicle with a single-stage body material and a livery.
local VDT='/vehicles/vivace/dynamicDecals/main.materials.json'
material('vivace_body','vivace','/vehicles/vivace/vivace.materials.json',1)
material('vivace.skin.rally','vivace.skin.rally','/vehicles/vivace/skins.materials.json',1)
material('vivace.skin.dynamicTextures','vivace.skin.dynamicTextures',VDT)
local viv=vehicle('vivace',77,{'scratches_77_vivace'})
local vcfg={partsTree={id='paint_design',chosenPartName='vivace_skin_rally'}}
local vdata={model='vivace',vehicleDirectory='/vehicles/vivace/',activePartsData={vivace_skin_rally={skinName='rally'}},flexbodies={{}}}
adapter.prepare(nil,77,vdata,nil,vcfg)
check(vdata.flexbodies[1].materialOverride[1][2]=='scratches_77_vivace','second vehicle model gets its own clone override')
local v=adapter.create(viv,'vivace_skin_rally')
check(v.sourceName=='vivace.skin.rally' and v.stage==1 and v.soilStage==2,'one-stage livery gets damage at stage 1 and soil at stage 2')
check(v.material:getField('activeLayers',0)=='3','one-stage body enables exactly two extra stages')
check(v.material:getField('baseColorMap',1)=='@DynamicTextureBaseColor' and v.material:getField('baseColorMap',2)=='@ScratchesSoilBaseColor','damage then soil stage bound')
v:appearance(0,0.5);check(v.material:getField('opacityFactor',2)=='0.5','soil fade follows the shifted soil stage')
-- Full or non-PBR materials fail closed and leave the car untouched.
objects['vivace.skin.rally']:setField('activeLayers',0,'3')
local full={model='vivace',vehicleDirectory='/vehicles/vivace/',activePartsData=vdata.activePartsData,flexbodies={{}}}
adapter.prepare(nil,77,full,nil,vcfg)
check(full.flexbodies[1].materialOverride==nil and not adapter.wants(viv,'vivace_skin_rally'),'three-stage material rejected without overrides')
objects['vivace.skin.rally']:setField('activeLayers',0,'1');objects['vivace.skin.rally']:setField('version',0,'1')
local old={model='vivace',vehicleDirectory='/vehicles/vivace/',activePartsData=vdata.activePartsData,flexbodies={{}}}
adapter.prepare(nil,77,old,nil,vcfg)
check(old.flexbodies[1].materialOverride==nil,'non-PBR material rejected')
check(not adapter.wants(vehicle('pickup',5,{}),''),'vehicle without Dynamic Textures materials is not adapted')
-- A design part with no skin name (overlay-mesh livery) keeps the base body material.
objects['vivace.skin.rally']:setField('version',0,'1.5')
local overlay={model='vivace',vehicleDirectory='/vehicles/vivace/',activePartsData={vivace_skin_decals={partName='vivace_skin_decals'}},flexbodies={{}}}
adapter.prepare(nil,77,overlay,nil,{partsTree={id='paint_design',chosenPartName='vivace_skin_decals'}})
check(overlay.flexbodies[1].materialOverride and overlay.flexbodies[1].materialOverride[1][2]=='scratches_77_vivace','overlay livery without skin name is adapted on its base material')

-- Simulate map teardown: stale userdata must never be called.
objects[p.material:getName()]=nil
p.material.setField=function() error('deleted material called') end
check(pcall(function() p:detach() end),'detach tolerates deleted scene material')
check(pcall(adapter.disableAll),'unload tolerates deleted scene material')
dofile=realDofile
local realRequire=require
local invalidations=0
require=function(name)
  assert(name=='jbeam/loader')
  return {onFileChanged=function() invalidations=invalidations+1 end}
end
adapter.invalidateConstructionCache()
check(invalidations==1,'construction retry invalidates cached per-vehicle overrides')
editor.active=true
check(not pcall(adapter.invalidateConstructionCache) and invalidations==1,'editor ownership prevents cache invalidation')
editor.active=false
require=realRequire
local orphan=material();orphan:registerObject('scratches_99_etk800')
orphan:setField('scratchesOwner',0,'bodyAdapter-v2')
local legacyOrphan=material();legacyOrphan:registerObject('scratches_etk800_98_plain')
legacyOrphan:setField('scratchesOwner',0,'etkAdapter-v1')
getAllVehicles=function() return {veh} end
cfg.partsTree.chosenPartName=''
veh.getMaterialNames=function() return {'scratches_42_etk800'} end
check(adapter.create(veh,'')==nil,'main-only construction cannot silently omit rear-quarter binding')
veh.getMaterialNames=function() return {'scratches_99_etk800'} end
check(adapter.create(veh,'')==nil,'prepared state cannot bind a foreign cached clone after reload')
adapter.collectUnusedMaterials()
check(objects['scratches_99_etk800']~=nil,'cached clone referenced by another live mesh is retained')
veh.getMaterialNames=function() return {'scratches_42_etk800','scratches_42_etk800_extra'} end
editor.active=true
check(not adapter.collectUnusedMaterials() and objects['scratches_99_etk800']~=nil,'editor defers orphan material cleanup')
editor.active=false
adapter.collectUnusedMaterials()
check(objects['scratches_99_etk800']==nil and objects['etk800_main']~=nil,'unreferenced owned orphan removed without deleting source materials')
check(objects['scratches_etk800_98_plain']==nil,'clones from the previous ETK-only adapter are also cleaned up')
check(objects['scratches_42_etk800_extra']~=nil,'live vehicle clone retained')
FS=nil;core_vehicle_manager=nil
return n
