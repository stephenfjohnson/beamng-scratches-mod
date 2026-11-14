# roofdrop - 20261114-164213_roofdrop_original-d3d12-cold_r1

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 5.316 s - 451 frames, 84.6 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1141 | 51 | 51 | 0 | 57 | 20 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 707, BelowThresh 383

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.747 | 13.657 | 46.215 |
| whole frame, ms | 10.714 (p50) | 34.763 | 58.24 |
| all GE Lua, ms | | 14.637 | 47.318 |
| physics + vehicle Lua, ms | | 0.103 | 0.904 |
| render, ms | | 2.9 | |

- Painter frames over 4 ms: 32; worst flush (project + bake) 33.86 ms, worst composite 0.114 ms.
- Detector: 1.968 us per contact, 4.923 ms total, worst frame 0.482 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 58.24 | 46.21 | 35.21 | 0.32 | 3.02 |
| 1.36 | 51.61 | 42.57 | 31.72 | 0.06 | 2.42 |
| 0.96 | 50.14 | 42.26 | 38.47 | 0.08 | 1.73 |
| 1.57 | 49.61 | 39.96 | 33.99 | 0.08 | 2.16 |
| 0.94 | 47.59 | 37.39 | 28.09 | 0.07 | 1.93 |
