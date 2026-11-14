# sideslide - 20261114-165305_sideslide_candidate-d3d12-warm_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 4.215 s - 134 frames, 31.6 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.156)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1066 | 286 | 68 | 58 | 141 | 76 | 52 | 0.0% | 0 | 12 |

Rejected contacts: Wheel 576, BelowThresh 203, NormalForce 1

Body materials: METAL 206, PLASTIC 80

Surfaces: ASPHALT 286

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 18.339 | 50.218 | 58.239 |
| whole frame, ms | 22.046 (p50) | 62.383 | 73.663 |
| all GE Lua, ms | | 51.478 | 59.157 |
| physics + vehicle Lua, ms | | 6.488 | 8.762 |
| render, ms | | 2.63 | |

- Painter frames over 4 ms: 66; worst flush (project + bake) 58.197 ms, worst composite 0.148 ms.
- Detector: 2.179 us per contact, 4.924 ms total, worst frame 0.463 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 73.66 | 45.87 | 1.13 | 5.24 | 7.52 |
| 0.69 | 72.51 | 52.92 | 52.90 | 0.16 | 2.63 |
| 2.01 | 69.45 | 51.77 | 12.89 | 0.10 | 1.99 |
| 0.38 | 67.76 | 58.24 | 0.87 | 0.06 | 2.11 |
| 1.76 | 67.47 | 50.54 | 34.74 | 0.07 | 2.16 |
