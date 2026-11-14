# sideslide - 20261114-165331_sideslide_candidate-d3d12-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 6.382 s - 286 frames, 44.7 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.172)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2588 | 256 | 130 | 40 | 233 | 77 | 60 | 0.0% | 0 | 10 |

Rejected contacts: Wheel 1270, BelowThresh 1062

Body materials: METAL 186, PLASTIC 70

Surfaces: ASPHALT 256

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 9.804 | 42.509 | 60.395 |
| whole frame, ms | 11.83 (p50) | 54.934 | 77.023 |
| all GE Lua, ms | | 43.651 | 61.522 |
| physics + vehicle Lua, ms | | 4.267 | 11.439 |
| render, ms | | 3.014 | |

- Painter frames over 4 ms: 79; worst flush (project + bake) 60.34 ms, worst composite 0.14 ms.
- Detector: 1.354 us per contact, 7.037 ms total, worst frame 0.487 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.38 | 77.02 | 60.03 | 43.95 | 0.11 | 2.28 |
| 0.60 | 72.37 | 60.39 | 0.77 | 4.15 | 1.56 |
| 0.38 | 64.78 | 55.43 | 0.96 | 0.06 | 2.68 |
| 1.70 | 63.81 | 52.21 | 0.93 | 3.27 | 2.00 |
| 0.91 | 63.17 | 40.44 | 48.61 | 0.16 | 2.63 |
