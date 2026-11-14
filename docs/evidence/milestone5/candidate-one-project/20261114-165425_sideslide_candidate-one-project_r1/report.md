# sideslide - 20261114-165425_sideslide_candidate-one-project_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: True after 4.232 s - 447 frames, 61.8 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 5241 | 586 | 87 | 120 | 116 | 34 | 56 | 0.0% | 0 | 34 |

Rejected contacts: Wheel 3145, BelowThresh 1508, NormalForce 2

Body materials: METAL 439, PLASTIC 147

Surfaces: ASPHALT 586

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.578 | 37.034 | 57.313 |
| whole frame, ms | 10.326 (p50) | 46.968 | 67.325 |
| all GE Lua, ms | | 38.093 | 58.563 |
| physics + vehicle Lua, ms | | 1.948 | 5.325 |
| render, ms | | 3.283 | |

- Painter frames over 4 ms: 90; worst flush (project + bake) 57.22 ms, worst composite 0.117 ms.
- Detector: 1.308 us per contact, 11.912 ms total, worst frame 0.539 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 6.84 | 67.32 | 57.31 | 0.91 | 0.07 | 3.24 |
| 4.59 | 57.55 | 45.13 | 43.58 | 0.08 | 3.01 |
| 4.55 | 57.41 | 25.86 | 1.05 | 0.06 | 3.48 |
| 0.41 | 57.20 | 44.28 | 31.06 | 0.07 | 3.77 |
| 0.82 | 57.03 | 48.01 | 29.80 | 0.07 | 2.17 |
