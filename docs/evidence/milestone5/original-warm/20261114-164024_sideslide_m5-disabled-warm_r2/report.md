# sideslide - 20261114-164024_sideslide_m5-disabled-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.877 s - 455 frames, 93.1 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3348 | 803 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1441, BelowThresh 1101, NormalForce 3

Body materials: METAL 586, PLASTIC 217

Surfaces: ASPHALT 803

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.004 | 0.006 | 0.008 |
| whole frame, ms | 10.722 (p50) | 13.075 | 15.83 |
| all GE Lua, ms | | 1.001 | 3.204 |
| physics + vehicle Lua, ms | | 0.086 | 0.194 |
| render, ms | | 2.779 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.084 us per contact, 5.561 ms total, worst frame 0.033 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.08 | 15.83 | 0.00 | 0.77 | 0.05 | 2.80 |
| 2.69 | 15.65 | 0.00 | 0.73 | 0.05 | 2.94 |
| 3.02 | 15.52 | 0.00 | 2.99 | 0.10 | 2.15 |
| 2.30 | 15.18 | 0.01 | 0.72 | 0.07 | 2.58 |
| 1.18 | 14.69 | 0.00 | 0.62 | 0.04 | 2.05 |
