"""Real traffic plus player scrape; preserves any pre-existing traffic."""
import argparse,json,time,shutil
from pathlib import Path
from types import SimpleNamespace
import dev,bench
p=argparse.ArgumentParser();p.add_argument('--label',required=True);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
def vehicles():
 return json.loads(dev.lua('local r={};for _,v in ipairs(getAllVehicles()) do local layers={};for _,name in pairs(v:getMaterialNames()) do if name:find("scratches_etk800_",1,true) then local m=scenetree.findObject(name);layers[name]=m and m:getField("activeLayers",0) or "missing" end end;r[tostring(v:getId())]={model=v.JBeam,pos=v:getPosition(),velocity=v:getVelocity(),materials=v:getMaterialNames(),privateLayers=layers} end;return jsonEncode(r)'))
before=vehicles();new=[];r={'before':before}
try:
 dev.lua('gameplay_traffic.setupTraffic(3,{keepCurrent=true});return true');time.sleep(15)
 r['spawned']=vehicles();new=[i for i in r['spawned'] if i not in before]
 assert new,'traffic failed to spawn'
 bench.ensure_bench()
 args=SimpleNamespace(tag=a.label,repeat=1,no_shots=True,shot_scale=.5,optick=False)
 row=bench.run_one('sideslide',args,[],bench.homes()['gridmap_v2'],1)
 shutil.copytree(Path(bench.RUNS_DIR)/row['run'],out/row['run'])
 r['after']=vehicles();r['npcStats']={}
 for vid in new:
  dev.lua('m5traffic={};function m5traffic.recv(s,p) m5traffic.stats=s end;local v=scenetree.findObjectById('+vid+');if v then v:queueLuaCommand([[if scratches_detect then scratches_detect.sendStatsTo("m5traffic.recv") end]]) end;return true')
  time.sleep(.5);r['npcStats'][vid]=json.loads(dev.lua('return jsonEncode(m5traffic.stats or {})'))
finally:
 (out/'traffic.json').write_text(json.dumps(r,indent=2))
 for vid in new:dev.lua('local v=scenetree.findObjectById('+vid+');if v then v:delete() end;return true')
 dev.lua('m5traffic=nil;return true')
