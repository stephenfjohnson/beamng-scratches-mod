"""Live lifecycle boundaries; creates/deletes only its own unicycle fixture."""
import json,time,argparse
from pathlib import Path
import dev,livery_probe
p=argparse.ArgumentParser();p.add_argument('--label',required=True);p.add_argument('--experimental-half',action='store_true');p.add_argument('--experimental-width',type=int,choices=[4096,2048,1024]);p.add_argument('--coalesce',action='store_true');a=p.parse_args();coalesce=a.coalesce or a.experimental_half;width=a.experimental_width or (2048 if a.experimental_half else None)
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False);rows={}
def snap(k):
 if width:dev.lua('if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution('+str(width)+');scratches_paint.setBakeBudget(3);scratches_paint.setFlushInterval(0.05);scratches_paint.setCoverageCoalescing('+str(coalesce).lower()+');scratches_paint.setPanelGrouping(true) end;return true')
 rows[k]=json.loads(dev.lua(livery_probe.LUA));rows[k]['painter']=json.loads(dev.lua('return jsonEncode(scratches_paint.getStats())'));(out/'matrix.json').write_text(json.dumps(rows,indent=2))
original=int(dev.lua('return getPlayerVehicle(0):getId()'));other=None
try:
 snap('start')
 for i in range(5):
  dev.lua('extensions.reload("scratches_paint");return true');time.sleep(2);snap('extensionReload'+str(i))
 dev.lua('core_vehicle_partmgmt.setSkin("heritage");return true');time.sleep(3);snap('unsupportedHeritage')
 dev.lua('core_vehicle_partmgmt.setSkin("police");return true');time.sleep(3);snap('policeReturn')
 dev.lua('core_vehicles.spawnNewVehicle("unicycle",{pos=getPlayerVehicle(0):getPosition()+vec3(5,0,0)});return true');time.sleep(3)
 other=int(dev.lua('return getPlayerVehicle(0):getId()'));assert other!=original,'spawn did not select its new fixture';snap('unicycle')
 dev.lua(f'be:enterVehicle(0,scenetree.findObjectById({original}));return true');time.sleep(2);snap('etkReturn')
finally:
 dev.lua(f'be:enterVehicle(0,scenetree.findObjectById({original}));return true')
 if other and other!=original:dev.lua(f'local v=scenetree.findObjectById({other});if v then v:delete() end;return true')
