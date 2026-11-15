"""Move an already scratched ETK to real mud and roll it without resetting damage."""
import time,json,argparse
from pathlib import Path
import dev,soil_probe,livery_probe
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,default=Path('docs/evidence/milestone4/persistence'));out=parser.parse_args().output;out.mkdir(parents=True,exist_ok=True)
lua=dev.lua
previous=json.loads(lua('return jsonEncode(settings.getValue("fpsLimitBackgroundEnabled"))'))
generation=int(lua('return scratches_paint.getStats().generation'))
try:
 # Use the installed safe-placement API's explicit non-reset path. Raw low
 # placement caused instability; the -1 cluster path also reset cosmetics.
 lua('settings.setValue("fpsLimitBackgroundEnabled",false);local v=getPlayerVehicle(0);spawn.safeTeleport(v,vec3(-313,-365,101.2),quat(0,0,0,1),true,nil,false,false,false);v:queueLuaCommand([[input.event("parkingbrake",0,1)]]);return true')
 for i in range(24):
  current=int(lua('local v=getPlayerVehicle(0);local c=v:getVelocity();v:applyClusterVelocityScaleAdd(v:getRefNodeId(),1,-c.x,2-c.y,0);return scratches_paint.getStats().generation'));assert current==generation,'mud placement reset cosmetics; not persistence evidence';time.sleep(.25)
 lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",1,1)]]);return true');time.sleep(3)
 (out/'before-wash.json').write_text(json.dumps({'config':json.loads(lua(livery_probe.LUA)),'state':soil_probe.state()},indent=2)+'\n')
 assert int(lua('return scratches_paint.getStats().generation'))==generation,'mud settling reset cosmetics; not persistence evidence'
except Exception as e:
 (out/'fixture-error.json').write_text(json.dumps({'error':str(e),'initialGeneration':generation,'state':soil_probe.state()},indent=2));raise
finally:lua('settings.setValue("fpsLimitBackgroundEnabled",'+str(previous).lower()+');return true')
