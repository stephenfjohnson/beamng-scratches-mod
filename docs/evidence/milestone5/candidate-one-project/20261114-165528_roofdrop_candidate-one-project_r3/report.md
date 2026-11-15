# roofdrop - 20261114-165528_roofdrop_candidate-one-project_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: True after 6.184 s - 469 frames, 75.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1312 | 59 | 59 | 0 | 55 | 21 | 23 | 0.0% | 0 | 18 |

Rejected contacts: PartExcluded 813, BelowThresh 440

Body materials: METAL 57, PLASTIC 2

Surfaces: ASPHALT 59

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.982 | 20.202 | 43.106 |
| whole frame, ms | 11.404 (p50) | 31.426 | 54.321 |
| all GE Lua, ms | | 21.318 | 44.226 |
| physics + vehicle Lua, ms | | 0.125 | 1.404 |
| render, ms | | 3.757 | |

- Painter frames over 4 ms: 44; worst flush (project + bake) 35.147 ms, worst composite 0.119 ms.
- Detector: 2.098 us per contact, 6.443 ms total, worst frame 0.801 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.59 | 54.32 | 43.11 | 18.13 | 0.08 | 2.78 |
| 1.39 | 53.69 | 42.73 | 38.76 | 0.07 | 2.84 |
| 1.37 | 47.59 | 37.48 | 33.39 | 0.06 | 2.50 |
| 5.22 | 47.53 | 35.19 | 1.11 | 0.08 | 3.45 |
| 0.54 | 44.25 | 33.96 | 31.33 | 0.20 | 3.50 |
