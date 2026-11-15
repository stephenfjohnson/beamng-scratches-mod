# roofdrop - 20261114-192809_roofdrop_resumed-selected-half-vulkan-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.018 s - 387 frames, 76.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1057 | 46 | 46 | 0 | 53 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 602, BelowThresh 409

Body materials: METAL 45, PLASTIC 1

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.5 | 0.859 | 38.29 |
| whole frame, ms | 12.493 (p50) | 14.798 | 50.866 |
| all GE Lua, ms | | 1.903 | 39.303 |
| physics + vehicle Lua, ms | | 0.069 | 0.243 |
| render, ms | | 1.615 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 38.268 ms, worst composite 0.044 ms.
- Detector: 1.347 us per contact, 3.623 ms total, worst frame 0.513 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 50.87 | 38.29 | 0.72 | 0.05 | 1.24 |
| 0.53 | 50.68 | 37.89 | 0.81 | 0.09 | 1.15 |
| 1.13 | 49.94 | 37.13 | 0.70 | 0.06 | 1.40 |
| 3.73 | 49.53 | 34.97 | 0.93 | 0.06 | 1.86 |
| 1.84 | 49.27 | 37.17 | 0.72 | 0.06 | 1.16 |
