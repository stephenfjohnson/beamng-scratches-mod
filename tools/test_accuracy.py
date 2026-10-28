"""Repeatable accuracy checks: python tools/test_accuracy.py [--ingame] [--physics].

The headless suite always runs. --ingame replaces the player car with a fixed
pickup configuration on Gridmap v2 and compares frozen clean/painted PNGs.
--physics additionally runs the five crash scenarios from a fresh configuration.
Artifacts and exact inputs are saved under bench/accuracy/. Exit 1 on failure.
Requires Pillow and numpy for rendered image comparisons, plus BeamNG MCP.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time
from types import SimpleNamespace

import dev
import bench

ROOT = Path(dev.ROOT)
CONFIG = "vehicles/pickup/d15_4wd_A.pc"
SEED = 1977
EXPOSURE_EV = 10.3  # Sunny Gridmap: retain paint detail instead of clipping highlights


def fixture_passes(noise, checks, stats, errors=()):
    return (all(n['changed'] <= 10 for n in noise.values())
            and checks['target']['changed'] >= 25 and checks['target']['fraction'] < 0.05
            and all(c['changed'] <= 10 for v,c in checks.items() if v != 'target')
            and stats['perf']['bakeLayersTotal'] > 0
            and not stats['stamp'].get('bakesFailed',0)
            and not stats['stamp']['jobsFailed'] and not errors)


def relevant_errors(lines):
    return [line for line in lines if '|E|' in line
            and any(word in line.lower() for word in ('scratches','dynamicdecal','bakelayers'))]


def lua_json(code):
    return json.loads(dev.lua(code))


def wait_for(code, timeout=20):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if dev.lua(code) == "true":
            return
        time.sleep(0.1)
    raise RuntimeError("Timed out waiting for " + code)


def drain():
    wait_for("local s=scratches_paint.getStats() return tostring(s.ready and s.queue.bake==0 and s.queue.jobs==0 and s.queue.stamps==0)")
    # One extra render after the last bake/composite.
    time.sleep(0.3)


def prepare():
    dev.lua("simTimeAuthority.pause(false) core_vehicles.replaceVehicle('pickup', "
            "{config='" + CONFIG + "',pos=vec3(62.0871,20.8285,100.5),rot=quat(0,0,0,1)})")
    time.sleep(2)
    wait_for("return tostring(scratches_paint and scratches_paint.getStats().ready)")
    dev.lua("getPlayerVehicle(0):queueLuaCommand(\"input.event('parkingbrake',1,1) input.event('throttle',0,1)\")")
    time.sleep(1)
    dev.lua("simTimeAuthority.pause(true) scratches_paint.clearStamps() scratches_paint.resetPaintStats() "
            f"scratches_paint.setRandomSeed({SEED})")
    drain()


def camera(point, normal, distance):
    cfg = json.dumps(dict(point=point, normal=normal, distance=distance))
    dev.lua("local c=jsonDecode(" + bench.lua_long_string(cfg) + ") "
            "local v=getPlayerVehicle(0) local m=v:getRefNodeMatrix() "
            "local center=m:mulP3F(vec3(unpack(c.point))) "
            "m:setColumn(3,vec3(0,0,0)) local n=m:mulP3F(vec3(unpack(c.normal))):normalized() "
            "local up=m:mulP3F(math.abs(c.normal[3])>0.9 and vec3(0,1,0) or vec3(0,0,1)) "
            "core_camera.setByName(0,'free') "
            "core_camera.globalCameraFunction('free','setPosition',center+n*c.distance) "
            "core_camera.globalCameraFunction('free','setRotation',quatFromDir(-n,up)) "
            "core_camera.setFOV(v:getId(),60)")
    # Exposure/reflections need several rendered frames after a camera jump.
    time.sleep(3)


def shot(out, name):
    rel = "bench/accuracy_capture_" + str(time.time_ns())
    source = Path(dev.user_dir()) / (rel + ".png")
    dev.lua("createScreenshot2({filename=" + json.dumps(rel) +
            ",writePNG=true,writeJPG=false,superSampling=1,rescaleFactor=0.5})")
    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        if source.exists() and source.stat().st_size > 0:
            try:
                from PIL import Image
                with Image.open(source) as im:
                    im.load()
                dest = out / (name + ".png")
                source.replace(dest)
                return dest
            except (OSError, PermissionError):
                pass
        time.sleep(0.1)
    raise RuntimeError("Screenshot was not saved: " + str(source))


def difference(before, after, out, roi=(0.2, 0.2, 0.8, 0.8)):
    import numpy as np
    from PIL import Image
    a, b = [np.asarray(Image.open(p).convert('RGB'), dtype=np.int16) for p in (before, after)]
    if a.shape != b.shape:
        raise RuntimeError("Capture resolution changed during test")
    delta = np.max(np.abs(a-b), axis=2)
    mask = delta > 20
    h, w = mask.shape
    crop = mask[int(roi[1]*h):int(roi[3]*h), int(roi[0]*w):int(roi[2]*w)]
    Image.fromarray((mask*255).astype('uint8')).save(out)
    return dict(changed=int(crop.sum()), pixels=int(crop.size), fraction=float(crop.mean()))


def fixture(out, name, part, point, normal, forbidden_point, forbidden_normal):
    out.mkdir(parents=True)
    logs = dev.LogTail()
    dev.lua(f"scratches_paint.clearStamps() scratches_paint.resetPaintStats() scratches_paint.setRandomSeed({SEED})")
    drain()
    # Name/part lookup avoids assuming numeric node ids survive engine updates.
    cfg = json.dumps(dict(part=part, point=point))
    target = lua_json("local c=jsonDecode(" + bench.lua_long_string(cfg) + ") "
        "local d=core_vehicle_manager.getPlayerVehicleData().vdata local best,dist "
        "for id,n in pairs(d.nodes) do if n.partOrigin==c.part and n.collision~=false then "
        "local v=n.pos-vec3(unpack(c.point)) local ds=v:dot(v) "
        "if not dist or ds<dist then best={id=id,name=n.name,rest=n.pos} dist=ds end end end "
        "if not best then error('fixture part has no collision node') end "
        "local v=getPlayerVehicle(0) local m=v:getRefNodeMatrix():fullInverse() m:setColumn(3,vec3(0,0,0)) "
        "local p=m:mulP3F(v:getNodePosition(best.id)) best.localPos={p.x,p.y,p.z} "
        "local ref=d.nodes[d.refNodes[0].ref].pos best.ref={ref.x,ref.y,ref.z} return jsonEncode(best)")
    forbidden = [x-r for x,r in zip(forbidden_point,target['ref'])]
    views = {'target': (target['localPos'],normal,0.9),
             'protected': (forbidden,forbidden_normal,1.4)}
    if name == 'bed_outer_only':
        inside = [x-r for x,r in zip([0.7,1.5,0.9],target['ref'])]
        views['inner_wall'] = (inside,[-1,0,0],0.6)
    before = {}
    for view,args in views.items():
        camera(*args)
        before[view] = shot(out, view+'_before')
    # Revisit every camera with no painting. This also detects camera-change
    # exposure lag, which a second shot at just the last view would miss.
    noise = {}
    for view,args in views.items():
        camera(*args)
        control = shot(out,view+'_control')
        noise[view] = difference(before[view],control,out/(view+'_control_diff.png'))
    contact = [target['id'],0,0,0,*normal,0,1,0,'s',6000,1]
    dev.lua("scratches_paint.ingestContacts(getPlayerVehicle(0):getId(),jsonDecode(" +
            bench.lua_long_string(json.dumps([contact])) + "))")
    drain()
    stats = lua_json("return jsonEncode(scratches_paint.getStats())")
    checks = {}
    for view,args in views.items():
        camera(*args)
        after = shot(out,view+'_after')
        checks[view] = difference(before[view],after,out/(view+'_diff.png'))
    log_lines = logs.read()
    (out/'game.log').write_text('\n'.join(log_lines),encoding='utf-8')
    errors = relevant_errors(log_lines)
    passed = fixture_passes(noise,checks,stats,errors)
    result = dict(name=name,passed=passed,target=target,contacts=[contact],views=views,
                  noise=noise,images=checks,painter=stats,errors=errors)
    (out/'result.json').write_text(json.dumps(result,indent=2))
    print(f"{name}: {'PASS' if passed else 'FAIL'} target={checks['target']['changed']} "
          f"protected={checks['protected']['changed']} controls={[v['changed'] for v in noise.values()]}",flush=True)
    return result


def crash_images(out, stats):
    """Remove only cosmetics from the frozen wreck, retaining its deformation."""
    out.mkdir(parents=True)
    dev.lua('simTimeAuthority.pause(true)')
    drain()
    ref = lua_json('local d=core_vehicle_manager.getPlayerVehicleData().vdata '
                   'local p=d.nodes[d.refNodes[0].ref].pos return jsonEncode({p.x,p.y,p.z})')
    # The whole-car overview cannot resolve the small impact chips. Inspect
    # the fixed rear-roof contact node at close range, including deformation.
    roof = lua_json("local v=getPlayerVehicle(0) local d=core_vehicle_manager.getPlayerVehicleData().vdata "
                    "for id,n in pairs(d.nodes) do if n.name=='rfc2l' then "
                    "local m=v:getRefNodeMatrix():fullInverse() m:setColumn(3,vec3(0,0,0)) "
                    "local p=m:mulP3F(v:getNodePosition(id)) return jsonEncode({p.x,p.y,p.z}) end end "
                    "error('Fixed pickup roof node is missing')")
    views = {'target': (roof,[0,0,1],0.65),
             'protected': ([x-r for x,r in zip([0,1.6,0.5],ref)],[0,0,1],1.4)}
    marked, noise = {}, {}
    for view,args in views.items():
        camera(*args)
        marked[view] = shot(out,view+'_painted')
    for view,args in views.items():
        camera(*args)
        control = shot(out,view+'_control')
        noise[view] = difference(marked[view],control,out/(view+'_control_diff.png'))
    dev.lua('scratches_paint.clearStamps()')
    drain()
    checks = {}
    for view,args in views.items():
        camera(*args)
        clean = shot(out,view+'_clean_deformed')
        checks[view] = difference(marked[view],clean,out/(view+'_diff.png'))
    result = dict(passed=fixture_passes(noise,checks,stats),views=views,noise=noise,images=checks)
    (out/'result.json').write_text(json.dumps(result,indent=2))
    print(f"crash paint isolation: {'PASS' if result['passed'] else 'FAIL'} "
          f"target={checks['target']['changed']} bed={checks['protected']['changed']}",flush=True)
    return result


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--ingame',action='store_true')
    ap.add_argument('--physics',action='store_true')
    ap.add_argument('--repeat',type=int,default=1)
    args=ap.parse_args()
    if args.repeat < 1: ap.error('--repeat must be positive')
    subprocess.run(['lua','tools/sim/harness.lua'],cwd=ROOT,check=True)
    if not (args.ingame or args.physics): return 0
    subprocess.run([sys.executable,'-m','unittest','discover','-s','tools/sim','-p','test_*.py'],cwd=ROOT,check=True)
    bench.ensure_bench()
    if bench.level_id()!='gridmap_v2':
        raise RuntimeError('Load Gridmap v2 before running the fixed fixtures')
    out=ROOT/'bench'/'accuracy'/time.strftime('%Y%m%d-%H%M%S')
    out.mkdir(parents=True)
    manifest=dict(config=CONFIG,seed=SEED,level='gridmap_v2',source={})
    sources = [p for tree in ('lua','art','tools') for p in (ROOT/tree).rglob('*')
               if p.is_file() and '__pycache__' not in p.parts]
    for p in sorted(sources):
        manifest['source'][str(p.relative_to(ROOT))]=hashlib.sha256(p.read_bytes()).hexdigest()
    manifest['environment']=lua_json("return jsonEncode({version=beamng_version,build=beamng_versiond,graphics=settings.getValue('GraphicDisplayResolutions')})")
    settings_file = Path(dev.user_dir())/'settings'/'settings.json'
    if settings_file.exists():
        graphics = json.loads(settings_file.read_text())
        manifest['environment']['graphics_settings'] = {k:v for k,v in graphics.items()
                                                        if k.startswith(('Graphic','PostFX'))}
    manifest['environment']['python'] = sys.version
    previous=lua_json("local e=scenetree.findObject('PostEffectLocalExposureObject') "
                      "if not e then error('Fixed exposure requires PostEffectLocalExposureObject') end "
                      "return jsonEncode({paused=simTimeAuthority.getPause(),ui=ui_visibility.get(),"
                      "background=settings.getValue('fpsLimitBackgroundEnabled'),autoExposure=e.autoExposure,manualEV=e.manualEV})")
    manifest['environment']['renderer'] = dev.lua('return Engine.Render.getAdapterType()')
    manifest['capture'] = dict(manualEV=EXPOSURE_EV,autoExposure=False,prior=previous)
    results=[]
    manifest['completed'] = False
    try:
        dev.lua("settings.setValue('fpsLimitBackgroundEnabled',false) ui_visibility.set(false)")
        dev.lua("local e=scenetree.findObject('PostEffectLocalExposureObject') "
                f"e.autoExposure=true e.manualEV={EXPOSURE_EV} e.autoExposure=false")
        for rep in range(1,args.repeat+1):
            prepare()
            for case in [
                ('roof_only','pickup_body',[0.337,0.4,1.745],[0,0,1],[0,1.6,0.5],[0,0,1]),
                ('bed_outer_only','pickup_bed',[0.9,1.5,0.9],[1,0,0],[0,1.6,0.5],[0,0,1]),
                ('bed_floor_positive','pickup_bed',[0,1.4,0.5],[0,0,1],[0,-0.1,1.75],[0,0,1]),
            ]:
                results.append(fixture(out/(case[0]+f'_r{rep}'),*case))
        if args.physics:
            for rep in range(1,args.repeat+1):
                for name in bench.SCENARIOS:
                    prepare()
                    logs = dev.LogTail()
                    dev.lua('simTimeAuthority.pause(false)')
                    summary=bench.run_one(name,SimpleNamespace(tag='accuracy',no_shots=False,
                        shot_scale=0.5,optick=False,repeat=args.repeat),[],bench.HOMES['gridmap_v2'],rep)
                    raw=json.loads((Path(bench.RUNS_DIR)/summary['run']/'result.json').read_text())
                    s=raw['painter']; q=s['queue']
                    log_lines = logs.read()
                    errors = relevant_errors(log_lines)
                    (out/(summary['run']+'.log')).write_text('\n'.join(log_lines),encoding='utf-8')
                    passed=(not errors and not raw.get('error') and not any(q.values()) and not s['stamp']['jobsFailed']
                            and not s['stamp'].get('bakesFailed',0)
                            and (s['perf']['bakeLayersTotal']>0 if name!='baseline' else s['stamp']['projectsIssued']==0))
                    if name == 'rollover':
                        passed = passed and min(raw['frames']['upZ']) < -0.7
                    images = crash_images(out/(name+f'_paint_r{rep}'),s) if name in ('roofdrop','rollover') else None
                    if images: passed = passed and images['passed']
                    results.append(dict(name=name,passed=passed,report=summary['run'],errors=errors,images=images))
        manifest['completed'] = True
    except Exception as exc:
        manifest['error'] = repr(exc)
        raise
    finally:
        try:
            dev.lua('simTimeAuthority.pause('+str(previous['paused']).lower()+') '
                    'ui_visibility.set('+str(previous['ui']).lower()+') '
                    'settings.setValue(\"fpsLimitBackgroundEnabled\",'+str(previous['background']).lower()+') '
                    "local e=scenetree.findObject('PostEffectLocalExposureObject') "
                    'e.autoExposure='+str(not previous['autoExposure']).lower()+' '
                    'e.manualEV='+str(previous['manualEV'])+' '
                    'e.autoExposure='+str(previous['autoExposure']).lower())
        except Exception as exc:
            manifest['restore_error'] = repr(exc)
        manifest['results']=results
        manifest['passed']=(manifest['completed'] and not manifest.get('restore_error')
                            and bool(results) and all(r['passed'] for r in results))
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2))
        print('Artifacts:',out)
    return 0 if manifest['passed'] else 1


if __name__=='__main__':
    raise SystemExit(main())
