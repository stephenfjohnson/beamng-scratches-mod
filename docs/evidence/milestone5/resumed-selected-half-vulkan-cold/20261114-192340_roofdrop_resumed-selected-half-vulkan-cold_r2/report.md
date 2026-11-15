# roofdrop - 20261114-192340_roofdrop_resumed-selected-half-vulkan-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.181 s - 455 frames, 73.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1269 | 55 | 55 | 0 | 58 | 17 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 726, BelowThresh 488

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.353 | 0.671 | 58.229 |
| whole frame, ms | 12.559 (p50) | 22.809 | 77.437 |
| all GE Lua, ms | | 1.728 | 59.346 |
| physics + vehicle Lua, ms | | 0.07 | 1.346 |
| render, ms | | 1.579 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 58.205 ms, worst composite 0.108 ms.
- Detector: 1.371 us per contact, 4.182 ms total, worst frame 0.499 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 77.44 | 58.23 | 0.81 | 0.08 | 1.42 |
| 1.15 | 49.95 | 37.27 | 0.76 | 0.07 | 1.26 |
| 5.12 | 49.54 | 36.69 | 0.77 | 0.05 | 1.24 |
| 0.83 | 49.05 | 36.81 | 0.80 | 0.06 | 1.36 |
| 4.28 | 48.93 | 36.25 | 0.73 | 0.06 | 1.20 |
