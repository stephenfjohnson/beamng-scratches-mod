# roofdrop - 20261114-190937_roofdrop_resumed-selected-half-d3d12-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.121 s - 451 frames, 87.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1202 | 51 | 51 | 0 | 53 | 13 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 690, BelowThresh 461

Body materials: METAL 50, PLASTIC 1

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.013 | 4.638 | 30.136 |
| whole frame, ms | 10.942 (p50) | 14.318 | 41.467 |
| all GE Lua, ms | | 5.866 | 31.222 |
| physics + vehicle Lua, ms | | 0.079 | 0.415 |
| render, ms | | 2.173 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 30.086 ms, worst composite 0.122 ms.
- Detector: 1.459 us per contact, 4.224 ms total, worst frame 0.573 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.52 | 41.47 | 30.14 | 0.87 | 0.05 | 1.84 |
| 2.48 | 40.96 | 30.07 | 0.79 | 0.03 | 1.57 |
| 0.79 | 40.92 | 29.29 | 0.79 | 0.04 | 1.96 |
| 2.20 | 40.43 | 28.75 | 1.07 | 0.05 | 1.65 |
| 1.40 | 40.40 | 28.93 | 0.78 | 0.04 | 1.65 |
