"""Live lifecycle boundaries; creates/deletes only its own unicycle fixture."""
import json,time,argparse
from pathlib import Path
import dev,livery_probe
p=argparse.ArgumentParser();p.add_argument('--label',required=True);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False);rows={}
def snap(k):
 rows[k]=json.loads(dev.lua(livery_probe.LUA));(out/'matrix.json').write_text(json.dumps(rows,indent=2))
original=int(dev.lua('return getPlayerVehicle(0):getId()'));other=None
try:
 snap('start')
 for i in range(5):
  dev.lua('extensions.reload("scratches_paint");return true');time.sleep(2);snap('extensionReload'+str(i))
 dev.lua('core_vehicle_partmgmt.setSkin("heritage");return true');time.sleep(3);snap('unsupportedHeritage')
 dev.lua('core_vehicle_partmgmt.setSkin("police");return true');time.sleep(3);snap('policeReturn')
 dev.lua('core_vehicles.spawnNewVehicle("unicycle",{pos=getPlayerVehicle(0):getPosition()+vec3(5,0,0)});return true');time.sleep(3)
 other=int(dev.lua('return getPlayerVehicle(0):getId()'));snap('unicycle')
 dev.lua(f'be:enterVehicle(0,scenetree.findObjectById({original}));return true');time.sleep(2);snap('etkReturn')
finally:
 dev.lua(f'be:enterVehicle(0,scenetree.findObjectById({original}));return true')
 if other:dev.lua(f'local v=scenetree.findObjectById({other});if v then v:delete() end;return true')
