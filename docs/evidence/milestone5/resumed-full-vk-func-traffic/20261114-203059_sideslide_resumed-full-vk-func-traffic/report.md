# sideslide - 20261114-203059_sideslide_resumed-full-vk-func-traffic

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.266 s - 257 frames, 58.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1872 | 448 | 100 | 101 | 132 | 94 | 123 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 859, BelowThresh 562, NormalForce 3

Body materials: METAL 329, PLASTIC 119

Surfaces: ASPHALT 448

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.41 | 18.276 | 40.94 |
| whole frame, ms | 14.844 (p50) | 31.739 | 53.425 |
| all GE Lua, ms | | 19.55 | 42.119 |
| physics + vehicle Lua, ms | | 0.227 | 0.82 |
| render, ms | | 1.894 | |

- Painter frames over 4 ms: 58; worst flush (project + bake) 40.914 ms, worst composite 0.101 ms.
- Detector: 1.939 us per contact, 8.212 ms total, worst frame 0.455 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 53.42 | 40.94 | 1.13 | 0.23 | 1.67 |
| 1.43 | 39.88 | 24.44 | 2.96 | 0.13 | 1.33 |
| 2.75 | 38.27 | 19.35 | 5.68 | 0.18 | 1.36 |
| 0.33 | 37.34 | 23.66 | 2.46 | 0.14 | 1.68 |
| 0.23 | 36.42 | 28.06 | 1.11 | 0.18 | 1.66 |
