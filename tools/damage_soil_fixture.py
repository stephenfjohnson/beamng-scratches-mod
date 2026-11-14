"""Move an already scratched ETK to real mud and roll it without resetting damage."""
import time,json,argparse
from pathlib import Path
import dev,soil_probe,livery_probe
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,default=Path('docs/evidence/milestone4/persistence'));out=parser.parse_args().output;out.mkdir(parents=True,exist_ok=True)
lua=dev.lua
previous=json.loads(lua('return jsonEncode(settings.getValue("fpsLimitBackgroundEnabled"))'))
try:
 lua('settings.setValue("fpsLimitBackgroundEnabled",false);local v=getPlayerVehicle(0);v:setClusterPosRelRot(v:getRefNodeId(),-313,-365,100.3,0,0,0,1);v:applyClusterVelocityScaleAdd(v:getRefNodeId(),0,0,0,0);v:queueLuaCommand([[input.event("parkingbrake",0,1)]]);return true')
 for i in range(24):
  lua('local v=getPlayerVehicle(0);v:applyClusterVelocityScaleAdd(v:getRefNodeId(),0,0,2,0);return true');time.sleep(.25)
 lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",1,1)]]);return true');time.sleep(3)
 (out/'before-wash.json').write_text(json.dumps({'config':json.loads(lua(livery_probe.LUA)),'state':soil_probe.state()},indent=2)+'\n')
finally:lua('settings.setValue("fpsLimitBackgroundEnabled",'+str(previous).lower()+');return true')
