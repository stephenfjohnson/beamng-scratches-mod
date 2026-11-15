# sideslide - 20261114-173334_sideslide_candidate-d3d12-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.396 s - 238 frames, 47.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.172)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1930 | 282 | 107 | 57 | 182 | 87 | 60 | 0.0% | 0 | 14 |

Rejected contacts: Wheel 916, BelowThresh 731, NormalForce 1

Body materials: METAL 196, PLASTIC 86

Surfaces: ASPHALT 282

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 10.448 | 40.763 | 59.289 |
| whole frame, ms | 11.198 (p50) | 51.902 | 86.697 |
| all GE Lua, ms | | 41.832 | 60.437 |
| physics + vehicle Lua, ms | | 4.974 | 8.057 |
| render, ms | | 2.396 | |

- Painter frames over 4 ms: 78; worst flush (project + bake) 59.25 ms, worst composite 0.111 ms.
- Detector: 1.265 us per contact, 5.919 ms total, worst frame 1.017 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 86.70 | 59.29 | 1.37 | 0.68 | 1.61 |
| 2.62 | 68.71 | 35.20 | 1.08 | 7.99 | 1.50 |
| 0.83 | 61.53 | 49.57 | 1.10 | 3.47 | 1.64 |
| 3.78 | 60.14 | 28.89 | 0.92 | 7.14 | 1.61 |
| 0.92 | 58.21 | 40.64 | 45.75 | 0.10 | 2.70 |
