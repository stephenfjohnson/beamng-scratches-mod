"""Plot sanitized graphics events; no implication of CPU stacks/GPU execution time."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
p=Path('docs/evidence/milestone5/resumed-native-ring')
x=json.loads((p/'stall-owned-events.json').read_text());analysis=json.loads((p/'stall-analysis.json').read_text());delays=json.loads((p/'paging-delays.json').read_text())
fig,ax=plt.subplots(figsize=(12,5))
ax.broken_barh([(0,analysis['nativeProjectMs'])],(-.25,.5),facecolors='#c74932')
ax.text(10,0,'Native projection: 425.92 ms elapsed',color='white',va='center',fontsize=10)
packet=next(d for d in delays if d['sequence']=='29480')
ax.broken_barh([(packet['queuedOffsetMs'],packet['queueToCompleteMs'])],(.75,.5),facecolors='#2c75a5')
ax.text(10,1,'Paging packet: 422.64 ms queued to complete (not GPU execution duration)',color='white',va='center',fontsize=9)
threads=sorted(set(e['gameThread'] for e in x if e['provider'].endswith('Direct3D12') and e['gameThread']))
labels=['Native call','Paging packet']
for i,t in enumerate(threads,2):
 xs=[e['offsetMs'] for e in x if e['provider'].endswith('Direct3D12') and e['gameThread']==t]
 ax.scatter(xs,[i]*len(xs),marker='|',s=35,color='#38674d');labels.append('D3D12 thread '+str(t))
row=len(labels);present=[e['offsetMs'] for e in x if e['provider'].endswith('DXGI') and e['id']==42]
ax.scatter(present,[row]*len(present),marker='|',s=65,color='#725ba1');labels.append('DXGI Present start')
ax.axvline(0,color='#555',ls=':',lw=1);ax.axvline(analysis['nativeProjectMs'],color='#555',ls=':',lw=1)
ax.set_yticks(range(len(labels)),labels,fontsize=9);ax.invert_yaxis();ax.set_xlim(-50,480);ax.set_xlabel('Milliseconds relative to native-call start; clock alignment uncertainty approximately ±2.47 ms')
ax.set_title('D3D12 traced diagnostic: paging packet spans the native-call pause')
fig.text(.5,.015,'Event silence does not establish a CPU wait stack or root cause. No shader/pipeline-create events in this window is not proof of no shader work.',ha='center',fontsize=8)
fig.tight_layout(rect=(0,.04,1,1));fig.savefig(p/'stall-timeline.png',dpi=160)
