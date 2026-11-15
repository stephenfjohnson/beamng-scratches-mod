# roofdrop - 20261114-185641_roofdrop_resumed-selected-half-d3d12-endurance_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.156 s - 449 frames, 86.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1200 | 52 | 52 | 0 | 56 | 14 | 21 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 704, BelowThresh 444

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.095 | 4.529 | 30.833 |
| whole frame, ms | 11.101 (p50) | 13.855 | 41.939 |
| all GE Lua, ms | | 5.593 | 31.785 |
| physics + vehicle Lua, ms | | 0.072 | 0.28 |
| render, ms | | 2.183 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 30.81 ms, worst composite 0.059 ms.
- Detector: 1.239 us per contact, 3.812 ms total, worst frame 0.349 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 41.94 | 30.56 | 0.80 | 0.04 | 1.81 |
| 0.52 | 41.69 | 30.83 | 0.72 | 0.05 | 1.79 |
| 1.13 | 41.62 | 29.79 | 0.82 | 0.07 | 2.07 |
| 1.84 | 41.60 | 30.05 | 0.86 | 0.07 | 1.66 |
| 2.47 | 41.06 | 29.52 | 0.82 | 0.04 | 1.85 |
