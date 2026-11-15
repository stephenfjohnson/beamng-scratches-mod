"""Sanitize a Get-WinEvent XML export to game-owned graphics events and exact
correlated kernel paging packets. The raw system-wide ETL/XML stays local.
Example export (PowerShell, choose window from nativeEvents and trace clock sync):
Get-WinEvent -Path bench/resumed-native-ring.etl -Oldest -FilterXPath $q |
  ForEach-Object { $_.ToXml() } | Set-Content -Encoding utf8 bench/m5-stall-events.xml
"""
import argparse,json,datetime,xml.etree.ElementTree as ET
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--xml',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--run',type=Path,required=True);p.add_argument('--pid',type=int,required=True)
p.add_argument('--anchor-engine-clock',type=float,help='engine os.clockhp() seconds to use as offset zero (e.g. start of a long frame) instead of the longest native call');a=p.parse_args()
meta=json.loads((a.out/'trace.json').read_text());sync=next(e for e in meta['events'] if e['phase']=='started')
offset=(sync['hostBeforeUTCSeconds']+sync['hostAfterUTCSeconds'])/2-sync['engineClockSeconds']
r=json.loads(a.run.read_text())
if a.anchor_engine_clock is not None:native={'started':a.anchor_engine_clock,'ms':None,'anchor':'frame'}
else:native=max(r['painter']['nativeEvents'],key=lambda e:e['ms'])
start=native['started']+offset
ns={'e':'http://schemas.microsoft.com/win/2004/08/events/event'};events=[]
for node in ET.fromstring('<Events>'+a.xml.read_text(encoding='utf-8-sig')+'</Events>'):
 s=node.find('e:System',ns);ex=s.find('e:Execution',ns)
 events.append({'provider':s.find('e:Provider',ns).attrib['Name'],'id':int(s.findtext('e:EventID',namespaces=ns)),'task':int(s.findtext('e:Task',namespaces=ns) or 0),'op':int(s.findtext('e:Opcode',namespaces=ns) or 0),'time':s.find('e:TimeCreated',ns).attrib['SystemTime'],'pid':int(ex.attrib['ProcessID']),'tid':int(ex.attrib['ThreadID']),'data':{d.attrib.get('Name',''):d.text for d in node.findall('e:EventData/e:Data',ns)}})
def key(e):return tuple(e['data'].get(k) for k in ['PagingQueue','PagingQueuePacket','SequenceId'])
def ms(e):return (datetime.datetime.fromisoformat(e['time'].replace('Z','+00:00')).timestamp()-start)*1000
packets={key(e):e for e in events if e['pid']==a.pid and e['provider'].endswith('DxgKrnl') and e['id']==322}
owned=[];delays=[]
for e in events:
 correlated=e['provider'].endswith('DxgKrnl') and e['id'] in [324,325] and key(e) in packets
 if e['pid']==a.pid or correlated:
  row={k:e[k] for k in ['provider','id','task','op']};row['offsetMs']=round(ms(e),4);row['gameThread']=e['tid'] if e['pid']==a.pid else None
  row['data']={k:v for k,v in e['data'].items() if k in ['SequenceId','VidMmOpType','ExecutionTime100ns','Width','Height','Dimension','HeapType','Format','Size']};owned.append(row)
 if correlated and e['id']==325:
  q=packets[key(e)];delays.append({'sequence':q['data']['SequenceId'],'vidMmOpType':q['data']['VidMmOpType'],'queuedOffsetMs':ms(q),'completedOffsetMs':ms(e),'queueToCompleteMs':ms(e)-ms(q),'executionTime100ns':e['data'].get('ExecutionTime100ns')})
(a.out/'stall-owned-events.json').write_text(json.dumps(owned,indent=2))
(a.out/'paging-delays.json').write_text(json.dumps(sorted(delays,key=lambda e:e['queueToCompleteMs'],reverse=True),indent=2))
print(json.dumps({'ownedOrCorrelatedEvents':len(owned),'nativeMs':native['ms'],'anchor':native.get('anchor','native'),'longestPagingPacket':max(delays,key=lambda e:e['queueToCompleteMs'],default=None)},indent=2))
