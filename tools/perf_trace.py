"""Bounded ETW diagnostic: stop a 128 MiB circular trace after a >100 ms native call.
Traced runs are diagnostics, never untraced performance acceptance. No elevation.
"""
import argparse,json,time,subprocess,hashlib,shutil
from pathlib import Path
from types import SimpleNamespace
import dev,bench,livery_probe
p=argparse.ArgumentParser();p.add_argument('--label',required=True);p.add_argument('--runs',type=int,default=6);a=p.parse_args()
out=Path('docs/evidence/milestone5')/a.label;out.mkdir(parents=True,exist_ok=False)
trace=Path('bench')/(a.label+'.etl');session='ScratchesM5Ring'+str(int(time.time()))
bench.ensure_bench();(out/'environment.json').write_text(dev.lua(livery_probe.LUA))
(out/'source-sha256.json').write_text(json.dumps({str(f):hashlib.sha256((Path(dev.mount_dir())/f).read_bytes()).hexdigest() for f in (x.relative_to(Path(dev.mount_dir())) for x in (Path(dev.mount_dir())/'lua').rglob('*.lua'))},indent=2))
metadata={'session':session,'etlLocalPath':str(trace.resolve()),'profilingDiagnostic':True,'events':[]};active=False;triggered=False

def sync(phase):
 before=time.time();engine=float(dev.lua('return tostring(os.clockhp())'));after=time.time()
 metadata['events'].append({'phase':phase,'hostBeforeUTCSeconds':before,'engineClockSeconds':engine,'hostAfterUTCSeconds':after})
 (out/'trace.json').write_text(json.dumps(metadata,indent=2))

def stop(reason):
 global active,triggered
 if not active:return
 (out/'session-final.txt').write_text(subprocess.check_output(['logman','query',session,'-ets'],text=True))
 subprocess.run(['logman','stop',session,'-ets'],check=True,capture_output=True)
 active=False;triggered=reason!='limit';metadata['stopReason']=reason;sync('stopped')

def poll(status):
 if status.get('nativeMaxMs',0)>100:stop('native-over-100ms')

try:
 subprocess.run(['logman','start',session,'-p','Microsoft-Windows-Direct3D12','0x484','5','-f','bincirc','-max','128','-bs','64','-nb','64','256','-ets','-o',str(trace)],check=True,capture_output=True)
 active=True
 for name,mask in [('Microsoft-Windows-DXGI','0x2'),('Microsoft-Windows-Direct3DShaderCache','0xf'),('Microsoft-Windows-DxgKrnl','0x80c1')]:
  subprocess.run(['logman','update','trace',session,'-p',name,mask,'5','-ets'],check=True,capture_output=True)
 sync('started')
 tuning=bench.parse_tuning(['paint.setDamageResolution=2048','paint.setBakeBudget=3','paint.setFlushInterval=0.05','paint.setCoverageCoalescing=true','paint.setPanelGrouping=true'])
 for rep in range(1,a.runs+1):
  args=SimpleNamespace(tag=a.label,repeat=a.runs,no_shots=True,shot_scale=.5,optick=False,drain_timeout=15,on_poll=poll)
  row=bench.run_one('sustained',args,tuning,bench.homes()['gridmap_v2'],rep)
  shutil.copytree(Path(bench.RUNS_DIR)/row['run'],out/row['run'])
  data=json.loads((out/row['run']/'result.json').read_text())
  if max(data['painter']['perf'][k] for k in ['projectMsMax','bakeMsMax'])>100:stop('native-over-100ms-at-result')
  if triggered:break
finally:
 stop('limit')
 if trace.exists():
  metadata['etlBytes']=trace.stat().st_size;metadata['etlSHA256']=hashlib.sha256(trace.read_bytes()).hexdigest()
 (out/'trace.json').write_text(json.dumps(metadata,indent=2))
 dev.lua('if scratches_paint.getCompatibility().ready then scratches_paint.setDamageResolution(4096) end;scratches_paint.setBakeBudget(6);scratches_paint.setFlushInterval(0.2);scratches_paint.setCoverageCoalescing(false);scratches_paint.setPanelGrouping(false);return true')
