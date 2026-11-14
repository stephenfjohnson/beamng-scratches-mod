# sideslide - 20261114-165519_sideslide_candidate-one-project_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: True after 4.254 s - 460 frames, 63.3 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.19)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 5632 | 513 | 101 | 103 | 131 | 35 | 53 | 0.0% | 0 | 35 |

Rejected contacts: Wheel 3478, BelowThresh 1637, NormalForce 4

Body materials: METAL 368, PLASTIC 145

Surfaces: ASPHALT 513

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.18 | 35.479 | 46.413 |
| whole frame, ms | 10.743 (p50) | 44.855 | 60.6 |
| all GE Lua, ms | | 36.556 | 47.728 |
| physics + vehicle Lua, ms | | 1.806 | 4.167 |
| render, ms | | 3.39 | |

- Painter frames over 4 ms: 88; worst flush (project + bake) 39.08 ms, worst composite 0.189 ms.
- Detector: 1.204 us per contact, 11.751 ms total, worst frame 0.609 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.82 | 60.60 | 46.27 | 28.34 | 0.18 | 4.56 |
| 6.67 | 57.45 | 45.78 | 43.62 | 0.09 | 2.99 |
| 6.04 | 56.99 | 46.41 | 43.81 | 0.09 | 2.88 |
| 6.06 | 55.46 | 44.21 | 47.73 | 0.08 | 3.09 |
| 6.02 | 53.99 | 42.67 | 17.37 | 0.09 | 3.52 |
