"""Capture matched original-stage and clean-overlay renders on an active ETK adapter.
Clears cosmetic marks. Run after a bench baseline at rest; does not edit source materials.
Usage: python tools/etk_compare.py --output docs/evidence/milestone1/etk-plain
"""
import argparse
import json
from pathlib import Path
import shutil
import time
import dev
import livery_probe


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    evidence = json.loads(dev.lua(livery_probe.LUA))
    c = evidence['compatibility']
    assert c.get('adapter') and c['ready'], 'ETK adapter not ready'
    assert not evidence['comparison']['differences'], 'Original material fields differ'
    count = evidence['comparison']['originalStages']
    active = int(evidence['comparison']['activeStages'])
    mat = json.dumps(c['material'])
    dev.lua('scratches_paint.clearStamps(); local v=getPlayerVehicle(0); local c=v:getWorldBox():getCenter(); '
            'local f=v:getDirectionVector(); local up=vec3(0,0,1); local left=up:cross(f):normalized(); '
            'local p=c+left*5+up*1.2; core_camera.setByName(0,"free"); '
            'core_camera.globalCameraFunction("free","setPosition",p); '
            'core_camera.globalCameraFunction("free","setRotation",quatFromDir((c-p):normalized(),up)); return true')
    try:
        for label, layers in [('original-stages', count), ('clean-overlay', active)]:
            dev.lua(f'local m=scenetree.findObject({mat});m:setField("activeLayers",0,"{layers}");m:flush();m:reload();return true')
            time.sleep(1)
            basename = f'/screenshots/scratches-compare-{time.time_ns()}-{label}'
            dev.lua(f'createScreenshot2({{filename={json.dumps(basename)},writeJPG=false,rescaleFactor=0.5}}); return true')
            source = Path(dev.user_dir()) / (basename.lstrip('/') + '.png')
            for _ in range(30):
                if source.exists():
                    try:
                        shutil.copyfile(source, out.with_name(out.name+'-'+label+'.png'))
                        break
                    except PermissionError:
                        pass
                time.sleep(0.25)
            else:
                raise RuntimeError('screenshot was not written')
    finally:
        dev.lua(f'local m=scenetree.findObject({mat});m:setField("activeLayers",0,"{active}");m:flush();m:reload();return true')
    out.with_suffix('.json').write_text(json.dumps(evidence, indent=2)+'\n', encoding='utf-8')
    print('Original stages equal source; both comparison captures saved.')

if __name__ == '__main__':
    main()
