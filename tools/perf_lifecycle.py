"""Repeated live lifecycle/resource snapshots, restoring the original player.
Run with supported ETK selected: python tools/perf_lifecycle.py --label before
"""
import argparse,json,time,subprocess,hashlib
from pathlib import Path
import dev,livery_probe

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--label',required=True);p.add_argument('--cycles',type=int,default=10);a=p.parse_args()
 out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False);rows=[]
 (out/'source-sha256.json').write_text(json.dumps({str(f):hashlib.sha256((Path(dev.mount_dir())/f).read_bytes()).hexdigest() for f in Path('lua').rglob('*.lua')},indent=2))
 def snap(label):
  row={'label':label,'time':time.time(),'state':json.loads(dev.lua(livery_probe.LUA)), 'stats':json.loads(dev.lua('return jsonEncode(scratches_paint.getStats())'))}
  row['privateBytes']=int(subprocess.check_output(['powershell','-NoProfile','-Command','(Get-Process BeamNG.drive.x64 | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1).PrivateMemorySize64'],text=True))
  rows.append(row);(out/'lifecycle.json').write_text(json.dumps(rows,indent=2));print(label,row['privateBytes'],row['state']['compatibility'],flush=True)
 original=int(dev.lua('return getPlayerVehicle(0):getId()')); second=None
 try:
  snap('start')
  dev.lua('local v=getPlayerVehicle(0);core_vehicles.spawnNewVehicle("etk800",{config=core_vehicle_partmgmt.getConfig(),pos=v:getPosition()+vec3(5,0,0)});return true');time.sleep(4)
  second=int(dev.lua('return getPlayerVehicle(0):getId()'));assert second!=original,'spawn did not select its new fixture'
  for i in range(a.cycles):
   for vid in [original,second]:
    dev.lua(f'be:enterVehicle(0,scenetree.findObjectById({vid}));return true');time.sleep(1);snap(f'switch-{i}-{vid}')
   dev.lua('getPlayerVehicle(0):reload();return true');time.sleep(2);snap(f'reload-{i}')
  dev.lua('collectgarbage("collect");return true');time.sleep(3);snap('after-gc')
 finally:
  dev.lua(f'be:enterVehicle(0,scenetree.findObjectById({original}));return true')
  if second and second!=original:dev.lua(f'local v=scenetree.findObjectById({second});if v then v:delete() end;return true')
if __name__=='__main__':main()
