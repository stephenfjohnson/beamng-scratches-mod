"""Continuous same-process endurance test. Resets the car, never reloads the painter.
Records every run and process-private memory without forcing collection until end.
"""
import argparse,json,time,subprocess,shutil,hashlib
from pathlib import Path
from types import SimpleNamespace
import dev,bench,livery_probe
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--label',required=True);p.add_argument('--minutes',type=float,default=10);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
bench.ensure_bench()
environment=json.loads(dev.lua(livery_probe.LUA))
(out/'environment.json').write_text(json.dumps(environment,indent=2))
assert environment['compatibility']['ready'] and not environment['comparison']['differences']
(out/'engine.txt').write_text('\n'.join(l for l in (Path(dev.user_dir())/'beamng.log').read_text(errors='replace').splitlines() if 'Log started' in l or 'Attempting to create GFX' in l))
(out/'source-sha256.json').write_text(json.dumps({str(f):hashlib.sha256((Path(dev.mount_dir())/f).read_bytes()).hexdigest() for f in Path('lua').rglob('*.lua')},indent=2))
started=time.monotonic();rows=[]
def memory():
 return int(subprocess.check_output(['powershell','-NoProfile','-Command','(Get-Process BeamNG.drive.x64 | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1).PrivateMemorySize64'],text=True,timeout=30))
def gpu():
 try:return subprocess.check_output(['nvidia-smi','--query-gpu=name,memory.used','--format=csv,noheader'],text=True,timeout=10).strip()
 except (OSError,subprocess.SubprocessError):return None
rows.append({'phase':'start','elapsed':0,'privateBytes':memory(),'deviceMemory':gpu()})
i=0
while time.monotonic()-started<a.minutes*60:
 scenario=['sideslide','roofdrop','sustained'][i%3];i+=1
 args=SimpleNamespace(tag=a.label,repeat=1000,no_shots=True,shot_scale=.5,optick=False,drain_timeout=15)
 row=bench.run_one(scenario,args,[],bench.homes()['gridmap_v2'],i)
 shutil.copytree(Path(bench.RUNS_DIR)/row['run'],out/row['run'])
 rows.append({'phase':scenario,'run':row['run'],'elapsed':time.monotonic()-started,'privateBytes':memory(),'deviceMemory':gpu()})
 (out/'memory.json').write_text(json.dumps(rows,indent=2))
 print('endurance',round(rows[-1]['elapsed']),rows[-1]['privateBytes'],flush=True)
dev.lua('collectgarbage("collect");return true');time.sleep(3)
rows.append({'phase':'after-gc','elapsed':time.monotonic()-started,'privateBytes':memory(),'deviceMemory':gpu()})
(out/'memory.json').write_text(json.dumps(rows,indent=2))
