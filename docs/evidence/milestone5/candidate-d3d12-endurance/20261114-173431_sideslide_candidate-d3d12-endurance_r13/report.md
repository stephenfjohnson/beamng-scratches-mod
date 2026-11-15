# sideslide - 20261114-173431_sideslide_candidate-d3d12-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.636 s - 124 frames, 26.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 755 | 242 | 93 | 40 | 198 | 77 | 56 | 0.0% | 0 | 12 |

Rejected contacts: Wheel 342, BelowThresh 168, NormalForce 3

Body materials: METAL 169, PLASTIC 73

Surfaces: ASPHALT 242

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 23.718 | 52.78 | 60.05 |
| whole frame, ms | 41.484 (p50) | 67.077 | 79.9 |
| all GE Lua, ms | | 55.254 | 62.234 |
| physics + vehicle Lua, ms | | 9.639 | 11.022 |
| render, ms | | 3.181 | |

- Painter frames over 4 ms: 73; worst flush (project + bake) 60.009 ms, worst composite 0.118 ms.
- Detector: 2.821 us per contact, 5.67 ms total, worst frame 0.553 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.36 | 79.90 | 59.15 | 1.77 | 8.28 | 2.76 |
| 1.79 | 78.33 | 60.05 | 23.05 | 0.12 | 2.61 |
| 1.53 | 71.46 | 52.55 | 45.22 | 0.11 | 2.72 |
| 2.02 | 68.96 | 44.02 | 54.01 | 0.16 | 3.18 |
| 0.59 | 68.29 | 53.38 | 1.26 | 3.94 | 2.42 |
