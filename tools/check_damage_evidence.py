"""Recorded milestone-4 invariants; cannot substitute for reviewing engine PNGs."""
import json
from pathlib import Path
root=Path('docs/evidence/milestone4')
for case in ['accepted-plain-dark','tone-plain-light','accepted-police-dark-roof','accepted-police-light','impact-police']:
 folder=root/case;d=json.loads((folder/'state.json').read_text())
 assert d['compatibility']['ready'] and d['compatibility']['adapter']
 assert not d['comparison']['differences'],case
 assert all((folder/(name+'.png')).is_file() for name in ['damaged','original-stages','reset']),case
 r=json.loads((folder/'result.json').read_text())
 assert all(v==0 for v in r['painter']['queue'].values()),case
 assert r['painter']['stamp']['jobsFailed']==0,case
 print(case,'material/capture/queue checks passed')
for case in ['accepted-water','persistence']:
 d=json.loads((root/case/'water.json').read_text());surface=lambda k:d[k]['state']['surface']
 assert surface('dirty')['deposits']>0,case
 assert surface('shallow')['soilRemaining']==1,case
 assert 0<surface('deep-progress')['soilRemaining']<1,case
 assert surface('deep-washed')['deposits']==0,case
 assert surface('pauseStart')==surface('pauseEnd'),case
 assert surface('dry')['wetness']==0 and not d['dry']['config']['comparison']['differences'],case
 assert surface('redirty')['deposits']>0,case
 assert d['dry']['state']['stats']['perf']['bakeLayersTotal']==0,case
 print(case,'wash/pause/dry/re-deposition checks passed')
print('Inspect PNGs separately for scratch visibility and persistence.')
