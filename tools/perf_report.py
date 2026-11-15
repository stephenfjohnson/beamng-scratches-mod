"""Summarize every retained milestone 5 run, including unfavorable outliers."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import bench
root=Path('docs/evidence/milestone5')
rows=[]
for p in sorted(root.rglob('result.json')):
 r=json.loads(p.read_text()); f=r.get('frames',{}); xs=f.get('frameMs',[])
 if not xs:continue
 perf=r['painter']['perf']; stamp=r['painter']['stamp']
 rows.append({'run':str(p.relative_to(root)), 'p95':bench.pct(xs,95),'p99':bench.pct(xs,99),'max':max(xs),'projectionMax':perf['projectMsMax'],'bakeMax':perf['bakeMsMax'],'queue':r['painter']['queue'],'drops':stamp['jobsDropped'],'aggregateDrops':stamp['aggregateDropped'],'config':r['painter']['config'],'failures':stamp['jobsFailed'],'drainSeconds':r.get('drainSeconds'),'frames':len(xs)})
(root/'all-runs.json').write_text(json.dumps(rows,indent=2))
fig,ax=plt.subplots(figsize=(12,max(5,len(rows)*.22)))
y=list(range(len(rows)))
ax.barh(y,[r['max'] for r in rows],color='#d4d9df',label='Worst frame')
ax.scatter([r['p99'] for r in rows],y,label='p99',s=14,color='#d66820')
ax.scatter([r['p95'] for r in rows],y,label='p95',s=10,color='#126290')
ax.set_yticks(y,[Path(r['run']).parent.name for r in rows],fontsize=6)
ax.axvline(100,color='#bb2222',linestyle=':',label='100 ms native-call gate (frame shown for context)')
ax.set_xlabel('Frame wall time (ms); different physics runs, same scripted launch')
ax.legend(fontsize=8);ax.invert_yaxis();fig.tight_layout();fig.savefig(root/'frame-tails.png',dpi=140)
print(f'{len(rows)} runs; worst frame {max(r["max"] for r in rows):.1f} ms')

# Whole-process memory is not dedicated GPU memory; preserve time axis and samples.
fig,ax=plt.subplots(figsize=(9,4))
for name in ['original-lifecycle','candidate-lifecycle']:
 p=root/name/'lifecycle.json'
 if not p.exists():continue
 data=json.loads(p.read_text());t0=data[0]['time']
 ax.plot([(x['time']-t0)/60 for x in data],[x['privateBytes']/2**30 for x in data],marker='.',label=name)
ax.set(xlabel='Elapsed automation time (minutes, includes MCP/host waits)',ylabel='Process-private memory (GiB)',title='20 player switches + 10 vehicle reloads; final point after Lua collection')
ax.legend();fig.tight_layout();fig.savefig(root/'lifecycle-memory.png',dpi=160)
