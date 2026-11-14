# roofdrop - 20261114-165434_roofdrop_candidate-one-project_r1

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: True after 5.103 s - 405 frames, 79.2 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 983 | 49 | 49 | 0 | 51 | 17 | 18 | 0.0% | 0 | 15 |

Rejected contacts: PartExcluded 590, BelowThresh 344

Body materials: METAL 48, PLASTIC 1

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.984 | 19.667 | 39.545 |
| whole frame, ms | 11.074 (p50) | 32.092 | 50.939 |
| all GE Lua, ms | | 20.674 | 40.635 |
| physics + vehicle Lua, ms | | 0.096 | 0.385 |
| render, ms | | 3.348 | |

- Painter frames over 4 ms: 35; worst flush (project + bake) 30.985 ms, worst composite 0.111 ms.
- Detector: 2.081 us per contact, 5.204 ms total, worst frame 0.811 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.74 | 50.94 | 39.54 | 19.69 | 0.08 | 3.10 |
| 1.36 | 46.27 | 36.37 | 31.34 | 0.06 | 2.63 |
| 2.80 | 44.65 | 29.25 | 1.08 | 0.05 | 2.70 |
| 3.42 | 42.84 | 30.87 | 1.28 | 0.06 | 1.91 |
| 3.84 | 42.49 | 31.04 | 0.91 | 0.11 | 2.10 |
