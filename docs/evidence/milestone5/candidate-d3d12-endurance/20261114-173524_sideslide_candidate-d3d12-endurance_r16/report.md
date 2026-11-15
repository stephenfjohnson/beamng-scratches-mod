# sideslide - 20261114-173524_sideslide_candidate-d3d12-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.293 s - 156 frames, 38.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.208)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1218 | 312 | 79 | 68 | 146 | 87 | 58 | 0.0% | 0 | 13 |

Rejected contacts: Wheel 658, BelowThresh 247, NormalForce 1

Body materials: METAL 217, PLASTIC 95

Surfaces: ASPHALT 312

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.601 | 41.305 | 53.971 |
| whole frame, ms | 13.525 (p50) | 51.327 | 68.145 |
| all GE Lua, ms | | 42.385 | 54.903 |
| physics + vehicle Lua, ms | | 5.06 | 9.753 |
| render, ms | | 2.282 | |

- Painter frames over 4 ms: 75; worst flush (project + bake) 53.944 ms, worst composite 0.083 ms.
- Detector: 1.64 us per contact, 4.64 ms total, worst frame 0.513 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.99 | 68.14 | 40.45 | 1.38 | 9.75 | 3.18 |
| 2.30 | 63.29 | 53.97 | 1.05 | 2.37 | 1.74 |
| 0.58 | 56.08 | 47.43 | 1.03 | 1.88 | 1.50 |
| 0.79 | 55.84 | 46.42 | 1.02 | 2.83 | 1.51 |
| 0.38 | 55.20 | 43.53 | 0.83 | 0.04 | 2.12 |
