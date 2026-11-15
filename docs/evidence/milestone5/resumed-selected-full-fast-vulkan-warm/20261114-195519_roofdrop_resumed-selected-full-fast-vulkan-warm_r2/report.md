# roofdrop - 20261114-195519_roofdrop_resumed-selected-full-fast-vulkan-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.981 s - 370 frames, 74.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 903 | 46 | 45 | 0 | 60 | 18 | 28 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 540, BelowThresh 317

Body materials: METAL 44, PLASTIC 2

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.708 | 7.868 | 36.902 |
| whole frame, ms | 12.386 (p50) | 18.113 | 49.823 |
| all GE Lua, ms | | 9.075 | 37.926 |
| physics + vehicle Lua, ms | | 0.097 | 0.232 |
| render, ms | | 1.873 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 36.881 ms, worst composite 0.115 ms.
- Detector: 1.623 us per contact, 3.621 ms total, worst frame 0.378 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.84 | 49.82 | 35.78 | 1.95 | 0.07 | 1.30 |
| 2.47 | 49.46 | 36.89 | 1.17 | 0.10 | 1.24 |
| 1.41 | 49.34 | 35.04 | 1.02 | 0.05 | 1.42 |
| 3.69 | 49.14 | 36.90 | 0.73 | 0.04 | 1.21 |
| 0.81 | 49.08 | 32.87 | 0.94 | 0.10 | 1.39 |
