# roofdrop - 20261114-193018_roofdrop_resumed-control-v2-full-vulkan_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 6.173 s - 466 frames, 71.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1296 | 53 | 53 | 0 | 49 | 18 | 14 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 775, BelowThresh 468

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.973 | 1.126 | 40.501 |
| whole frame, ms | 12.735 (p50) | 15.204 | 470.612 |
| all GE Lua, ms | | 2.608 | 41.301 |
| physics + vehicle Lua, ms | | 0.074 | 0.546 |
| render, ms | | 1.69 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 40.476 ms, worst composite 0.053 ms.
- Detector: 1.385 us per contact, 5.663 ms total, worst frame 1.57 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.73 | 470.61 | 18.29 | 0.97 | 0.06 | 1.69 |
| 2.28 | 53.28 | 40.50 | 0.86 | 0.08 | 1.34 |
| 1.57 | 51.73 | 38.91 | 1.06 | 0.05 | 1.22 |
| 1.15 | 50.60 | 36.88 | 0.95 | 0.04 | 1.24 |
| 1.37 | 50.25 | 37.31 | 1.11 | 0.06 | 1.20 |
