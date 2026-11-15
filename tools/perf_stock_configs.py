"""Exact installed stock ETK configuration checks, without broad adapter expansion."""
import json,time,shutil
from pathlib import Path
from types import SimpleNamespace
import dev,bench,livery_probe,damage_probe
out=Path('docs/evidence/milestone5/stock-configs');out.mkdir(parents=True,exist_ok=False)
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
  args=SimpleNamespace(tag='m5-stock-'+name,repeat=1,no_shots=False,shot_scale=.5,optick=False)
  row=bench.run_one('sideslide',args,[],bench.homes()['gridmap_v2'],1)
  damage_probe.matched(name)
  for f in (Path(bench.RUNS_DIR)/row['run']).iterdir():shutil.copyfile(f,out/name/f.name)
finally:
 dev.lua('simTimeAuthority.pause(false);core_vehicles.replaceVehicle("etk800",{config="vehicles/etk800/rennspecht_8r_A.pc"});return true');time.sleep(4)
 dev.lua('core_vehicle_partmgmt.setSkin("police");return true')
