"""Live ground-strip driving probe. Uses real collisions, never injects soil events."""
import argparse,json,time,shutil
from pathlib import Path
import dev
import livery_probe

def lua(s): return dev.lua(s)
def shot(path):
    lua('local v=getPlayerVehicle(0);local c=v:getWorldBox():getCenter();local p=c+v:getDirectionVector():cross(vec3(0,0,1))*5+vec3(0,0,1);core_camera.setByName(0,"free");core_camera.globalCameraFunction("free","setPosition",p);core_camera.globalCameraFunction("free","setRotation",quatFromDir((c-p):normalized(),vec3(0,0,1)));return true')
    time.sleep(.3)
    name='/screenshots/m2-'+str(time.time_ns())
    lua('createScreenshot2({filename='+json.dumps(name)+',writeJPG=false,rescaleFactor=0.5});return true')
    time.sleep(1)
    shutil.copyfile(Path(dev.user_dir())/(name[1:]+'.png'),path)
def state():
    return json.loads(lua('return jsonEncode({surface=scratches_paint.getSurfaceState(),stats=scratches_paint.getStats(),pos=getPlayerVehicle(0):getPosition(),velocity=getPlayerVehicle(0):getVelocity(),contacts=m2contacts})'))
def run():
    ap=argparse.ArgumentParser();ap.add_argument('kind');ap.add_argument('--x',type=float,required=True);ap.add_argument('--y',type=float,default=-365);ap.add_argument('--z',type=float,default=100.3);ap.add_argument('--seconds',type=float,default=8);a=ap.parse_args()
    out=Path('docs/evidence/milestone2');out.mkdir(parents=True,exist_ok=True)
    lua('simTimeAuthority.pause(false);settings.setValue("fpsLimitBackgroundEnabled",false);local v=getPlayerVehicle(0);v:setPosRot('+str(a.x)+','+str(a.y)+','+str(a.z)+',0,0,1,0);v:queueLuaCommand([[input.event("throttle",0,1);input.event("brake",0,1);input.event("parkingbrake",1,1)]]);return true')
    time.sleep(2)
    lua('m2contacts=nil;scratches_paint.clearStamps();scratches_paint.resetPaintStats();getPlayerVehicle(0):queueLuaCommand([[if m2old then onNodeCollision=m2old end;m2old=onNodeCollision;local old=m2old;local counts={};local total=0;onNodeCollision=function(id,p,n,nv,pv,sv,sl,sf,nf,d,m1,m2) counts[m1]=(counts[m1] or 0)+1;total=total+1;if total%1000==0 then obj:queueGameEngineLua("m2contacts="..serialize(counts)) end;old(id,p,n,nv,pv,sv,sl,sf,nf,d,m1,m2) end;controller.mainController.setGearboxMode("arcade")]]);return true')
    result={'config':json.loads(lua(livery_probe.LUA)),'start':state()}
    shot(out/(a.kind+'-clean.png'))
    lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",0,1);input.event("throttle",0.35,1)]]);return true')
    time.sleep(a.seconds/2)
    lua('simTimeAuthority.pause(true);return true');result['early']=state();shot(out/(a.kind+'-early.png'))
    lua('simTimeAuthority.pause(false);return true');time.sleep(a.seconds/2)
    lua('simTimeAuthority.pause(true);return true');result['late']=state();shot(out/(a.kind+'-late.png'))
    lua('getPlayerVehicle(0):queueLuaCommand([[input.event("throttle",0,1);input.event("brake",0,1);input.event("parkingbrake",1,1)]]);simTimeAuthority.pause(false);return true')
    time.sleep(4);result['stationaryStart']=state();time.sleep(3);result['stationaryEnd']=state();shot(out/(a.kind+'-stationary.png'))
    (out/(a.kind+'.json')).write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:v.get('surface') for k,v in result.items() if k!='config'}))
def main():
    previous = json.loads(lua('return jsonEncode(settings.getValue("fpsLimitBackgroundEnabled"))'))
    try:
        run()
    finally:
        lua('simTimeAuthority.pause(false);local v=getPlayerVehicle(0);if v then v:queueLuaCommand([[input.event("throttle",0,1);input.event("brake",0,1);input.event("parkingbrake",1,1);if m2old then onNodeCollision=m2old;m2old=nil end]]) end;settings.setValue("fpsLimitBackgroundEnabled",'+str(previous).lower()+');return true')
if __name__=='__main__':main()
