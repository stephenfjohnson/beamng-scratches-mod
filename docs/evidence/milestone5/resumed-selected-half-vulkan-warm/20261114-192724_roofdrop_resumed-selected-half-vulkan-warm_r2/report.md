# roofdrop - 20261114-192724_roofdrop_resumed-selected-half-vulkan-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.346 s - 415 frames, 77.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1104 | 55 | 55 | 0 | 59 | 14 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 607, BelowThresh 442

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.218 | 0.764 | 38.047 |
| whole frame, ms | 12.55 (p50) | 14.503 | 50.022 |
| all GE Lua, ms | | 1.691 | 38.937 |
| physics + vehicle Lua, ms | | 0.07 | 0.187 |
| render, ms | | 1.576 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 38.026 ms, worst composite 0.049 ms.
- Detector: 1.357 us per contact, 3.749 ms total, worst frame 0.389 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.52 | 50.02 | 38.05 | 0.87 | 0.05 | 1.29 |
| 1.82 | 49.67 | 37.32 | 0.77 | 0.03 | 1.05 |
| 2.20 | 49.36 | 35.95 | 0.72 | 0.04 | 1.14 |
| 1.13 | 48.22 | 36.32 | 0.79 | 0.04 | 1.36 |
| 0.80 | 48.06 | 35.49 | 0.74 | 0.05 | 1.32 |
