# roofdrop - 20261114-191319_roofdrop_resumed-grouped-quarter-d3d12_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 7.755 s - 662 frames, 85.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1917 | 59 | 58 | 0 | 59 | 19 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1154, BelowThresh 704

Body materials: METAL 58, PLASTIC 1

Surfaces: ASPHALT 59

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.838 | 1.861 | 31.07 |
| whole frame, ms | 11.323 (p50) | 13.419 | 43.309 |
| all GE Lua, ms | | 3.044 | 32.025 |
| physics + vehicle Lua, ms | | 0.083 | 0.299 |
| render, ms | | 2.76 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 31.038 ms, worst composite 0.103 ms.
- Detector: 1.649 us per contact, 6.936 ms total, worst frame 0.455 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.96 | 43.31 | 31.07 | 0.77 | 0.03 | 1.85 |
| 0.52 | 42.48 | 30.56 | 0.85 | 0.05 | 1.68 |
| 6.50 | 42.14 | 29.79 | 0.94 | 0.07 | 2.18 |
| 3.60 | 41.52 | 30.48 | 0.88 | 0.07 | 1.71 |
| 2.21 | 40.50 | 28.87 | 0.99 | 0.08 | 2.56 |
