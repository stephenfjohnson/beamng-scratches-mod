# sideslide - 20261114-173618_sideslide_candidate-d3d12-endurance_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.306 s - 152 frames, 38.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.199)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1229 | 267 | 85 | 52 | 156 | 88 | 51 | 0.0% | 0 | 7 |

Rejected contacts: Wheel 648, BelowThresh 313, NormalForce 1

Body materials: METAL 187, PLASTIC 80

Surfaces: ASPHALT 267

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 14.73 | 40.957 | 61.29 |
| whole frame, ms | 14.623 (p50) | 52.371 | 69.103 |
| all GE Lua, ms | | 42.133 | 62.355 |
| physics + vehicle Lua, ms | | 6.384 | 9.044 |
| render, ms | | 2.471 | |

- Painter frames over 4 ms: 67; worst flush (project + bake) 61.25 ms, worst composite 0.109 ms.
- Detector: 1.522 us per contact, 4.356 ms total, worst frame 0.421 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.39 | 69.10 | 61.29 | 1.06 | 0.05 | 1.97 |
| 2.94 | 65.00 | 36.65 | 1.00 | 6.53 | 6.30 |
| 0.81 | 61.79 | 45.96 | 1.76 | 4.99 | 2.42 |
| 2.32 | 60.80 | 37.17 | 0.91 | 9.04 | 1.61 |
| 0.60 | 60.08 | 46.58 | 1.06 | 5.67 | 1.79 |
