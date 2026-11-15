# roofdrop - 20261114-184628_roofdrop_resumed-grouped-half-untraced_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.964 s - 431 frames, 86.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1169 | 49 | 49 | 0 | 53 | 17 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 680, BelowThresh 440

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.25 | 4.376 | 30.805 |
| whole frame, ms | 11.095 (p50) | 14.218 | 43.549 |
| all GE Lua, ms | | 5.286 | 32.007 |
| physics + vehicle Lua, ms | | 0.078 | 0.21 |
| render, ms | | 2.253 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 30.774 ms, worst composite 0.071 ms.
- Detector: 1.323 us per contact, 3.617 ms total, worst frame 0.326 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.47 | 43.55 | 29.84 | 0.78 | 0.03 | 1.66 |
| 1.13 | 41.85 | 29.94 | 1.40 | 0.08 | 1.82 |
| 0.52 | 41.67 | 30.05 | 0.86 | 0.10 | 1.95 |
| 3.71 | 41.67 | 30.23 | 0.80 | 0.04 | 1.63 |
| 0.80 | 41.40 | 30.17 | 0.82 | 0.05 | 1.77 |
