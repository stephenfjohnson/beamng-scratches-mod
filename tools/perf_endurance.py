"""Same-process endurance: repeated fixtures or one continuous circular roof scrape.
All contacts are real. A vehicle/cosmetic reset invalidates a measured fixture.
"""
import argparse,json,time,subprocess,shutil,hashlib,ctypes
from pathlib import Path
from types import SimpleNamespace
from ctypes import wintypes
import dev,bench,livery_probe
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--label',required=True);p.add_argument('--minutes',type=float,default=10)
p.add_argument('--width',type=int,default=4096);p.add_argument('--bake',type=int,default=6)
p.add_argument('--flush',type=float,default=.2);p.add_argument('--coalesce',action='store_true');p.add_argument('--group',action='store_true')
p.add_argument('--continuous',action='store_true');p.add_argument('--disabled',action='store_true');a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
bench.ensure_bench()
environment=json.loads(dev.lua(livery_probe.LUA));(out/'environment.json').write_text(json.dumps(environment,indent=2))
assert environment['compatibility']['ready'] and not environment['comparison']['differences']
(out/'engine.txt').write_text('\n'.join(l for l in (Path(dev.user_dir())/'beamng.log').read_text(errors='replace').splitlines() if 'Log started' in l or 'Attempting to create GFX' in l))
(out/'source-sha256.json').write_text(json.dumps({str(f):hashlib.sha256((Path(dev.mount_dir())/f).read_bytes()).hexdigest() for f in (x.relative_to(Path(dev.mount_dir())) for x in (Path(dev.mount_dir())/'lua').rglob('*.lua'))},indent=2))
(out/'settings.json').write_text(json.dumps(vars(a),indent=2))
tuning=bench.parse_tuning(['paint.setDamageResolution='+str(a.width),'paint.setBakeBudget='+str(a.bake),'paint.setFlushInterval='+str(a.flush),'paint.setCoverageCoalescing='+str(a.coalesce).lower(),'paint.setPanelGrouping='+str(a.group).lower()])
if a.disabled:tuning+=bench.parse_tuning(['detect.setPaintEnabled=false'])
# Resolve PID once, outside the measured window. Cheap native reads thereafter.
pid=int(subprocess.check_output(['powershell','-NoProfile','-Command','(Get-Process BeamNG.drive.x64 | Sort-Object PrivateMemorySize64 -Descending | Select-Object -First 1).Id'],text=True))
class Memory(ctypes.Structure):
 _fields_=[('cb',wintypes.DWORD),('PageFaultCount',wintypes.DWORD)]+[(n,ctypes.c_size_t) for n in ['PeakWorkingSetSize','WorkingSetSize','QuotaPeakPagedPoolUsage','QuotaPagedPoolUsage','QuotaPeakNonPagedPoolUsage','QuotaNonPagedPoolUsage','PagefileUsage','PeakPagefileUsage','PrivateUsage']]
k=ctypes.WinDLL('kernel32',use_last_error=True);ps=ctypes.WinDLL('psapi',use_last_error=True)
k.OpenProcess.argtypes=[wintypes.DWORD,wintypes.BOOL,wintypes.DWORD];k.OpenProcess.restype=wintypes.HANDLE;k.CloseHandle.argtypes=[wintypes.HANDLE]
ps.GetProcessMemoryInfo.argtypes=[wintypes.HANDLE,ctypes.POINTER(Memory),wintypes.DWORD]
handle=k.OpenProcess(0x410,False,pid)
if not handle:raise ctypes.WinError(ctypes.get_last_error())
started=time.monotonic();rows=[];last_sample=-10

def sample(phase):
 m=Memory();m.cb=ctypes.sizeof(m)
 if not ps.GetProcessMemoryInfo(handle,ctypes.byref(m),m.cb):raise ctypes.WinError(ctypes.get_last_error())
 rows.append({'phase':phase,'elapsed':time.monotonic()-started,'pid':pid,'privateBytes':m.PrivateUsage,'workingSetBytes':m.WorkingSetSize})
 (out/'memory.json').write_text(json.dumps(rows,indent=2))

def poll(status):
 global last_sample
 if time.monotonic()-started-last_sample>=10:
  sample(status.get('phase'));last_sample=time.monotonic()-started

def archive():
 for run in Path(bench.RUNS_DIR).glob('*_'+a.label+'*'):
  if not (out/run.name).exists():shutil.copytree(run,out/run.name)

def engine_resources(name):
 # Outside measured fixtures: retain the engine API's raw VRAM value, without
 # assuming this is a per-target allocation count or a native leak measurement.
 (out/('engine-resources-'+name+'.json')).write_text(dev.lua('local r={luaKiB=collectgarbage("count"),vramAvailable=Engine.Render and Engine.Render.getVRAMUsage~=nil or false};if r.vramAvailable then local ok,v=pcall(Engine.Render.getVRAMUsage);r.vramCallOK=ok;r.vramRaw=(type(v)=="table" or type(v)=="number") and v or tostring(v) end;return jsonEncode(r)'))
try:
 engine_resources('start')
 sample('start');i=0
 if a.continuous:
  bench.SCENARIOS['circle']=dict(bench.SCENARIOS['sustained'],maxTime=a.minutes*60,circleRadius=25,requireInverted=True,desc='continuous additive roof scrape in a 25 m radius circle; no mid-run reset')
 while time.monotonic()-started<a.minutes*60:
  scenario='circle' if a.continuous else ['sideslide','roofdrop','sustained'][i%3];i+=1
  args=SimpleNamespace(tag=a.label,repeat=1000,no_shots=True,shot_scale=.5,optick=False,drain_timeout=15,on_poll=poll)
  row=bench.run_one(scenario,args,tuning,bench.homes()['gridmap_v2'],i);archive();sample(scenario)
  print('endurance',round(rows[-1]['elapsed']),rows[-1]['privateBytes'],flush=True)
  if a.continuous:break
 (out/'environment-end.json').write_text(dev.lua(livery_probe.LUA))
 dev.lua('collectgarbage("collect");return true');time.sleep(3);sample('after-gc')
 engine_resources('end')
except Exception as e:
 (out/'error.txt').write_text(str(e));archive();raise
finally:
 k.CloseHandle(handle)
 dev.lua('if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution(4096) end;scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(0.2);scratches_paint.setCoverageCoalescing(false);scratches_paint.setPanelGrouping(false);local v=getPlayerVehicle(0);if v then v:queueLuaCommand("if scratches_detect then scratches_detect.setPaintEnabled(true) end") end;return true')
