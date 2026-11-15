"""Two identical background ETKs: cached construction must not share active clones."""
import argparse,json,time
from pathlib import Path
import dev,livery_probe
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--label',required=True);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
original=int(dev.lua('return getPlayerVehicle(0):getId()'));created=[];rows=[]
inventory='''local r={};for _,v in ipairs(getAllVehicles()) do local materials={};for _,name in pairs(v:getMaterialNames()) do if name:find("scratches_etk800_",1,true)==1 then local m=scenetree.findObject(name);materials[#materials+1]={name=name,layers=m and m:getField("activeLayers",0)} end end;r[#r+1]={id=v:getId(),materials=materials} end;return jsonEncode(r)'''
def snap(phase):
 row={'phase':phase,'vehicles':json.loads(dev.lua(inventory)),'player':json.loads(dev.lua(livery_probe.LUA))};rows.append(row);(out/'npcs.json').write_text(json.dumps(rows,indent=2));return row
try:
 snap('before')
 for i in range(2):
  before={v['id'] for v in json.loads(dev.lua(inventory))}
  dev.lua('local v=getPlayerVehicle(0);core_vehicles.spawnNewVehicle("etk800",{autoEnterVehicle=false,config=core_vehicle_partmgmt.getConfig(),pos=v:getPosition()+vec3('+str(20+5*i)+',0,0)});return true');time.sleep(4)
  new={v['id'] for v in json.loads(dev.lua(inventory))}-before;created.extend(new);assert len(new)==1
  assert int(dev.lua('return getPlayerVehicle(0):getId()'))==original
  snap('background-'+str(i))
 dev.lua('be:enterVehicle(0,scenetree.findObjectById('+str(created[0])+'));return true');time.sleep(3)
 row=snap('enter-first')
 checks=[]
 for v in row['vehicles']:
  if v['id'] not in created+[original]:continue
  checks.append(bool(v['materials']) and all(m['name'].startswith('scratches_etk800_'+str(v['id'])+'_') and int(m['layers'])==(4 if v['id']==created[0] else 2) for m in v['materials']))
 (out/'checks.json').write_text(json.dumps({'allPrivateAndOnlyPlayerActive':all(checks),'vehiclesChecked':len(checks)},indent=2))
 assert all(checks),'cached background vehicle shares an active private material; retained evidence'
finally:
 dev.lua('be:enterVehicle(0,scenetree.findObjectById('+str(original)+'));return true');time.sleep(1)
 for vid in created:dev.lua('local v=scenetree.findObjectById('+str(vid)+');if v then v:delete() end;return true')
