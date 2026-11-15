"""Warm control with painter unloaded and detector disabled; not a clean ZIP uninstall."""
import json,time,shutil,argparse
from pathlib import Path
from types import SimpleNamespace
import dev,bench
p=argparse.ArgumentParser();p.add_argument('--label',required=True);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
bench.ensure_bench()
try:
 dev.lua('getPlayerVehicle(0):queueLuaCommand([[scratches_detect.setEnabled(false);scratches_detect.setPaintEnabled(false)]]);extensions.unload("scratches_paint");return true');time.sleep(1)
 state=dev.lua('local layers={};for _,name in pairs(getPlayerVehicle(0):getMaterialNames()) do if name:find("scratches_etk800_",1,true) then layers[name]=scenetree.findObject(name):getField("activeLayers",0) end end;return jsonEncode({painterLoaded=scratches_paint~=nil,layers=layers})')
 (out/'state.json').write_text(state)
 assert not json.loads(state)['painterLoaded']
 args=SimpleNamespace(tag=a.label,repeat=3,no_shots=True,shot_scale=.5,optick=False)
 for i in range(3):
  for name in ['sideslide','roofdrop']:
   row=bench.run_one(name,args,[],bench.homes()['gridmap_v2'],i+1)
   shutil.copytree(Path(bench.RUNS_DIR)/row['run'],out/row['run'])
finally:
 dev.lua('extensions.load("scratches_paint");getPlayerVehicle(0):queueLuaCommand([[scratches_detect.setEnabled(true);scratches_detect.setPaintEnabled(true)]]);return true')
