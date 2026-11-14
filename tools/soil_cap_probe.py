"""Sustained low-speed rolling stress through actual Gridmap DIRT collisions.
The bench maintains 2 m/s with the stock cluster-velocity API; no fake contacts.
"""
import time,json
from pathlib import Path
import dev,soil_probe
def main():
    try:
        rows=[]
        Path('docs/evidence/milestone2').mkdir(parents=True,exist_ok=True)
        dev.lua('local v=getPlayerVehicle(0);v:setPosRot(-350,-365,100.3,0,0,1,0);v:queueLuaCommand([[input.event("parkingbrake",0,1);input.event("throttle",0,1);input.event("brake",0,1)]]);return true')
        time.sleep(2)
        dev.lua('m2contacts=nil;scratches_paint.clearStamps();scratches_paint.resetPaintStats();return true')
        for i in range(120):
         dev.lua('local v=getPlayerVehicle(0);v:applyClusterVelocityScaleAdd(v:getRefNodeId(),0,0,2,0);return true')
         time.sleep(.25)
         if i%20==19:rows.append(soil_probe.state())
        dev.lua('getPlayerVehicle(0):queueLuaCommand([[input.event("parkingbrake",1,1)]]);return true')
        time.sleep(2);rows.append(soil_probe.state())
        Path('docs/evidence/milestone2/cap.json').write_text(json.dumps(rows,indent=2))
        soil_probe.shot(Path('docs/evidence/milestone2/dirt-capped.png'))
        print([r['surface']['deposits'] for r in rows])
    finally:
        dev.lua('local v=getPlayerVehicle(0);if v then v:queueLuaCommand([[input.event("throttle",0,1);input.event("parkingbrake",1,1)]]) end;return true')

if __name__ == '__main__':
    main()
