"""Controlled splash projections at ETK side-panel seams, on the current paint.

Clears cosmetic marks; does not drive or change the paint config. These are
synthetic placement checks, separate from soil_probe.py's real mud contacts.
"""
import argparse
import json
import time
from pathlib import Path

import dev
import soil_probe


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    args.output.mkdir(parents=True,exist_ok=True)
    dev.lua('soilSeamProbe={camera=core_camera.getContextCameraState(),paused=simTimeAuthority.getPause(),'
            'bg=settings.getValue("fpsLimitBackgroundEnabled")};simTimeAuthority.pause(true);'
            'settings.setValue("fpsLimitBackgroundEnabled",false);scratches_paint.clearStamps();return true')
    try:
        dev.lua('local b=getPlayerVehicle(0):getSpawnLocalAABB();'
                'for _,side in ipairs({-1,1}) do '
                'local x=side<0 and b.minExtents.x or b.maxExtents.x;'
                'for i,y in ipairs({-0.9,0.25,1.3}) do for pass=1,4 do '
                'scratches_paint.stampAtLocal(vec3(x,y,0.25+i*0.13),vec3(side,0,0),'
                '{soil=true,r=0.62,g=0.36,b=0.16,a=0.95,scale=2.3,width=0.48,depth=math.min(1.8,(b.maxExtents.x-b.minExtents.x)*0.9),'
                'flow=vec3(0,1,0.1):normalized(),skipMetal=true,noJitter=true,dist=5.1,'
                'colorTex="/art/dynamicDecals/textures/soil_mud_splash_1.png"}) end end end;return true')
        time.sleep(1)
        for side in (-0.65,0.65):
            soil_probe.shot(args.output/('seams-left.png' if side<0 else 'seams-right.png'),side=side)
        state=json.loads(dev.lua('return jsonEncode({compatibility=scratches_paint.getCompatibility(),stats=scratches_paint.getStats()})'))
        (args.output/'seams.json').write_text(json.dumps(state,indent=2)+'\n')
        assert state['stats']['queue']['jobs']==0, 'projection queue not drained'
    finally:
        dev.lua('core_camera.setContextCameraState(nil,soilSeamProbe.camera);simTimeAuthority.pause(soilSeamProbe.paused);'
                'settings.setValue("fpsLimitBackgroundEnabled",soilSeamProbe.bg);soilSeamProbe=nil;return true')
    print(args.output)


if __name__=='__main__':
    main()
