# sideslide - 20261114-171027_sideslide_candidate-reflections-off_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.321 s - 137 frames, 33.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 976 | 253 | 85 | 46 | 164 | 82 | 49 | 0.0% | 0 | 8 |

Rejected contacts: Wheel 509, BelowThresh 211, NormalForce 3

Body materials: METAL 180, PLASTIC 73

Surfaces: ASPHALT 253

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.245 | 43.312 | 58.514 |
| whole frame, ms | 24.811 (p50) | 56.863 | 80.457 |
| all GE Lua, ms | | 46.626 | 59.302 |
| physics + vehicle Lua, ms | | 6.256 | 10.151 |
| render, ms | | 2.743 | |

- Painter frames over 4 ms: 65; worst flush (project + bake) 58.478 ms, worst composite 0.151 ms.
- Detector: 2.115 us per contact, 4.637 ms total, worst frame 0.519 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 80.46 | 51.10 | 0.94 | 3.59 | 1.89 |
| 0.37 | 68.63 | 58.51 | 0.75 | 0.04 | 2.11 |
| 1.46 | 67.77 | 35.86 | 1.12 | 5.55 | 2.42 |
| 2.11 | 63.46 | 35.77 | 1.32 | 8.60 | 7.25 |
| 2.57 | 59.61 | 42.71 | 41.15 | 0.16 | 2.56 |
