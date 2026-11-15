# roofdrop - 20261114-191112_roofdrop_resumed-selected-half-d3d12-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.44 s - 479 frames, 87.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1325 | 49 | 49 | 0 | 52 | 16 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 750, BelowThresh 526

Body materials: METAL 48, PLASTIC 1

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.072 | 4.382 | 30.944 |
| whole frame, ms | 10.928 (p50) | 13.32 | 41.679 |
| all GE Lua, ms | | 5.267 | 31.871 |
| physics + vehicle Lua, ms | | 0.07 | 0.209 |
| render, ms | | 2.156 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 30.87 ms, worst composite 0.121 ms.
- Detector: 1.386 us per contact, 4.443 ms total, worst frame 0.581 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.47 | 41.68 | 30.74 | 0.78 | 0.04 | 1.62 |
| 3.64 | 41.12 | 29.67 | 0.85 | 0.04 | 1.66 |
| 0.52 | 41.01 | 28.97 | 0.90 | 0.04 | 2.00 |
| 1.12 | 40.73 | 28.87 | 0.86 | 0.05 | 1.72 |
| 2.20 | 40.31 | 29.20 | 0.92 | 0.04 | 1.74 |
