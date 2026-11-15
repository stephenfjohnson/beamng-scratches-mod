# roofdrop - 20261114-171102_roofdrop_candidate-reflections-off_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.959 s - 369 frames, 74.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 993 | 47 | 47 | 0 | 59 | 19 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 587, BelowThresh 359

Body materials: METAL 45, PLASTIC 2

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.239 | 22.987 | 49.588 |
| whole frame, ms | 11.3 (p50) | 34.844 | 62.033 |
| all GE Lua, ms | | 24.28 | 50.732 |
| physics + vehicle Lua, ms | | 0.128 | 2.935 |
| render, ms | | 3.217 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 49.536 ms, worst composite 0.099 ms.
- Detector: 1.907 us per contact, 4.572 ms total, worst frame 0.598 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.74 | 62.03 | 48.64 | 46.39 | 0.11 | 2.88 |
| 1.16 | 61.66 | 49.59 | 1.31 | 1.09 | 2.78 |
| 0.73 | 57.37 | 45.03 | 0.84 | 0.05 | 2.53 |
| 0.76 | 55.89 | 41.04 | 50.05 | 0.06 | 1.73 |
| 0.99 | 54.86 | 45.34 | 36.76 | 0.06 | 1.81 |
