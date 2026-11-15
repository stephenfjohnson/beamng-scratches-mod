# sideslide - 20261114-173713_sideslide_candidate-d3d12-endurance_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.309 s - 138 frames, 34.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1100 | 249 | 92 | 52 | 148 | 79 | 53 | 0.0% | 0 | 9 |

Rejected contacts: Wheel 596, BelowThresh 255

Body materials: METAL 180, PLASTIC 69

Surfaces: ASPHALT 249

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.002 | 45.179 | 53.514 |
| whole frame, ms | 20.883 (p50) | 54.827 | 72.522 |
| all GE Lua, ms | | 46.194 | 54.844 |
| physics + vehicle Lua, ms | | 5.076 | 9.893 |
| render, ms | | 2.835 | |

- Painter frames over 4 ms: 68; worst flush (project + bake) 53.484 ms, worst composite 0.141 ms.
- Detector: 1.736 us per contact, 4.657 ms total, worst frame 0.398 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.13 | 72.52 | 45.18 | 1.06 | 9.89 | 1.77 |
| 1.53 | 69.76 | 35.51 | 1.36 | 6.28 | 1.83 |
| 0.84 | 65.50 | 53.51 | 0.98 | 4.27 | 1.77 |
| 0.62 | 60.73 | 49.91 | 1.10 | 3.29 | 1.78 |
| 2.00 | 60.71 | 49.28 | 1.12 | 3.91 | 1.66 |
