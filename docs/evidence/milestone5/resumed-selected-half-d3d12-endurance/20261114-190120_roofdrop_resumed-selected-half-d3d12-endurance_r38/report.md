# roofdrop - 20261114-190120_roofdrop_resumed-selected-half-d3d12-endurance_r38

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 7.829 s - 679 frames, 86.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1984 | 65 | 64 | 0 | 58 | 17 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1130, BelowThresh 789

Body materials: METAL 63, PLASTIC 2

Surfaces: ASPHALT 65

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.835 | 1.592 | 34.045 |
| whole frame, ms | 11.263 (p50) | 12.719 | 42.397 |
| all GE Lua, ms | | 2.607 | 34.805 |
| physics + vehicle Lua, ms | | 0.071 | 0.163 |
| render, ms | | 2.168 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 34.012 ms, worst composite 0.11 ms.
- Detector: 1.254 us per contact, 5.741 ms total, worst frame 0.359 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 6.38 | 42.40 | 31.32 | 0.72 | 0.03 | 1.80 |
| 0.53 | 41.94 | 30.15 | 0.77 | 0.09 | 1.89 |
| 1.46 | 41.52 | 34.04 | 0.71 | 0.04 | 1.41 |
| 1.13 | 41.42 | 29.87 | 0.80 | 0.03 | 1.99 |
| 0.81 | 40.89 | 29.68 | 0.98 | 0.08 | 1.85 |
