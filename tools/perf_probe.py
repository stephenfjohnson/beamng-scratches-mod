"""Repeated physics performance runs; process-cold does not mean shader-cache-cold.
Example: python tools/perf_probe.py --label d3d12-cold --restart --rounds 3
Disables only paint submission with --disabled (detector/adapter remain loaded).
"""
import argparse, json, subprocess, sys, time, hashlib, shutil
from pathlib import Path
from types import SimpleNamespace
import bench, dev, livery_probe

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--label',required=True)
    p.add_argument('--rounds',type=int,default=3)
    p.add_argument('--restart',action='store_true')
    p.add_argument('--renderer',choices=['d3d12','vk'],default='d3d12')
    p.add_argument('--disabled',action='store_true')
    p.add_argument('--reflections-off',action='store_true')
    p.add_argument('--budget',type=int)
    p.add_argument('--skin',choices=['plain','police'],default='police')
    a=p.parse_args()
    root=Path('docs/evidence/milestone5')/a.label
    root.mkdir(parents=True,exist_ok=False)
    rows=[]
    previous_reflections=None
    try:
        for i in range(a.rounds):
            if a.restart:
                subprocess.run([sys.executable,'tools/dev.py','restart','--game-arg=-gfx','--game-arg='+a.renderer],check=True)
                dev._port_cache=None
            if a.reflections_off:
                if previous_reflections is None:
                    previous_reflections=json.loads(dev.lua('return jsonEncode(settings.getValue("GraphicDynReflectionEnabled"))'))
                dev.lua('settings.setValue("GraphicDynReflectionEnabled",false);return true')
            dev.lua('simTimeAuthority.pause(false);core_vehicle_partmgmt.setSkin('+json.dumps('' if a.skin=='plain' else 'police')+');return true')
            time.sleep(3)
            bench.ensure_bench()
            meta=json.loads(dev.lua(livery_probe.LUA))
            meta['sourceSha256']={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in Path('lua').rglob('*.lua')}
            meta['processCold']=a.restart
            meta['paintingDisabled']=a.disabled
            (root/f'environment-{i+1}.json').write_text(json.dumps(meta,indent=2))
            log=Path(dev.user_dir())/'beamng.log'
            (root/f'engine-{i+1}.txt').write_text('\n'.join(l for l in log.read_text(errors='replace').splitlines() if any(k in l for k in ['Log started','name:NVIDIA','Attempting to create GFX','shader cache','Shader compilation'])))
            sets=['detect.setPaintEnabled='+str(not a.disabled).lower()]
            sets+=['paint.setProjectionBudget='+str(a.budget or 6)]
            args=SimpleNamespace(tag=a.label,repeat=a.rounds,no_shots=True,shot_scale=.5,optick=False)
            for scenario in ['sideslide','roofdrop','baseline']:
                row=bench.run_one(scenario,args,bench.parse_tuning(sets),bench.homes()['gridmap_v2'],i+1)
                folder=Path(bench.RUNS_DIR)/row['run']
                shutil.copytree(folder,root/row['run'])
                result=json.loads((folder/'result.json').read_text())
                row['frame_ms_p99']=bench.pct(result['frames']['frameMs'],99)
                rows.append(row)
                (root/'summary.json').write_text(json.dumps(rows,indent=2))
    finally:
        if previous_reflections is not None:
            dev.lua('settings.setValue("GraphicDynReflectionEnabled",'+str(previous_reflections).lower()+');return true')
        dev.lua('scratches_paint.setProjectionBudget(6);local v=getPlayerVehicle(0);if v then v:queueLuaCommand("if scratches_detect then scratches_detect.setPaintEnabled(true) end") end;return true')
if __name__=='__main__':main()
