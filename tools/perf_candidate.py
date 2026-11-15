"""Sequential controlled quality/bake experiments; fresh evidence labels required."""
import argparse,json,time,shutil,hashlib,subprocess,sys
from pathlib import Path
from types import SimpleNamespace
import dev,bench,livery_probe,damage_probe
p=argparse.ArgumentParser();p.add_argument('--label',required=True);p.add_argument('--width',type=int,default=4096);p.add_argument('--bake',type=int,default=6);p.add_argument('--repeat',type=int,default=3);p.add_argument('--coalesce',action='store_true');p.add_argument('--group',action='store_true');p.add_argument('--flush',type=float,default=.2);p.add_argument('--projects',type=int,default=6);p.add_argument('--layers',type=int,default=24);p.add_argument('--scenarios',nargs='+',default=['sideslide','roofdrop','sustained']);p.add_argument('--capture',action='store_true');p.add_argument('--restart',action='store_true');p.add_argument('--renderer',choices=['d3d12','vk'],default='d3d12');a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
if not a.restart:bench.ensure_bench()
tuning=bench.parse_tuning(['paint.setDamageResolution='+str(a.width),'paint.setBakeBudget='+str(a.bake),'paint.setFlushInterval='+str(a.flush),'paint.setProjectionBudget='+str(a.projects),'paint.setLayerBudget='+str(a.layers)])
if a.coalesce:tuning+=bench.parse_tuning(['paint.setCoverageCoalescing=true'])
if a.group:tuning+=bench.parse_tuning(['paint.setPanelGrouping=true'])
(out/'source-sha256.json').write_text(json.dumps({str(f):hashlib.sha256((Path(dev.mount_dir())/f).read_bytes()).hexdigest() for f in (x.relative_to(Path(dev.mount_dir())) for x in (Path(dev.mount_dir())/'lua').rglob('*.lua'))},indent=2))
if not a.restart:(out/'environment.json').write_text(dev.lua(livery_probe.LUA))
(out/'settings.json').write_text(json.dumps(vars(a),indent=2))
(out/'engine.txt').write_text('\n'.join(l for l in (Path(dev.user_dir())/'beamng.log').read_text(errors='replace').splitlines() if 'Log started' in l or 'Attempting to create GFX' in l))
try:
 for rep in range(1,a.repeat+1):
  if a.restart:
   subprocess.run([sys.executable,'tools/dev.py','restart','--game-arg=-gfx','--game-arg='+a.renderer],check=True)
   dev._port_cache=None
   dev.lua('core_vehicle_partmgmt.setSkin("police");return true');time.sleep(3)
   bench.ensure_bench()
   (out/('environment-'+str(rep)+'.json')).write_text(dev.lua(livery_probe.LUA))
   (out/('engine-'+str(rep)+'.txt')).write_text('\n'.join(l for l in (Path(dev.user_dir())/'beamng.log').read_text(errors='replace').splitlines() if 'Log started' in l or 'Attempting to create GFX' in l))
  for name in a.scenarios:
   args=SimpleNamespace(tag=a.label,repeat=a.repeat,no_shots=not(a.capture and rep==1),shot_scale=.5,optick=False,drain_timeout=15)
   row=bench.run_one(name,args,tuning,bench.homes()['gridmap_v2'],rep)
   shutil.copytree(Path(bench.RUNS_DIR)/row['run'],out/row['run'])
   r=json.loads((out/row['run']/'result.json').read_text());print('CANDIDATE',json.dumps({'run':row['run'],'config':r['painter']['config'],'latency':r['painter'].get('latency'),'perf':r['painter']['perf'],'drops':r['painter']['stamp']}),flush=True)
   if a.capture and rep==1:
    damage_probe.OUT=out;damage_probe.matched(name)
except Exception as e:
 (out/'error.txt').write_text(str(e))
 for run in Path(bench.RUNS_DIR).glob('*_'+a.label+'*'):
  if not (out/run.name).exists():shutil.copytree(run,out/run.name)
 raise
finally:
 try:dev.lua('if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution(4096) end;scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(0.2);scratches_paint.setProjectionBudget(6);scratches_paint.setLayerBudget(24);if scratches_paint.setPanelGrouping then scratches_paint.setPanelGrouping(false) end;if scratches_paint.setCoverageCoalescing then scratches_paint.setCoverageCoalescing(false) end;return true')

 except Exception as restore_error:(out/'restore-error.txt').write_text(str(restore_error))
