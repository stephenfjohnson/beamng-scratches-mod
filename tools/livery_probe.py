"""Read-only live livery/material evidence. Does not initialize the decal API.
Usage: python tools/livery_probe.py --output docs/evidence/milestone1/police.json
"""
import argparse
import json
from pathlib import Path
import dev

LUA = r'''
local veh = getPlayerVehicle(0)
local cfg = core_vehicle_partmgmt.getConfig()
local fields = {'baseColorMap','colorPaletteMap','opacityMap','diffuseMapUseUV',
  'metallicMap','metallicFactor','roughnessMap','roughnessFactor',
  'clearCoatMap','clearCoatFactor','clearCoatRoughnessFactor','normalMap',
  'detailNormalMap','detailNormalMapStrength','detailScale'}
local materials = {}
for _, suffix in ipairs({'', '_main', '.skin.police', '.skin.dynamicTextures'}) do
  local name = veh.JBeam .. suffix
  local mat = scenetree.findObject(name)
  if mat then
    local stages = {}
    for i=0,3 do
      local stage = {}
      for _, f in ipairs(fields) do stage[f] = mat:getField(f,i) end
      stages[#stages+1] = stage
    end
    materials[name] = {activeLayers=mat:getField('activeLayers',0),stages=stages}
  end
end
local compat = scratches_paint.getCompatibility()
local comparison
if compat.adapter and compat.material then
  local src = scenetree.findObject(compat.adapter)
  local dst = scenetree.findObject(compat.material)
  local differences = {}
  local count = tonumber(src:getField('activeLayers',0))
  local ignored = {name=true,mapTo=true,persistentId=true,parentGroup=true,
    internalName=true,class=true,className=true,superClass=true,hidden=true,
    locked=true,canSave=true,canSaveDynamicFields=true,activeLayers=true}
  for field in pairs(src:getFields()) do
    if not ignored[field] then
      for st=0,count-1 do
        local a,b=src:getField(field,st),dst:getField(field,st)
        if a~=b then differences[#differences+1]={field=field,stage=st,source=a,clone=b} end
      end
    end
  end
  comparison={originalStages=count,activeStages=dst:getField('activeLayers',0),differences=differences}
end
local graphics = {}
for _, k in ipairs({'GraphicDisplayResolutions','GraphicOverallQuality','GraphicAntialiasType',
  'GraphicLightingQuality','GraphicShaderQuality','GraphicTextureQuality','GraphicDynReflectionEnabled'}) do
  graphics[k] = settings.getValue(k)
end
return jsonEncode({vehicle=veh.JBeam, id=veh:getId(), map=getCurrentLevelIdentifier(),
  config=cfg.partConfigFilename, paints=cfg.paints, graphics=graphics,
  compatibility=compat, comparison=comparison, materials=materials})
'''

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    result = json.loads(dev.lua(LUA))
    dest = Path(args.output)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result['compatibility']))
