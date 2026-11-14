# roofdrop - 20261114-165311_roofdrop_candidate-d3d12-warm_r1

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 6.468 s - 545 frames, 84.1 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1491 | 61 | 61 | 0 | 56 | 21 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 831, BelowThresh 599

Body materials: METAL 59, PLASTIC 2

Surfaces: ASPHALT 61

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.415 | 7.046 | 39.498 |
| whole frame, ms | 10.998 (p50) | 22.062 | 49.622 |
| all GE Lua, ms | | 8.138 | 40.725 |
| physics + vehicle Lua, ms | | 0.092 | 0.19 |
| render, ms | | 3.066 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 38.193 ms, worst composite 0.113 ms.
- Detector: 1.952 us per contact, 6.674 ms total, worst frame 0.71 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 49.62 | 39.50 | 34.28 | 0.17 | 3.30 |
| 1.54 | 48.47 | 38.24 | 0.91 | 0.05 | 1.96 |
| 0.96 | 46.00 | 38.64 | 36.10 | 0.07 | 1.76 |
| 0.73 | 45.81 | 31.90 | 0.85 | 0.07 | 3.29 |
| 1.15 | 44.97 | 35.61 | 21.11 | 0.06 | 2.14 |
