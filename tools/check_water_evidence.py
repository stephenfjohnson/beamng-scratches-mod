"""Check recorded final water runs; rendering still requires image inspection."""
import json
from pathlib import Path
for kind in ['mud','dirt','snow']:
    d=json.loads((Path('docs/evidence/milestone3')/(kind+'-final')/'water.json').read_text())
    surface=lambda k:d[k]['state']['surface']
    assert surface('dirty')['deposits']>0,kind
    assert surface('shallow')['soilRemaining']==1,kind
    assert 0<surface('deep-progress')['soilRemaining']<1,kind
    assert surface('deep-washed')['deposits']==0,kind
    assert surface('pauseStart')==surface('pauseEnd'),kind
    assert surface('dry')['wetness']==0,kind
    for change in d['washed-wet']['config']['comparison']['differences']:
        assert change['field'] in {'clearCoatFactor','clearCoatRoughnessFactor'}, (kind,change)
    assert not d['dry']['config']['comparison']['differences'],kind
    assert surface('redirty')['deposits']>0,kind
    assert d['dry']['state']['stats']['perf']['bakeLayersTotal']==0,kind
    print(kind,'passed recorded state checks; inspect PNGs for visual acceptance')
