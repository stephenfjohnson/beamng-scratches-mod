# sideslide - 20261114-173955_sideslide_candidate-d3d12-endurance_r31

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.347 s - 154 frames, 38.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1219 | 285 | 91 | 62 | 158 | 85 | 59 | 0.0% | 0 | 10 |

Rejected contacts: Wheel 641, BelowThresh 292, NormalForce 1

Body materials: METAL 204, PLASTIC 81

Surfaces: ASPHALT 285

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.7 | 41.803 | 55.087 |
| whole frame, ms | 15.115 (p50) | 52.502 | 83.445 |
| all GE Lua, ms | | 42.9 | 56.323 |
| physics + vehicle Lua, ms | | 5.267 | 9.654 |
| render, ms | | 2.362 | |

- Painter frames over 4 ms: 77; worst flush (project + bake) 55.032 ms, worst composite 0.169 ms.
- Detector: 1.554 us per contact, 4.278 ms total, worst frame 0.364 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.99 | 83.44 | 55.09 | 1.35 | 9.65 | 2.18 |
| 0.60 | 73.54 | 43.19 | 0.85 | 4.35 | 1.69 |
| 2.55 | 58.13 | 46.34 | 1.27 | 3.73 | 1.63 |
| 0.38 | 54.91 | 45.92 | 0.96 | 0.06 | 1.72 |
| 2.43 | 53.57 | 43.23 | 38.84 | 0.10 | 1.58 |
