"""Sequential functional regression of the explicit grouped candidate.
Uses real collision/mud/water fixtures and restores their temporary objects/settings.
Run on Gridmap v2 with the verified ETK; backend is chosen before this command.
"""
import argparse,json,subprocess,sys,time,shutil
from pathlib import Path
from types import SimpleNamespace
import dev,bench,livery_probe
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--label',required=True);p.add_argument('--width',type=int,choices=[4096,2048,1024],default=2048);p.add_argument('--coalesce',action='store_true');a=p.parse_args()
root=Path('docs/evidence/milestone5');out=root/a.label;out.mkdir(parents=True,exist_ok=False)
tune='scratches_paint.setDamageResolution('+str(a.width)+');scratches_paint.setBakeBudget(3);scratches_paint.setFlushInterval(0.05);scratches_paint.setCoverageCoalescing('+str(a.coalesce).lower()+');scratches_paint.setPanelGrouping(true);return true'

def run(script,*args):
 print('FUNCTIONAL',script,*args,flush=True);subprocess.run([sys.executable,'tools/'+script,*args],check=True)
def snapshot(name):
 state=json.loads(dev.lua(livery_probe.LUA));state['painter']=json.loads(dev.lua('return jsonEncode(scratches_paint.getStats())'));(out/(name+'.json')).write_text(json.dumps(state,indent=2));return state
try:
 bench.ensure_bench();snapshot('start')
 (out/'engine.txt').write_text('\n'.join(l for l in (Path(dev.user_dir())/'beamng.log').read_text(errors='replace').splitlines() if 'Log started' in l or 'Attempting to create GFX' in l))
 run('perf_cached_npcs.py','--label',a.label+'-cached-npcs')
 run('perf_stock_configs.py','--label',a.label+'-stock','--experimental-width',str(a.width),*(['--coalesce'] if a.coalesce else []))
 dev.lua(tune);run('perf_lifecycle.py','--label',a.label+'-lifecycle','--cycles','10')
 states=json.loads((root/(a.label+'-lifecycle')/'lifecycle.json').read_text())
 assert all(x['state']['compatibility']['ready'] and not x['state']['comparison']['differences'] and x['stats']['config']['damageWidth']==a.width for x in states)
 dev.lua(tune);run('perf_traffic.py','--label',a.label+'-traffic')
 traffic=json.loads((root/(a.label+'-traffic')/'traffic.json').read_text())
 assert len(traffic['npcStats'])==3 and all(s['impactEvents']==0 and s['streamsFlushed']==0 and s['totalCalls']==0 for s in traffic['npcStats'].values())
 run('perf_matrix.py','--label',a.label+'-matrix','--experimental-width',str(a.width),*(['--coalesce'] if a.coalesce else []))
 dev.lua(tune);run('water_editor_probe.py','--output',str(out/'editor.json'));time.sleep(3)
 run('perf_maps.py','--label',a.label+'-maps','--experimental-width',str(a.width),*(['--coalesce'] if a.coalesce else []))
 dev.lua(tune);run('perf_mod_config.py','--label',a.label+'-mod')
 dev.lua(tune);snapshot('before-wash-fixture')
 args=SimpleNamespace(tag=a.label+'-wash',repeat=1,no_shots=False,shot_scale=.5,optick=False,drain_timeout=15)
 row=bench.run_one('sideslide',args,[],bench.homes()['gridmap_v2'],1)
 wash=root/(a.label+'-wash');shutil.copytree(Path(bench.RUNS_DIR)/row['run'],wash)
 run('damage_soil_fixture.py','--output',str(wash))
 run('water_probe.py','--output',str(wash),'--left','--redirty-x','-313')
 w=json.loads((wash/'water.json').read_text());surface=lambda k:w[k]['state']['surface']
 assert surface('dirty')['deposits']>0 and surface('shallow')['soilRemaining']==1
 assert surface('deep-washed')['deposits']==0 and surface('dry')['wetness']==0
 assert surface('pauseStart')==surface('pauseEnd') and not w['dry']['config']['comparison']['differences']
 assert surface('redirty')['deposits']>0 and w['dry']['state']['stats']['perf']['bakeLayersTotal']==0
 assert w['dry']['state']['stats']['config']['damageWidth']==a.width
 (out/'checks.json').write_text(json.dumps({'lifecycleSnapshots':len(states),'trafficNPCs':len(traffic['npcStats']),'waterStateChecks':True,'renderingRequiresImageReview':True},indent=2))
 snapshot('end')
except Exception as e:
 (out/'error.txt').write_text(str(e));raise
finally:
 dev.lua('simTimeAuthority.pause(false);if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution(4096) end;scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(0.2);scratches_paint.setCoverageCoalescing(false);scratches_paint.setPanelGrouping(false);return true')
