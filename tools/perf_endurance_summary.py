"""Compact summary of a long endurance cohort, for publishing without raw frames.

Long sessions produce ~50 MB of per-frame JSON per ten minutes. This writes
summary.json (one row per fixture: native/bake maxima and call percentiles,
completed-layer age, frame p95/p99/worst with the phase that carried the worst
frame, layer conservation and loss counters) plus manifest.json (SHA256 of every
raw file). With --move-raw-to, raw fixture folders are moved to that local
(ignored) directory and only the summary, manifest, memory and environment files
stay in docs/evidence. Nothing is recomputed from averages.

    python tools/perf_endurance_summary.py --label my-long --move-raw-to bench/raw
"""
import argparse, hashlib, json, shutil
from pathlib import Path
import bench

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--label', required=True)
p.add_argument('--move-raw-to')
a = p.parse_args()
root = Path('docs/evidence/milestone5') / a.label
PHASES = ['Lua', 'LuaGC', 'PhysicsAndVLUA', 'Render', 'RenderShadows', 'OtherRender', 'FramePresent', 'WaitNextFrame']
LOSS = ['aggregateDropped', 'jobsDropped', 'jobsFailed', 'stampsSkippedMissed', 'bakeFailures', 'layersLost', 'streamLayersMissed']
rows, manifest = [], {}
for run in sorted(d for d in root.iterdir() if d.is_dir()):
    for f in sorted(run.rglob('*')):
        if f.is_file():
            manifest[str(f.relative_to(root)).replace('\\', '/')] = hashlib.sha256(f.read_bytes()).hexdigest()
    res = run / 'result.json'
    if not res.exists():
        rows.append({'run': run.name, 'error': 'no result.json'})
        continue
    r = json.loads(res.read_text())
    pa = r.get('painter') or r.get('lastValidPainterStats') or {}
    perf, st, fr = pa.get('perf', {}), pa.get('stamp', {}), r.get('frames') or {}
    xs = fr.get('frameMs', [])
    worst = max(range(len(xs)), key=xs.__getitem__) if xs else None
    phase = None
    if worst is not None:
        cands = {k: fr[k][worst] for k in PHASES if k in fr and len(fr[k]) > worst}
        phase = max(cands, key=cands.get) if cands else None
    rows.append({
        'run': run.name, 'scenario': r.get('name'), 'error': r.get('error'),
        'nativeProjectionMaxMs': perf.get('projectMsMax', 0), 'bakeBatchMaxMs': perf.get('bakeMsMax', 0),
        'nativeTimingProfile': r.get('nativeTimingProfile'),
        'completedLayerAgeMaxMs': perf.get('inputToBakeMaxMs', 0),
        'frames': {'samples': len(xs), 'p95': bench.pct(xs, 95), 'p99': bench.pct(xs, 99), 'worst': max(xs, default=0),
                   'worstPhase': phase, 'worstPhaseMs': fr[phase][worst] if phase else None},
        'layers': {'discreteAttempted': st.get('stampsAttempted'), 'discreteEnqueued': st.get('stampsEnqueued'),
                   'streamExpected': st.get('streamLayersExpected'), 'streamCaptured': st.get('streamSubstrokesTotal'),
                   'baked': perf.get('bakeLayersTotal'), 'synthesizedAnchors': (pa.get('anchors') or {}).get('synthesized')},
        'losses': {k: st.get(k, 0) for k in LOSS}, 'finalQueue': pa.get('queue'), 'generation': pa.get('generation'),
    })
summary = {'label': a.label, 'fixtures': len(rows), 'rows': rows,
           'maxima': {'native': max((max(x.get('nativeProjectionMaxMs', 0), x.get('bakeBatchMaxMs', 0)) for x in rows), default=0),
                      'completedLayerAge': max((x.get('completedLayerAgeMaxMs', 0) for x in rows), default=0),
                      'frameWorst': max((x.get('frames', {}).get('worst', 0) for x in rows), default=0)},
           'nativeOver100': [x['run'] for x in rows if max(x.get('nativeProjectionMaxMs', 0), x.get('bakeBatchMaxMs', 0)) > 100],
           'framesOver100': [[x['run'], round(x['frames']['worst'], 1), x['frames']['worstPhase']] for x in rows if x.get('frames', {}).get('worst', 0) > 100],
           'totalLosses': sum(sum(x.get('losses', {}).values()) for x in rows),
           'errors': [x['run'] for x in rows if x.get('error')]}
(root / 'summary.json').write_text(json.dumps(summary, indent=2))
(root / 'manifest.json').write_text(json.dumps(manifest, indent=2))
print(json.dumps({k: v for k, v in summary.items() if k != 'rows'}, indent=2))
if a.move_raw_to:
    dest = Path(a.move_raw_to) / a.label
    dest.mkdir(parents=True, exist_ok=True)
    for run in [d for d in root.iterdir() if d.is_dir()]:
        shutil.move(str(run), str(dest / run.name))
    (root / 'RAW-LOCAL.txt').write_text(f'Raw per-fixture folders moved to the local, git-ignored {dest.as_posix()} '
                                        'to keep the repository small. manifest.json lists their SHA256 hashes.\n')
