"""Deliberate reset during a measured run must be rejected, with pre-reset stats retained.
This is a bench validity test, not a performance acceptance run.
"""
import json,shutil,argparse
from pathlib import Path
from types import SimpleNamespace
import bench,dev
p=argparse.ArgumentParser();p.add_argument('--label',required=True);a=p.parse_args();out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
bench.ensure_bench();triggered=False

def poll(s):
 global triggered
 if not triggered and s.get('phase')=='run' and s.get('t',0)>.7:
  triggered=True;dev.lua('scratches_paint.clearStamps();return true')
args=SimpleNamespace(tag=a.label,repeat=1,no_shots=True,shot_scale=.5,optick=False,drain_timeout=15,on_poll=poll)
try:bench.run_one('baseline',args,[],bench.homes()['gridmap_v2'],1)
except dev.DeployError:pass
runs=list(Path(bench.RUNS_DIR).glob('*_'+a.label));assert len(runs)==1 and triggered
r=json.loads((runs[0]/'result.json').read_text());assert 'cosmetic reset during measured run' in r.get('error','')
assert r['painter']['perf']['frames']>0 and r['painter']['generation']==r['initialGeneration']
shutil.copytree(runs[0],out/runs[0].name)
(out/'guard.json').write_text(json.dumps({'expectedInvalidRun':True,'resetDetected':True,'preResetStatsRetained':True},indent=2))
print('Reset guard rejected measurement and retained pre-reset statistics')
