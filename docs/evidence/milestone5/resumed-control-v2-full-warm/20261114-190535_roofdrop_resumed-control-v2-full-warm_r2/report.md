# roofdrop - 20261114-190535_roofdrop_resumed-control-v2-full-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 5.112 s - 444 frames, 82.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1144 | 53 | 53 | 0 | 47 | 17 | 14 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 624, BelowThresh 467

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.407 | 6.538 | 40.29 |
| whole frame, ms | 11.294 (p50) | 17.938 | 52.074 |
| all GE Lua, ms | | 7.544 | 41.075 |
| physics + vehicle Lua, ms | | 0.069 | 0.19 |
| render, ms | | 2.319 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 40.24 ms, worst composite 0.074 ms.
- Detector: 1.46 us per contact, 4.234 ms total, worst frame 0.464 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.55 | 52.07 | 40.29 | 0.79 | 0.04 | 1.77 |
| 0.73 | 46.86 | 35.86 | 0.71 | 0.04 | 2.03 |
| 2.40 | 44.37 | 32.85 | 0.83 | 0.04 | 1.88 |
| 1.14 | 43.34 | 30.63 | 0.93 | 0.05 | 2.23 |
| 0.94 | 42.55 | 31.05 | 1.01 | 0.05 | 1.95 |
