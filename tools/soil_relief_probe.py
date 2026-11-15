"""Short A/B on the current muddy ETK; preserves marks, pose and camera.

Run after deploying the relief texture. No driving or reset. The clean pair
tests the material's zero-opacity endpoint, not physical water detection.
"""
import json
import shutil
import time
from pathlib import Path

import dev

OUT = Path('docs/evidence/soil-relief')
TEXTURE = '/art/dynamicDecals/textures/soil_relief_detail.normal.png'


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    dev.lua('soilReliefProbe={camera=core_camera.getContextCameraState(),'
            'paused=simTimeAuthority.getPause(),bg=settings.getValue("fpsLimitBackgroundEnabled")};'
            'local m=scenetree.findObject(scratches_paint.getCompatibility().material);'
            'soilReliefProbe.opacity=m:getField("opacityFactor",3);'
            'soilReliefProbe.texture=m:getField("detailNormalMap",3);return true')
    try:
        dev.lua('simTimeAuthority.pause(true);settings.setValue("fpsLimitBackgroundEnabled",false);'
                'local v=getPlayerVehicle(0);local f=v:getDirectionVector();'
                'local c=v:getWorldBox():getCenter()+f*0.9;'
                'local p=c+f:cross(vec3(0,0,1))*-2.3+vec3(0,0,0.35);'
                'core_camera.setByName(0,"free");'
                'core_camera.globalCameraFunction("free","setPosition",p);'
                'core_camera.globalCameraFunction("free","setRotation",quatFromDir((c-p):normalized(),vec3(0,0,1)));return true')
        time.sleep(.5)
        for name, enabled, visible in [('before', False, True), ('after', True, True),
                                       ('hidden-before', False, False), ('hidden-after', True, False)]:
            dev.lua('local m=scenetree.findObject(scratches_paint.getCompatibility().material);'
                    'm:setField("detailNormalMap",3,' + json.dumps(TEXTURE if enabled else '') + ');'
                    'm:setField("opacityFactor",3,' + ('soilReliefProbe.opacity' if visible else '"0"') + ');'
                    'm:flush();m:reload();return true')
            time.sleep(.4)
            filename = 'soil-relief-' + name
            dev.lua('createScreenshot2({filename=' + json.dumps(filename) + ',writeJPG=false,rescaleFactor=0.5});return true')
            time.sleep(.8)
            shutil.copyfile(Path(dev.user_dir()) / (filename + '.png'), OUT / (name + '.png'))
        (OUT / 'state.json').write_text(dev.lua('return jsonEncode({compatibility=scratches_paint.getCompatibility(),surface=scratches_paint.getSurfaceState()})') + '\n')
    finally:
        dev.lua('local m=scenetree.findObject(scratches_paint.getCompatibility().material);'
                'm:setField("detailNormalMap",3,soilReliefProbe.texture);'
                'm:setField("opacityFactor",3,soilReliefProbe.opacity);m:flush();m:reload();'
                'core_camera.setContextCameraState(nil,soilReliefProbe.camera);'
                'simTimeAuthority.pause(soilReliefProbe.paused);'
                'settings.setValue("fpsLimitBackgroundEnabled",soilReliefProbe.bg);soilReliefProbe=nil;return true')
    print(OUT)


if __name__ == '__main__':
    main()
