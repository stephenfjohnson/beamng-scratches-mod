# sideslide - 20261114-173145_sideslide_candidate-d3d12-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.214 s - 147 frames, 32.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.156)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1098 | 318 | 84 | 63 | 168 | 84 | 60 | 0.0% | 0 | 14 |

Rejected contacts: Wheel 561, BelowThresh 219

Body materials: METAL 228, PLASTIC 90

Surfaces: ASPHALT 318

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.033 | 40.186 | 54.744 |
| whole frame, ms | 22.167 (p50) | 50.882 | 500.909 |
| all GE Lua, ms | | 41.245 | 55.739 |
| physics + vehicle Lua, ms | | 6.093 | 9.226 |
| render, ms | | 2.34 | |

- Painter frames over 4 ms: 76; worst flush (project + bake) 54.71 ms, worst composite 0.092 ms.
- Detector: 1.726 us per contact, 4.707 ms total, worst frame 0.585 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.59 | 500.91 | 0.01 | 12.91 | 0.11 | 2.19 |
| 0.80 | 66.39 | 54.74 | 1.02 | 3.79 | 2.01 |
| 3.36 | 61.63 | 46.04 | 32.22 | 0.09 | 2.14 |
| 2.15 | 61.47 | 28.83 | 1.16 | 9.23 | 1.79 |
| 0.58 | 58.29 | 42.94 | 0.81 | 1.43 | 2.50 |
