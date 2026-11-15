"""Actual spawn/delete material lifetime probe; preserves original player vehicle.
Tracks only scratches_etk800_* materials and references from live vehicle meshes.
"""
import argparse,json,time,hashlib
from pathlib import Path
import dev,livery_probe
p=argparse.ArgumentParser();p.add_argument('--label',required=True);p.add_argument('--cycles',type=int,default=5);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False);rows=[];created=None
(out/'source-sha256.json').write_text(json.dumps({str(f):hashlib.sha256((Path(dev.mount_dir())/f).read_bytes()).hexdigest() for f in Path('lua').rglob('*.lua')},indent=2))
(out/'engine.txt').write_text('\n'.join(l for l in (Path(dev.user_dir())/'beamng.log').read_text(errors='replace').splitlines() if 'Log started' in l or 'Attempting to create GFX' in l))
inventory='''local r={materials={},vehicles={}};for _,id in ipairs(scenetree.findClassObjects("Material")) do local m=scenetree.findObject(id);if m and m:getName():find("scratches_etk800_",1,true)==1 then r.materials[#r.materials+1]={name=m:getName(),id=m:getId(),parent=m:getGroup() and m:getGroup():getName()} end end;for _,v in ipairs(getAllVehicles()) do local names={};for _,name in pairs(v:getMaterialNames()) do if name:find("scratches_etk800_",1,true)==1 then names[#names+1]=name end end;r.vehicles[#r.vehicles+1]={id=v:getId(),materials=names} end;return jsonEncode(r)'''
def snap(phase):
 row=json.loads(dev.lua(inventory));row['phase']=phase;row['playerState']=json.loads(dev.lua(livery_probe.LUA));rows.append(row);(out/'materials.json').write_text(json.dumps(rows,indent=2));print(phase,len(row['materials']),row['playerState']['compatibility'],flush=True)
original=int(dev.lua('return getPlayerVehicle(0):getId()'))
try:
 snap('before')
 for i in range(a.cycles):
  dev.lua('local v=getPlayerVehicle(0);core_vehicles.spawnNewVehicle("etk800",{config=core_vehicle_partmgmt.getConfig(),pos=v:getPosition()+vec3(5,0,0)});return true');time.sleep(3)
  candidate=int(dev.lua('return getPlayerVehicle(0):getId()'));assert candidate!=original;created=candidate;snap('spawn-'+str(i))
  dev.lua('be:enterVehicle(0,scenetree.findObjectById('+str(original)+'));return true');time.sleep(1)
  dev.lua('local v=scenetree.findObjectById('+str(created)+');if v then v:delete() end;return true');created=None;time.sleep(1);snap('delete-'+str(i))
finally:
 dev.lua('be:enterVehicle(0,scenetree.findObjectById('+str(original)+'));return true')
 if created:dev.lua('local v=scenetree.findObjectById('+str(created)+');if v then v:delete() end;return true')
