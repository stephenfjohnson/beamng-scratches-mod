"""Real WaterBlock immersion experiment. Moves water, never injects sensor events.
Restores map water (or deletes its temporary fixture) in finally.
Requires a supported dirty vehicle, parked with brakes applied. Deep water can
flood its engine. Captures use the same car; no cosmetic reset is performed.
"""
import time,json,argparse
from pathlib import Path
import dev,soil_probe,livery_probe
ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--output',default='docs/evidence/milestone3');ap.add_argument('--redirty-x',type=float);ap.add_argument('--left',action='store_true',help='photograph left side for scratch persistence');a=ap.parse_args()
out=Path(a.output);out.mkdir(parents=True,exist_ok=True)
def lua(s):return dev.lua(s)
def state():return {'state':soil_probe.state(),'config':json.loads(lua(livery_probe.LUA))}
def snap(name):
    lua('simTimeAuthority.pause(true);return true')
    result[name]=state();soil_probe.shot(out/(name+'.png'), side=-1 if a.left else 1)
    lua('simTimeAuthority.pause(false);return true')
result={}
previous=json.loads(lua('return jsonEncode(settings.getValue("fpsLimitBackgroundEnabled"))'))
created=json.loads(lua('if scenetree.findObject("WaterBlock_1") then return "false" end;local w=createObject("WaterBlock");w:setField("scale",0,"35 100 10");w:setField("density",0,"1000");w:setField("viscosity",0,"0.001");w:setField("liquidType",0,"Water");w:setPosition(vec3(0,0,-100));w.canSave=false;w:registerObject("WaterBlock_1");scenetree.MissionGroup:addObject(w);return "true"'))
result['waterFixture']={'temporary':created,'class':'WaterBlock','scale':'35 100 10'}
original=json.loads(lua('local w=scenetree.findObject("WaterBlock_1");return jsonEncode(w:getPosition())'))
def restore():lua('scenetree.findObject("WaterBlock_1"):setPosition(vec3('+','.join(str(original[k]) for k in ['x','y','z'])+'));return true')
def flood(depth):
    lua('local p=getPlayerVehicle(0):getPosition();scenetree.findObject("WaterBlock_1"):setPosition(vec3(p.x,p.y,p.z+'+str(depth)+'));return true')
try:
    lua('settings.setValue("fpsLimitBackgroundEnabled",false);scratches_paint.resetPaintStats();return true')
    snap('dirty')
    flood(-0.15);time.sleep(2);snap('shallow')
    flood(0.5);time.sleep(2);snap('partial-water')
    restore();snap('wet-partial')
    flood(2);time.sleep(3);snap('deep-progress')
    time.sleep(7);snap('deep-washed')
    restore();snap('washed-wet')
    lua('simTimeAuthority.pause(true);return true');result['pauseStart']=state();time.sleep(2);result['pauseEnd']=state();lua('simTimeAuthority.pause(false);return true')
    deadline=time.monotonic()+90
    while soil_probe.state()['surface']['wetness']>0 and time.monotonic()<deadline: time.sleep(.5)
    assert soil_probe.state()['surface']['wetness']==0, 'drying timed out'
    snap('dry')
    if a.redirty_x is not None:
        lua('local v=getPlayerVehicle(0);v:setClusterPosRelRot(v:getRefNodeId(),'+str(a.redirty_x)+',-365,100.3,0,0,0,1);v:applyClusterVelocityScaleAdd(v:getRefNodeId(),0,0,0,0);return true')
    lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",0,1)]]);return true')
    for i in range(24):
        lua('local v=getPlayerVehicle(0);v:applyClusterVelocityScaleAdd(v:getRefNodeId(),0,0,'+('2' if a.redirty_x is not None else '-2')+',0);return true')
        time.sleep(.25)
    lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",1,1)]]);return true')
    time.sleep(3);snap('redirty')
finally:
    restore();lua('simTimeAuthority.pause(false);settings.setValue("fpsLimitBackgroundEnabled",'+str(previous).lower()+');getPlayerVehicle(0):queueLuaCommand([[input.event("throttle",0,1);input.event("parkingbrake",1,1)]]);return true')
    if created: lua('scenetree.findObject("WaterBlock_1"):delete();return true')
    (out/'water.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v['state']['surface'] for k,v in result.items() if 'state' in v}))
