-- Material preservation/lifecycle checks using the real adapter module.
local n=0
local function check(ok,msg) assert(ok,msg); n=n+1 end
local objects={}
local function material(name)
  local m={name=name or '',data={}}
  function m:getName() return self.name end
  function m:getFields() local t={};for f in pairs(self.data) do t[f]={} end;return t end
  function m:getField(f,s) return self.data[f] and self.data[f][s] or '' end
  function m:setField(f,s,v) self.data[f]=self.data[f] or {}; self.data[f][s]=v end
  function m:registerObject(v) self.name=v;objects[v]=self end
  function m:flush() end
  function m:reload() end
  return m
end
for _,name in ipairs({'etk800_main','etk800.skin.police'}) do
  local m=material(name);objects[name]=m
  m:setField('activeLayers',0,'2');m:setField('version',0,'1.5')
  m:setField('baseColorMap',1,'vehicles/etk800/etk800_skin_police_b.color.png')
  for _,f in ipairs({'metallicFactor','roughnessFactor','normalMap','colorPaletteMap','detailNormalMap','clearCoatRoughnessFactor'}) do
    m:setField(f,0,f..'0');m:setField(f,1,f..'1')
  end
end
local identity={}
for _,f in ipairs({'copy','setPosition','inverse'}) do identity[f]=function(self) return self end end
local veh={JBeam='etk800'}
function veh:getId() return 42 end
function veh:getRefNodeMatrix() return identity end
function veh:getDecalProjectionShape() return {} end
function veh:setTextureSet() end
function veh:getMaterialNames() return {'scratches_etk800_42_police','scratches_etk800_42_plain'} end
createObject=function() return material() end
scenetree={findObject=function(name) return objects[name] end,findObjectById=function() return veh end}
vec3=function() return {} end
editor={active=false}
DecalShapeRenderApp=nil
local realDofile=dofile
local clears=0
local function engineAPI()
  local decalProjection={}
  function decalProjection:clearBakedTextures() clears=clears+1 end
  for _,f in ipairs({'flushDynamicTextures','combineTextures','setShape','setWorldTransform','setTransform'}) do decalProjection[f]=function() end end
  local app={textureSet={}}
  local api={}
  api.bakeLayers=function() return decalProjection end
  api.onUpdate_=function() return app end
  api.setup=function() api.updateVehicleMaterials() end
  api.updateVehicleMaterials=function() error('unsafe heuristic called') end
  api.getShapeMaterialNames=function() return {[5]='etk800',[7]='scratches_etk800_42_police',[8]='scratches_etk800_42_plain'} end
  api.setMaterialIdx=function(i) api.index=i end
  api.addMaterialIdx=function() end
  return api
end
dofile=function(path)
  if path:find('editor/api/dynamicDecals') then return engineAPI() end
  return realDofile(path)
end
Point2I=function() return {} end
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
local adapter=realDofile('lua/ge/extensions/scratches/etkAdapter.lua')
local cfg={partsTree={id='paint_design',chosenPartName='etk800_skin_police'}}
local data={model='etk800',flexbodies={{materialOverride={{'wheel','custom-wheel'}}},{}}}
adapter.prepare(nil,42,data,nil,cfg)
check(cfg.partsTree.chosenPartName=='etk800_skin_police','configured livery untouched')
check(data.flexbodies[1].materialOverride[1][2]=='custom-wheel','unrelated override retained')
local a=adapter.create(veh,'etk800_skin_police')
check(a.api.index==7,'bind exact clone index, not base material')
check(a.material:getField('activeLayers',0)=='4','separate damage and soil stages enabled')
check(a.material:getField('baseColorFactor',2)=='0.75 0.75 0.75 1','damage diffuse muted independently of coverage')
check(a.material:getField('baseColorFactor',3)=='1 1 1 1','soil retains original color response')
check(a.material:getField('opacityMap',2)=='@DynamicTextureBaseColor','damage uses proven empty-transparent color mask')
for _,f in ipairs({'metallicFactor','roughnessFactor','normalMap','colorPaletteMap','detailNormalMap','clearCoatRoughnessFactor'}) do
  check(a.material:getField(f,0)==a.source:getField(f,0) and a.material:getField(f,1)==a.source:getField(f,1),'preserve '..f)
end
local beforeSoil=clears
a:clearSoil();check(clears==beforeSoil+1,'washing clears soil target only')
a:damageTone(0.9)
check(a.material:getField('baseColorFactor',2)=='0.75 0.75 0.75 1','Police mixed paint keeps neutral damage factor')
local original=a.source:getField('clearCoatFactor',0)
a:appearance(1,0.5)
check(a.material:getField('opacityFactor',3)=='0.5','washing fades only soil stage')
check(a.material:getField('opacityFactor',2)=='1','damage opacity unchanged')
check(a.source:getField('clearCoatFactor',0)==original,'wetness never writes shared source')
a:appearance(0,1)
check(a.material:getField('clearCoatFactor',0)==original,'drying restores exact original string')
a:appearance(1,0.25);a:detach()
check(a.material:getField('clearCoatFactor',0)==original,'detach restores wet clone')
local before=clears;a:clear();check(clears==before+2,'clear both private projections')
a:detach();check(a.material:getField('activeLayers',0)=='2','detach original stages only')
check(a.source:getField('activeLayers',0)=='2','source material never modified')
local reload=realDofile('lua/ge/extensions/scratches/etkAdapter.lua')
local adopted=reload.create(veh,'etk800_skin_police')
check(adopted.material==a.material,'reload adopts private clone')
reload.disableAll();check(a.material:getField('activeLayers',0)=='2','unload restores original rendering')
editor.active=true
check(not pcall(adapter.create,veh,'etk800_skin_police'),'editor ownership blocks setup')
editor.active=false
local conflict={model='etk800',flexbodies={{materialOverride={{'etk800','user-body'}}}}}
adapter.prepare(nil,42,conflict,nil,cfg)
check(not pcall(adapter.create,veh,'etk800_skin_police'),'conflicting body override rejected')
check(conflict.flexbodies[1].materialOverride[1][2]=='user-body','conflicting override not changed')
cfg.partsTree.chosenPartName=''
local plain={model='etk800',flexbodies={{}}};adapter.prepare(nil,42,plain,nil,cfg)
local p=adapter.create(veh,'')
check(p.sourceName=='etk800_main','plain uses current PBR material, not legacy etk800')
check(p.api.index==8,'plain clone projected')
p:damageTone(0.75)
check(p.material:getField('baseColorFactor',2)=='0.15 0.15 0.15 1','light plain paint uses dark coating response')
check(p.material:getField('baseColorFactor',3)=='1 1 1 1','adaptive damage tone leaves soil alone')
p:damageTone(0.025)
check(p.material:getField('baseColorFactor',2)=='0.75 0.75 0.75 1','dark plain paint restores neutral response')
check(soilAllocations==2,'one soil projection per adapter module, reused on switch')
-- Simulate map teardown: stale userdata must never be called.
objects[p.material:getName()]=nil
p.material.setField=function() error('deleted material called') end
check(pcall(function() p:detach() end),'detach tolerates deleted scene material')
check(pcall(adapter.disableAll),'unload tolerates deleted scene material')
dofile=realDofile
return n
