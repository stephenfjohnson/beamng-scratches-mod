# roofdrop - 20261114-184543_roofdrop_resumed-grouped-half-untraced_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.004 s - 436 frames, 86.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1187 | 46 | 46 | 0 | 52 | 15 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 697, BelowThresh 444

Body materials: METAL 44, PLASTIC 2

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.131 | 4.446 | 31.141 |
| whole frame, ms | 11.113 (p50) | 13.105 | 42.082 |
| all GE Lua, ms | | 5.32 | 32.006 |
| physics + vehicle Lua, ms | | 0.07 | 0.21 |
| render, ms | | 2.188 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 31.115 ms, worst composite 0.073 ms.
- Detector: 1.218 us per contact, 3.518 ms total, worst frame 0.447 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.52 | 42.08 | 30.18 | 0.95 | 0.05 | 1.81 |
| 3.75 | 41.78 | 30.78 | 0.91 | 0.05 | 1.67 |
| 1.13 | 41.42 | 29.84 | 0.76 | 0.05 | 1.79 |
| 0.80 | 41.33 | 30.32 | 0.75 | 0.04 | 1.81 |
| 2.20 | 41.17 | 29.82 | 0.93 | 0.04 | 1.79 |
