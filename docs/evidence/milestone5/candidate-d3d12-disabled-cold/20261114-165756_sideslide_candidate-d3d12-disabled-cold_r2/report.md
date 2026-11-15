# sideslide - 20261114-165756_sideslide_candidate-d3d12-disabled-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.067 s - 422 frames, 103.5 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.145)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3991 | 1064 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 2074, BelowThresh 848, NormalForce 5

Body materials: METAL 802, PLASTIC 262

Surfaces: ASPHALT 1064

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.102 |
| whole frame, ms | 10.3 (p50) | 13.088 | 19.42 |
| all GE Lua, ms | | 1.434 | 3.87 |
| physics + vehicle Lua, ms | | 0.107 | 0.409 |
| render, ms | | 3.063 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.44 us per contact, 8.197 ms total, worst frame 0.146 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.35 | 19.42 | 0.01 | 0.83 | 0.06 | 1.99 |
| 1.75 | 16.01 | 0.01 | 1.22 | 0.07 | 2.92 |
| 1.03 | 15.91 | 0.01 | 1.20 | 0.08 | 2.13 |
| 0.77 | 15.11 | 0.01 | 3.44 | 0.13 | 1.96 |
| 0.23 | 15.02 | 0.01 | 1.09 | 0.41 | 3.41 |
