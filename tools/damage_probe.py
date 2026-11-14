"""Matched engine captures of existing collision damage and original stages, plus reset.
Run bench.py sideslide/roofdrop first; this helper never injects damage.
--skin configures the next run; without it, capture at one frozen pose/camera.
"""
import json,time,shutil,hashlib
from pathlib import Path
import dev,livery_probe
OUT=Path('docs/evidence/milestone4');OUT.mkdir(parents=True,exist_ok=True)
def lua(s):return dev.lua(s)
def capture(path):
    name='/screenshots/m4-'+str(time.time_ns())
    lua('createScreenshot2({filename='+json.dumps(name)+',writeJPG=false,rescaleFactor=0.5});return true')
    src=Path(dev.user_dir())/(name[1:]+'.png')
    for _ in range(40):
        time.sleep(.2)
        if src.exists():
            try:shutil.copyfile(src,path);return
            except PermissionError:pass
    raise RuntimeError('capture timeout')
def matched(label):
    folder=OUT/label;folder.mkdir(exist_ok=True)
    lua('simTimeAuthority.pause(true);local v=getPlayerVehicle(0);local c=v:getWorldBox():getCenter();local up=vec3(0,0,1);local p=c+up:cross(v:getDirectionVector()):normalized()*4.5+up*.9;core_camera.setByName(0,"free");core_camera.globalCameraFunction("free","setPosition",p);core_camera.globalCameraFunction("free","setRotation",quatFromDir((c-p):normalized(),up));return true')
    if 'roof' in label:
        lua('local v=getPlayerVehicle(0);local c=v:getWorldBox():getCenter();local p=c+vec3(0,.1,5);core_camera.globalCameraFunction("free","setPosition",p);core_camera.globalCameraFunction("free","setRotation",quatFromDir((c-p):normalized(),v:getDirectionVector()));return true')
    e=json.loads(lua(livery_probe.LUA));assert e['compatibility'].get('adapter');assert not e['comparison']['differences']
    mat=json.dumps(e['compatibility']['material'])
    try:
        for name,layers in [('damaged',4),('original-stages',2)]:
            lua(f'local m=scenetree.findObject({mat});m:setField("activeLayers",0,"{layers}");m:flush();m:reload();return true');time.sleep(.5);capture(folder/(name+'.png'))
    finally:lua(f'local m=scenetree.findObject({mat});m:setField("activeLayers",0,"4");m:flush();m:reload();return true')
    e['sourceSHA256']={str(p):hashlib.sha256((Path(dev.mount_dir())/p).read_bytes()).hexdigest() for p in Path('lua').rglob('*.lua')}
    e['state']=json.loads(lua('return jsonEncode({stats=scratches_paint.getStats(),surface=scratches_paint.getSurfaceState(),pos=getPlayerVehicle(0):getPosition(),camera=getCameraPosition()})'))
    (folder/'state.json').write_text(json.dumps(e,indent=2)+'\n')
    lua('scratches_paint.clearStamps();return true');time.sleep(.5);capture(folder/'reset.png')
    lua('simTimeAuthority.pause(false);return true')
def configure(skin,light):
    lua('simTimeAuthority.pause(false);core_vehicle_partmgmt.setSkin('+json.dumps(skin)+');return true');time.sleep(3)
    value=.75 if light else .025
    lua('local cfg=core_vehicle_partmgmt.getConfig();for _,p in ipairs(cfg.paints) do p.baseColor={'+f'{value},{value},{value},1.2'+'} end;core_vehicle_partmgmt.setConfigPaints(cfg.paints,true);return true');time.sleep(3)
if __name__=='__main__':
    import argparse
    p=argparse.ArgumentParser();p.add_argument('label');p.add_argument('--skin',choices=['plain','police']);p.add_argument('--light',action='store_true');a=p.parse_args()
    if a.skin:configure('' if a.skin=='plain' else 'police',a.light)
    else:
        try:matched(a.label)
        finally:lua('simTimeAuthority.pause(false);return true')
