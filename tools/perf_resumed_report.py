"""Report resumed M5 cohorts without mixing corrected fixtures with invalid v1 runs.
Stage percentiles are per-frame accumulated work, not individual native calls.
Native maxima come from the call timers. All failed/diagnostic runs are retained.
"""
import json,collections
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import bench
root=Path('docs/evidence/milestone5');rows=[]
invalid={'resumed-half-b1-fast-cold-v2'}
corrected={'resumed-v2-full-control','resumed-v2-half-b3'}

def distribution(xs):
 return {'p95':bench.pct(xs,95),'p99':bench.pct(xs,99),'worst':max(xs,default=0),'samples':len(xs)}
for p in sorted(root.glob('resumed-*/*/result.json')):
 r=json.loads(p.read_text());f=r.get('frames') or {};xs=f.get('frameMs',[])
 if not xs:continue
 group=p.parent.parent.name;painter=r.get('painter') or r.get('lastValidPainterStats') or {};perf=painter.get('perf',{});stamp=painter.get('stamp',{});coverage=painter.get('coverage',{})
 fixture='functional' if '-func' in group else 'v2' if group in corrected or any(k in group for k in ['grouped','circle','selected','control-v2']) else 'v1'
 diagnostic=group in ['resumed-native-ring','resumed-grouped-half-warm']
 stages={}
 for field in ['projectTotalMs','bakeTotalMs']:
  series=f.get(field,[]);delta=[max(0,v-(series[i-1] if i else 0)) for i,v in enumerate(series)]
  stages[field]={"allFrames":distribution(delta),"activeFrames":distribution([v for v in delta if v>0])}
 row={'group':group,'run':p.parent.name,'scenario':r.get('name',p.parent.name.split('_')[1]),'error':r.get('error'),'fixture':fixture,'diagnostic':diagnostic,'invalidLegacyReset':group in invalid,'frames':distribution(xs),'perFrameStages':stages,'nativeTimingProfile':r.get('nativeTimingProfile'),'projectionMax':perf.get('projectMsMax',0),'bakeMax':perf.get('bakeMsMax',0),'inputToBakeMax':perf.get('inputToBakeMaxMs',0),'inputToProjectMax':perf.get('inputToProjectMaxMs',0),'queueOldestMax':max(f.get('oldestMs',[0]),default=0),'queue':painter.get('queue'),'coverage':coverage,'stamp':stamp,'config':painter.get('config'),'drainWallSeconds':r.get('drainWallSeconds')}
 row['paintingDisabled']=any('scratches_detect.setPaintEnabled(false)' in c.get('code','') for c in r.get('cfg',{}).get('tuning',[]))
 row['noContactWork']=bool(row['scenario']!='baseline' and not row['paintingDisabled'] and (not perf.get('projectCalls') or not (r.get('detect') or {}).get('totalCalls')))
 row['fullLayerRetention']=bool(not painter.get('config',{}).get('coverageCoalescing') and 'streamLayersExpected' in stamp and stamp['streamLayersExpected']==stamp.get('streamSubstrokesTotal') and stamp.get('stampsAttempted')==stamp.get('stampsEnqueued')==perf.get('bakeLayersTotal',0)-stamp.get('streamSubstrokesTotal',0))
 row['throughputPass']=bool(fixture=='v2' and not diagnostic and not r.get('error') and group not in invalid and (coverage.get('requests',0)>0 or (row['fullLayerRetention'] and perf.get('projectCalls',0)>0)) and not any(coverage.get(k,0) for k in ['lostRequests','pendingRequests','failedRepresentatives','unrepresentedCells','trackingOverflow']) and not any(stamp.get(k,0) for k in ['aggregateDropped','jobsDropped','jobsFailed','stampsSkippedMissed','bakeFailures','layersLost','streamLayersMissed']) and row['inputToBakeMax']<=1000 and not any((painter.get('queue') or {}).values()))
 rows.append(row)
(root/'resumed-runs.json').write_text(json.dumps(rows,indent=2))
selected=[r for r in rows if r['fixture']=='v2' and not r['diagnostic'] and not r['error'] and not r['invalidLegacyReset'] and not r['noContactWork']]
groups=list(dict.fromkeys(r['group'] for r in selected))
fig,axes=plt.subplots(1,2,figsize=(14,max(5,len(groups)*.55)))
for i,g in enumerate(groups):
 rs=[r for r in selected if r['group']==g]
 axes[0].scatter([max(r['projectionMax'],r['bakeMax']) for r in rs],[i]*len(rs),s=22,alpha=.65,color='#ba382d')
 axes[1].scatter([r['inputToBakeMax'] for r in rs],[i]*len(rs),s=22,alpha=.65,color='#226da1')
