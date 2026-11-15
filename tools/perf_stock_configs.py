"""Exact installed stock ETK configuration checks, without broad adapter expansion."""
import json,time,shutil,argparse
from pathlib import Path
from types import SimpleNamespace
import dev,bench,livery_probe,damage_probe
p=argparse.ArgumentParser();p.add_argument('--label',default='stock-configs');p.add_argument('--experimental-half',action='store_true');p.add_argument('--experimental-width',type=int,choices=[4096,2048,1024]);p.add_argument('--coalesce',action='store_true');a=p.parse_args();coalesce=a.coalesce or a.experimental_half;width=a.experimental_width or (2048 if a.experimental_half else None)
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
tuning=bench.parse_tuning(['paint.setDamageResolution='+str(width),'paint.setBakeBudget=3','paint.setFlushInterval=0.05','paint.setCoverageCoalescing='+str(coalesce).lower(),'paint.setPanelGrouping=true']) if width else []
damage_probe.OUT=out
try:
 for name in ['844_150_A','844_police_A','854_police_A']:
  dev.lua('core_vehicles.replaceVehicle("etk800",{config='+json.dumps('vehicles/etk800/'+name+'.pc')+'});return true');time.sleep(4)
  state=json.loads(dev.lua(livery_probe.LUA));(out/(name+'.json')).write_text(json.dumps(state,indent=2))
  if name=='854_police_A':
   assert state['compatibility']['skipped'] and state['compatibility']['part']=='etk800_skin_polizei'
   continue
  assert state['compatibility']['ready'] and not state['comparison']['differences']
  bench.ensure_bench()
  args=SimpleNamespace(tag=a.label+'-'+name,repeat=1,no_shots=False,shot_scale=.5,optick=False)
  row=bench.run_one('sideslide',args,tuning,bench.homes()['gridmap_v2'],1)
  damage_probe.matched(name)
  for f in (Path(bench.RUNS_DIR)/row['run']).iterdir():shutil.copyfile(f,out/name/f.name)
finally:
 dev.lua('simTimeAuthority.pause(false);core_vehicles.replaceVehicle("etk800",{config="vehicles/etk800/rennspecht_8r_A.pc"});return true');time.sleep(4)
 dev.lua('core_vehicle_partmgmt.setSkin("police");return true');time.sleep(3)
 if width:dev.lua('scratches_paint.setDamageResolution(4096);scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(0.2);scratches_paint.setCoverageCoalescing(false);scratches_paint.setPanelGrouping(false);return true')
