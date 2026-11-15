# sideslide - 20261114-173808_sideslide_candidate-d3d12-endurance_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.306 s - 142 frames, 35.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.168)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1102 | 278 | 86 | 57 | 170 | 87 | 55 | 0.0% | 0 | 12 |

Rejected contacts: Wheel 570, BelowThresh 254

Body materials: METAL 201, PLASTIC 77

Surfaces: ASPHALT 278

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 16.52 | 40.767 | 52.417 |
| whole frame, ms | 18.486 (p50) | 51.178 | 70.016 |
| all GE Lua, ms | | 41.956 | 53.375 |
| physics + vehicle Lua, ms | | 5.643 | 8.729 |
| render, ms | | 2.691 | |

- Painter frames over 4 ms: 71; worst flush (project + bake) 52.379 ms, worst composite 0.128 ms.
- Detector: 1.742 us per contact, 4.362 ms total, worst frame 0.374 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.51 | 70.02 | 39.82 | 1.36 | 8.73 | 8.24 |
| 2.60 | 61.36 | 52.42 | 1.07 | 1.96 | 1.57 |
| 3.55 | 59.94 | 41.94 | 46.95 | 0.09 | 2.47 |
| 0.61 | 58.83 | 45.89 | 0.81 | 4.50 | 1.88 |
| 1.48 | 57.89 | 28.20 | 1.15 | 6.88 | 1.99 |
