# roofdrop - 20261114-163959_roofdrop_m5-original-warm_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Settled: True after 6.288 s - 502 frames, 79.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1416 | 62 | 62 | 0 | 57 | 19 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 784, BelowThresh 570

Body materials: METAL 60, PLASTIC 2

Surfaces: ASPHALT 62

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.539 | 7.17 | 45.538 |
| whole frame, ms | 11.47 (p50) | 17.979 | 56.446 |
| all GE Lua, ms | | 7.967 | 46.318 |
| physics + vehicle Lua, ms | | 0.096 | 1.913 |
| render, ms | | 3.014 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 45.512 ms, worst composite 0.165 ms.
- Detector: 1.434 us per contact, 5.026 ms total, worst frame 0.695 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.15 | 56.45 | 45.54 | 0.78 | 0.05 | 2.07 |
| 0.54 | 51.24 | 41.73 | 41.15 | 0.14 | 2.76 |
| 0.53 | 51.11 | 40.15 | 0.74 | 0.10 | 2.12 |
| 1.58 | 49.55 | 37.12 | 33.71 | 0.07 | 2.50 |
| 0.75 | 49.03 | 39.75 | 34.10 | 0.07 | 2.74 |
