# sideslide - 20261114-164017_sideslide_m5-disabled-warm_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.446 s - 413 frames, 92.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.187)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2634 | 698 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1175, BelowThresh 755, NormalForce 6

Body materials: METAL 498, PLASTIC 200

Surfaces: ASPHALT 698

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.004 | 0.006 | 0.015 |
| whole frame, ms | 10.785 (p50) | 13.189 | 16.049 |
| all GE Lua, ms | | 0.953 | 3.139 |
| physics + vehicle Lua, ms | | 0.091 | 0.163 |
| render, ms | | 2.863 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.149 us per contact, 4.974 ms total, worst frame 0.094 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 16.05 | 0.01 | 0.80 | 0.08 | 3.66 |
| 2.00 | 15.58 | 0.00 | 0.61 | 0.04 | 2.44 |
| 0.86 | 15.37 | 0.01 | 0.91 | 0.16 | 2.74 |
| 0.55 | 15.23 | 0.01 | 0.74 | 0.06 | 2.94 |
| 1.33 | 14.94 | 0.00 | 0.60 | 0.04 | 2.35 |
