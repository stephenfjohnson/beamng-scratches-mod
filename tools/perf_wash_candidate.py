"""Guarded genuine scrape -> mud -> water -> drying -> redirty regression."""
import argparse,json,subprocess,sys,shutil
from pathlib import Path
from types import SimpleNamespace
import dev,bench
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--label',required=True);p.add_argument('--width',type=int,default=4096);p.add_argument('--coalesce',action='store_true');p.add_argument('--near-mud',action='store_true',help='scrape beside mud then physically approach it, without transferring the damaged car');a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
try:
 bench.ensure_bench()
 tuning=bench.parse_tuning(['paint.setDamageResolution='+str(a.width),'paint.setBakeBudget=3','paint.setFlushInterval=0.05','paint.setPanelGrouping=true','paint.setCoverageCoalescing='+str(a.coalesce).lower()])
 args=SimpleNamespace(tag=a.label,repeat=1,no_shots=False,shot_scale=.5,optick=False,drain_timeout=15)
 home={'pos':{'x':-300,'y':-390,'z':100.2},'dir':{'x':0,'y':1,'z':0},'up':{'x':0,'y':0,'z':1}} if a.near_mud else bench.homes()['gridmap_v2']
 row=bench.run_one('sideslide',args,tuning,home,1)
 for f in (Path(bench.RUNS_DIR)/row['run']).iterdir():shutil.copyfile(f,out/f.name)
 r=json.loads((out/'result.json').read_text());generation=r['painter']['generation']
 assert r['painter']['stamp']['streamSubstrokesTotal']>0,'initial collision produced no captured scratch stream layers'
 assert int(dev.lua('return scratches_paint.getStats().generation'))==generation,'photo placement reset cosmetics'
 subprocess.run([sys.executable,'tools/damage_soil_fixture.py','--output',str(out),*(['--drive-in'] if a.near_mud else [])],check=True)
 subprocess.run([sys.executable,'tools/water_probe.py','--output',str(out),'--left',*([] if a.near_mud else ['--redirty-x','-313'])],check=True)
 w=json.loads((out/'water.json').read_text());surface=lambda k:w[k]['state']['surface']
 assert all(x['state']['stats']['generation']==generation for x in w.values() if 'state' in x)
 assert surface('dirty')['deposits']>0 and surface('shallow')['soilRemaining']==1
 assert surface('deep-washed')['deposits']==0 and surface('dry')['wetness']==0
 assert surface('pauseStart')==surface('pauseEnd') and not w['dry']['config']['comparison']['differences']
 assert surface('redirty')['deposits']>0 and w['dry']['state']['stats']['perf']['bakeLayersTotal']==0
 assert w['dry']['state']['stats']['config']['damageWidth']==a.width
 (out/'checks.json').write_text(json.dumps({'generationPreserved':generation,'waterStateChecks':True,'requiresImageReview':True,'damagedVehicleTeleport':not a.near_mud},indent=2))
except Exception as e:
 (out/'error.txt').write_text(str(e));raise
finally:
 dev.lua('simTimeAuthority.pause(false);if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution(4096) end;scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(.2);scratches_paint.setPanelGrouping(false);scratches_paint.setCoverageCoalescing(false);return true')
