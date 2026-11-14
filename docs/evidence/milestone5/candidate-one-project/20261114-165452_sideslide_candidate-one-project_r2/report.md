# sideslide - 20261114-165452_sideslide_candidate-one-project_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: True after 4.252 s - 471 frames, 64.9 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.195)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 5727 | 482 | 89 | 96 | 130 | 35 | 52 | 0.0% | 0 | 35 |

Rejected contacts: Wheel 3463, BelowThresh 1781, NormalForce 1

Body materials: METAL 340, PLASTIC 142

Surfaces: ASPHALT 482

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.065 | 35.378 | 45.458 |
| whole frame, ms | 10.36 (p50) | 43.895 | 57.895 |
| all GE Lua, ms | | 36.711 | 46.49 |
| physics + vehicle Lua, ms | | 0.917 | 5.226 |
| render, ms | | 3.228 | |

- Painter frames over 4 ms: 87; worst flush (project + bake) 44.937 ms, worst composite 0.125 ms.
- Detector: 1.168 us per contact, 11.501 ms total, worst frame 0.91 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.62 | 57.89 | 45.46 | 32.35 | 0.07 | 4.11 |
| 1.66 | 57.84 | 45.00 | 1.11 | 1.40 | 3.16 |
| 1.26 | 53.13 | 43.22 | 42.20 | 0.07 | 2.14 |
| 1.49 | 51.19 | 41.49 | 34.58 | 0.06 | 2.43 |
| 2.28 | 50.48 | 39.45 | 0.90 | 1.29 | 2.29 |
