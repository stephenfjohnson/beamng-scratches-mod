# roofdrop - 20261114-164007_roofdrop_m5-original-warm_r3

_dropped upside down from about 1 m - roof impacts_

Settled: True after 4.939 s - 396 frames, 80.0 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 982 | 48 | 48 | 0 | 49 | 17 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 583, BelowThresh 351

Body materials: METAL 46, PLASTIC 2

Surfaces: ASPHALT 48

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.727 | 11.547 | 38.488 |
| whole frame, ms | 11.395 (p50) | 23.716 | 47.69 |
| all GE Lua, ms | | 12.949 | 39.375 |
| physics + vehicle Lua, ms | | 0.084 | 1.361 |
| render, ms | | 2.894 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 37.586 ms, worst composite 0.158 ms.
- Detector: 1.395 us per contact, 3.58 ms total, worst frame 0.552 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.74 | 47.69 | 37.63 | 0.62 | 0.06 | 2.19 |
| 0.53 | 47.62 | 34.84 | 0.80 | 0.09 | 2.23 |
| 2.47 | 45.94 | 34.68 | 0.74 | 0.04 | 1.95 |
| 0.99 | 45.71 | 38.49 | 38.20 | 0.06 | 1.80 |
| 1.59 | 45.61 | 34.24 | 0.64 | 0.07 | 1.98 |
