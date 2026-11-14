# roofdrop - 20261114-165339_roofdrop_candidate-d3d12-warm_r2

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 6.633 s - 532 frames, 80.0 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1419 | 61 | 61 | 0 | 61 | 23 | 19 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 849, BelowThresh 509

Body materials: METAL 59, PLASTIC 2

Surfaces: ASPHALT 61

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.513 | 11.953 | 41.777 |
| whole frame, ms | 11.222 (p50) | 22.607 | 50.839 |
| all GE Lua, ms | | 12.85 | 42.975 |
| physics + vehicle Lua, ms | | 0.103 | 1.83 |
| render, ms | | 3.186 | |

- Painter frames over 4 ms: 34; worst flush (project + bake) 34.573 ms, worst composite 0.095 ms.
- Detector: 1.967 us per contact, 6.451 ms total, worst frame 0.796 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.97 | 50.84 | 41.78 | 38.66 | 0.08 | 1.96 |
| 0.54 | 49.42 | 38.46 | 33.60 | 0.18 | 3.27 |
| 0.96 | 49.00 | 37.67 | 17.59 | 0.07 | 3.52 |
| 1.59 | 48.99 | 38.81 | 33.97 | 0.09 | 2.78 |
| 2.29 | 48.61 | 36.67 | 33.77 | 0.13 | 1.98 |
