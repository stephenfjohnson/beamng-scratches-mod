# roofdrop - 20261114-163950_roofdrop_m5-original-warm_r1

_dropped upside down from about 1 m - roof impacts_

Settled: True after 6.478 s - 540 frames, 83.2 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1481 | 56 | 56 | 0 | 56 | 20 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 933, BelowThresh 492

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.391 | 6.389 | 42.058 |
| whole frame, ms | 11.416 (p50) | 18.015 | 52.687 |
| all GE Lua, ms | | 7.223 | 42.797 |
| physics + vehicle Lua, ms | | 0.086 | 0.305 |
| render, ms | | 2.997 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 36.495 ms, worst composite 0.101 ms.
- Detector: 1.465 us per contact, 5.273 ms total, worst frame 0.661 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.74 | 52.69 | 42.06 | 37.64 | 0.10 | 2.00 |
| 0.72 | 47.17 | 36.53 | 0.69 | 0.05 | 2.32 |
| 5.40 | 46.85 | 35.27 | 0.70 | 0.05 | 1.85 |
| 1.56 | 44.87 | 30.64 | 0.69 | 0.05 | 1.97 |
| 0.73 | 43.93 | 35.90 | 37.18 | 0.07 | 2.22 |
