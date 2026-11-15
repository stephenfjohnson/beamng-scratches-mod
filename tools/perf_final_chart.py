"""Focused static comparison; raw cohorts remain in resumed-runs.json."""
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
root=Path('docs/evidence/milestone5');rows=json.loads((root/'resumed-runs.json').read_text())
groups=[
 ('resumed-control-v2-full-vulkan','Full-resolution control, warm\nbake6 / flush0.2 / grouping off'),
 ('resumed-fixed2-full-vulkan-cold','Final full-detail candidate, fresh process\nbake3 / flush0.05 / grouping on'),
 ('resumed-fixed2-full-vulkan-warm','Final full-detail candidate, warm'),
 ('resumed-fixed2-full-vulkan-endurance','Final full-detail candidate, 10-minute session'),
]
fig,axes=plt.subplots(1,2,figsize=(12,5),sharey=True)
for i,(group,label) in enumerate(groups):
 rs=[r for r in rows if r['group']==group and not r['error']]
 if not rs:raise RuntimeError('missing cohort: '+group)
 for ax,values,color in [(axes[0],[max(r['projectionMax'],r['bakeMax']) for r in rs],'#b4372f'),(axes[1],[r['inputToBakeMax'] for r in rs],'#2676a6')]:
  ax.scatter(values,[i]*len(rs),s=35,alpha=.6,color=color)
  ax.annotate(f'{max(values):.0f} ms',(max(values),i),xytext=(5,-16),textcoords='offset points',fontsize=9,color=color)
axes[0].set_yticks(range(len(groups)),[label for _,label in groups],fontsize=9);axes[0].invert_yaxis()
axes[0].axvline(100,color='#555',ls=':');axes[0].set_title('Worst native call / batch per run');axes[0].set_xlabel('Elapsed milliseconds; gate = 100')
axes[1].axvline(1000,color='#555',ls=':');axes[1].set_title('Oldest input to completed layer per run');axes[1].set_xlabel('Elapsed milliseconds; gate = 1000')
for ax in axes:ax.grid(axis='x',alpha=.2);ax.set_xlim(0,max(ax.get_xlim()[1]*1.1,150))
fig.suptitle('Vulkan / 4096×2048 damage / coalescing off: latency and native stalls are separate gates',fontsize=12)
fig.text(.5,.015,'Each dot is a real fixture. Physics contacts vary; control uses M5 resource fixes, not the untouched M4 binary. No GPU execution-time claim.',ha='center',fontsize=8)
fig.tight_layout(rect=(0,.05,1,.96));fig.savefig(root/'resumed-final-comparison.png',dpi=160)