for ax in axes:ax.set_yticks(range(len(groups)),groups,fontsize=8);ax.invert_yaxis();ax.grid(axis='x',alpha=.2)
axes[0].axvline(100,color='#444',ls=':');axes[0].set_xlabel('Worst native projection/bake call per run (ms)');axes[0].set_title('Native gate: 100 ms, unchanged')
axes[1].axvline(1000,color='#444',ls=':');axes[1].set_xlabel('Oldest input to completed layer, maximum (ms)');axes[1].set_title('Conservative visual-latency gate: 1000 ms')
fig.suptitle('Corrected fixture, untraced runs only; each dot is one run');fig.tight_layout();fig.savefig(root/'resumed-native-latency.png',dpi=150)
fig,ax=plt.subplots(figsize=(11,max(4,len(groups)*.45)))
for i,g in enumerate(groups):
 rs=[r for r in selected if r['group']==g]
 for field,color,offset in [('p95','#277aaf',-.15),('p99','#de891b',0),('worst','#b63730',.15)]:
  ax.scatter([r['frames'][field] for r in rs],[i+offset]*len(rs),s=18,color=color,alpha=.6,label=field if i==0 else None)
ax.set_yticks(range(len(groups)),groups,fontsize=8);ax.invert_yaxis();ax.set(xlabel='Whole-frame wall time (ms)',title='Corrected fixture frame tails: no averaging away outliers');ax.legend();fig.tight_layout();fig.savefig(root/'resumed-frame-tails.png',dpi=150)
lines=['# Resumed milestone 5 measured cohorts','','Per-run raw results and full percentile/counter data: [resumed-runs.json](resumed-runs.json).','perFrameStages contains accumulated native work per frame; nativeTimingProfile contains call/batch p95/p99 upper bin bounds where instrumented.','Physics contacts vary between identical scripted launches. No cache deletion.','','| Cohort | Runs | Worst frame p95 / p99 / max (ms) | Native max (ms) | Completed-layer age max (ms) | Queue-cap losses |','| --- | ---: | --- | ---: | ---: | ---: |']
for g in groups:
 rs=[r for r in selected if r['group']==g]
 lines.append(f"| {g} | {len(rs)} | "+' / '.join(f'{max(r["frames"][k] for r in rs):.1f}' for k in ['p95','p99','worst'])+f" | {max(max(r['projectionMax'],r['bakeMax']) for r in rs):.1f} | {max(r['inputToBakeMax'] for r in rs):.1f} | {sum(r['stamp'].get('jobsDropped',0)+r['stamp'].get('aggregateDropped',0) for r in rs)} |")
lines+=['','## Native call and batch tails','','Each value is the largest per-run percentile bound in that cohort, not a pooled percentile.','Exact worsts are retained separately. Earlier runs without call histograms are omitted here.','','| Cohort | Projection p95 / p99 / worst (ms) | Bake batch p95 / p99 / worst (ms) |','| --- | --- | --- |']
for g in groups:
 rs=[r for r in selected if r['group']==g and r.get('nativeTimingProfile')]
 if not rs:continue
 vals=[]
 for stage in ['project','bakeBatch']:
  stages=[r['nativeTimingProfile'][stage] for r in rs]
  cells=[]
  for q in ['p95','p99']:
   if any('aboveMs' in d.get(q,{}) for d in stages):cells.append('>1000')
   else:cells.append(f"{max(d.get(q,{}).get('upperMs',0) for d in stages):.1f}")
  cells.append(f"{max(d['maxMs'] for d in stages):.1f}");vals.append(' / '.join(cells))
 lines.append('| '+g+' | '+' | '.join(vals)+' |')
lines+=['','## Discrete representative coverage','','Cells are per-run proxy counts summed, not unique body pixels across the cohort.','Stream shaping, detector caps and spot saturation are separate counters in raw results.','','| Cohort | Requests / completed | Deliberately merged | Lost / pending | Missing proxy cells |','| --- | --- | --- | --- | --- |']
for g in groups:
 rs=[r for r in selected if r['group']==g and r['coverage'].get('requests',0)>0]
 if not rs:continue
 cs=[r['coverage'] for r in rs]
 total=lambda key:sum(c.get(key,0) for c in cs)
 lines.append(f"| {g} | {total('requests')} / {total('completedRequests')} | {total('mergedQueued')+total('mergedBaked')} | {total('lostRequests')} / {total('pendingRequests')} | {total('unrepresentedCells')} |")
lines+=['','These are observed bounds, not guarantees. Disabled controls have no painting latency.','Diagnostic traced cohorts and old v1/reset-invalid runs remain in JSON but are excluded above.','![](resumed-native-latency.png)','','![](resumed-frame-tails.png)']
(root/'resumed-summary.md').write_text('\n'.join(lines)+'\n')
print('Retained',len(rows),'runs;',len(selected),'corrected/untraced')
for p in root.glob('resumed-*/memory.json'):
 data=json.loads(p.read_text());fig,ax=plt.subplots(figsize=(9,4));ax.plot([x['elapsed']/60 for x in data],[x['privateBytes']/2**30 for x in data],marker='.',ms=3)
 ax.set(xlabel='Elapsed minutes',ylabel='Whole-process private memory (GiB)',title=p.parent.name+'; not dedicated GPU allocation');fig.tight_layout();fig.savefig(p.parent/'memory.png',dpi=150);plt.close(fig)
