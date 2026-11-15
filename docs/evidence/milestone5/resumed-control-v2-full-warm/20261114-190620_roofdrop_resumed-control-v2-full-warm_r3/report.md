# roofdrop - 20261114-190620_roofdrop_resumed-control-v2-full-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 5.102 s - 437 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1146 | 53 | 53 | 0 | 51 | 16 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 627, BelowThresh 466

Body materials: METAL 52, PLASTIC 1

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.471 | 10.911 | 35.494 |
| whole frame, ms | 11.294 (p50) | 18.725 | 46.291 |
| all GE Lua, ms | | 11.71 | 36.376 |
| physics + vehicle Lua, ms | | 0.069 | 0.148 |
| render, ms | | 2.235 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 34.922 ms, worst composite 0.089 ms.
- Detector: 1.348 us per contact, 3.627 ms total, worst frame 0.366 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.57 | 46.29 | 34.95 | 0.84 | 0.04 | 1.93 |
| 0.53 | 45.94 | 34.65 | 0.72 | 0.06 | 1.79 |
| 0.73 | 44.19 | 32.90 | 0.84 | 0.05 | 2.21 |
| 0.95 | 43.88 | 35.49 | 32.26 | 0.05 | 1.96 |
| 2.20 | 43.22 | 31.38 | 0.76 | 0.04 | 2.18 |
