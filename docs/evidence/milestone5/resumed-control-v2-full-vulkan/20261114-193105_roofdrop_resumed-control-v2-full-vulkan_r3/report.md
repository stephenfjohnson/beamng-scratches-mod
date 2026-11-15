# roofdrop - 20261114-193105_roofdrop_resumed-control-v2-full-vulkan_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 5.121 s - 386 frames, 75.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 989 | 53 | 53 | 0 | 59 | 18 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 557, BelowThresh 379

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.36 | 4.945 | 39.69 |
| whole frame, ms | 12.795 (p50) | 16.837 | 54.508 |
| all GE Lua, ms | | 6.177 | 41.105 |
| physics + vehicle Lua, ms | | 0.071 | 0.184 |
| render, ms | | 1.589 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 39.656 ms, worst composite 0.115 ms.
- Detector: 1.55 us per contact, 3.444 ms total, worst frame 0.359 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.56 | 54.51 | 39.69 | 0.95 | 0.06 | 1.71 |
| 0.94 | 51.29 | 38.72 | 0.95 | 0.05 | 1.23 |
| 2.47 | 50.71 | 38.25 | 0.85 | 0.05 | 1.11 |
| 0.73 | 50.64 | 37.46 | 0.86 | 0.05 | 1.45 |
| 2.24 | 50.51 | 38.49 | 0.81 | 0.05 | 1.18 |
