"""Move an already scratched ETK to real mud and roll it without resetting damage."""
import time,json,argparse
from pathlib import Path
import dev,soil_probe,livery_probe
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,default=Path('docs/evidence/milestone4/persistence'));parser.add_argument('--drive-in',action='store_true',help='physically translate from adjacent scrape area; no damaged-vehicle teleport');args=parser.parse_args();out=args.output;out.mkdir(parents=True,exist_ok=True)
lua=dev.lua
previous=json.loads(lua('return jsonEncode(settings.getValue("fpsLimitBackgroundEnabled"))'))
generation=int(lua('return scratches_paint.getStats().generation'))
try:
 # Use the installed safe-placement API's explicit non-reset path. Raw low
 # placement caused instability; the -1 cluster path also reset cosmetics.
 lua('settings.setValue("fpsLimitBackgroundEnabled",false);getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",0,1)]]);return true')
 if args.drive_in:
  samples=[];deadline=time.monotonic()+20
  while True:
   row=json.loads(lua('local v=getPlayerVehicle(0);local p=v:getPosition();local c=v:getVelocity();local vx=math.max(-2,math.min(2,(-313-p.x)*2));v:applyClusterVelocityScaleAdd(v:getRefNodeId(),1,vx-c.x,-c.y,0);return jsonEncode({pos=p,generation=scratches_paint.getStats().generation})'))
   samples.append(row);(out/'drive-in.json').write_text(json.dumps(samples,indent=2))
   assert row['generation']==generation,'physical mud approach reset cosmetics; not persistence evidence'
   if abs(row['pos']['x']+313)<.2:break
   assert time.monotonic()<deadline,'physical mud approach timed out'
   time.sleep(.2)
 else:
  lua('spawn.safeTeleport(getPlayerVehicle(0),vec3(-313,-365,101.2),quat(0,0,0,1),true,nil,false,false,false);return true')
 for i in range(24):
  current=int(lua('local v=getPlayerVehicle(0);local c=v:getVelocity();v:applyClusterVelocityScaleAdd(v:getRefNodeId(),1,-c.x,2-c.y,0);return scratches_paint.getStats().generation'));assert current==generation,'mud placement reset cosmetics; not persistence evidence';time.sleep(.25)
 lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",1,1)]]);return true');time.sleep(3)
 (out/'before-wash.json').write_text(json.dumps({'config':json.loads(lua(livery_probe.LUA)),'state':soil_probe.state()},indent=2)+'\n')
 assert int(lua('return scratches_paint.getStats().generation'))==generation,'mud settling reset cosmetics; not persistence evidence'
except Exception as e:
 (out/'fixture-error.json').write_text(json.dumps({'error':str(e),'initialGeneration':generation,'state':soil_probe.state()},indent=2));raise
finally:lua('settings.setValue("fpsLimitBackgroundEnabled",'+str(previous).lower()+');return true')
