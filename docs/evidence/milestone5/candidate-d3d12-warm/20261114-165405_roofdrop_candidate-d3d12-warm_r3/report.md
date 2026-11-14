# roofdrop - 20261114-165405_roofdrop_candidate-d3d12-warm_r3

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 7.631 s - 649 frames, 84.9 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1885 | 65 | 65 | 0 | 53 | 19 | 17 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1058, BelowThresh 762

Body materials: METAL 63, PLASTIC 2

Surfaces: ASPHALT 65

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.169 | 0.019 | 45.714 |
| whole frame, ms | 11.352 (p50) | 17.156 | 55.364 |
| all GE Lua, ms | | 3.671 | 46.734 |
| physics + vehicle Lua, ms | | 0.087 | 0.221 |
| render, ms | | 3.064 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 33.492 ms, worst composite 0.126 ms.
- Detector: 1.78 us per contact, 8.018 ms total, worst frame 0.793 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.97 | 55.36 | 45.71 | 39.20 | 0.06 | 2.56 |
| 0.54 | 52.18 | 39.71 | 35.01 | 0.22 | 3.98 |
| 0.95 | 47.65 | 38.15 | 30.89 | 0.09 | 3.23 |
| 1.57 | 45.69 | 34.98 | 34.40 | 0.07 | 2.08 |
| 1.56 | 44.90 | 33.52 | 1.02 | 0.07 | 2.03 |
