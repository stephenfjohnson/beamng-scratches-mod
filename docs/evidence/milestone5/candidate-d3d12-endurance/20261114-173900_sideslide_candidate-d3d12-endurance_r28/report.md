# sideslide - 20261114-173900_sideslide_candidate-d3d12-endurance_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.444 s - 131 frames, 30.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.19)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 819 | 251 | 105 | 53 | 171 | 81 | 57 | 0.0% | 0 | 8 |

Rejected contacts: Wheel 385, BelowThresh 183

Body materials: METAL 175, PLASTIC 76

Surfaces: ASPHALT 251

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 20.812 | 47.733 | 64.589 |
| whole frame, ms | 26.928 (p50) | 58.808 | 85.374 |
| all GE Lua, ms | | 49.233 | 65.888 |
| physics + vehicle Lua, ms | | 7.243 | 9.66 |
| render, ms | | 2.943 | |

- Painter frames over 4 ms: 74; worst flush (project + bake) 64.554 ms, worst composite 0.13 ms.
- Detector: 2.122 us per contact, 4.43 ms total, worst frame 0.421 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 85.37 | 55.50 | 1.32 | 1.01 | 7.96 |
| 1.44 | 74.18 | 64.59 | 1.12 | 1.78 | 1.72 |
| 2.35 | 73.76 | 57.10 | 32.85 | 0.07 | 1.70 |
| 2.55 | 72.93 | 53.62 | 33.78 | 0.10 | 1.81 |
| 1.87 | 67.03 | 57.06 | 8.29 | 0.07 | 1.95 |
