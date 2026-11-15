"""Repeated real map transitions; leaves Gridmap v2 with Police selected."""
import argparse,json,time
from pathlib import Path
import dev,livery_probe
p=argparse.ArgumentParser();p.add_argument('--label',required=True);p.add_argument('--experimental-half',action='store_true');p.add_argument('--experimental-width',type=int,choices=[4096,2048,1024]);p.add_argument('--coalesce',action='store_true');a=p.parse_args();coalesce=a.coalesce or a.experimental_half;width=a.experimental_width or (2048 if a.experimental_half else None)
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False);rows=[]
for level in ['automation_test_track','gridmap_v2','automation_test_track','gridmap_v2']:
 dev.lua('freeroam_freeroam.startFreeroamByName('+json.dumps(level)+');return true')
 deadline=time.monotonic()+120
 while time.monotonic()<deadline:
  time.sleep(2)
  try:
   ok=dev.lua('return tostring(getCurrentLevelIdentifier()=='+json.dumps(level)+' and getPlayerVehicle(0)~=nil and scratches_paint~=nil)')
   if ok=='true':break
  except (ConnectionError,dev.DeployError):pass
 else:raise RuntimeError('map load timed out: '+level)
 time.sleep(3)
 dev.lua('core_vehicle_partmgmt.setSkin("police");return true');time.sleep(3)
 if width:dev.lua('if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution('+str(width)+');scratches_paint.setBakeBudget(3);scratches_paint.setFlushInterval(0.05);scratches_paint.setCoverageCoalescing('+str(coalesce).lower()+');scratches_paint.setPanelGrouping(true) end;return true')
 row=json.loads(dev.lua(livery_probe.LUA));row['painter']=json.loads(dev.lua('return jsonEncode(scratches_paint.getStats())'));rows.append(row)
 (out/'maps.json').write_text(json.dumps(rows,indent=2));print(level,row['compatibility'],flush=True)
 assert row['compatibility']['ready'] and not row['comparison']['differences']
