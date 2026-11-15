# roofdrop - 20261114-174002_roofdrop_candidate-d3d12-endurance_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.909 s - 419 frames, 82.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1012 | 53 | 53 | 0 | 53 | 17 | 14 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 575, BelowThresh 384

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.578 | 16.424 | 41.534 |
| whole frame, ms | 11.088 (p50) | 23.238 | 48.598 |
| all GE Lua, ms | | 17.427 | 42.632 |
| physics + vehicle Lua, ms | | 0.078 | 0.162 |
| render, ms | | 2.265 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 37.225 ms, worst composite 0.078 ms.
- Detector: 1.366 us per contact, 4.835 ms total, worst frame 1.599 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.75 | 48.60 | 41.53 | 38.21 | 0.06 | 1.53 |
| 0.73 | 48.50 | 37.26 | 0.69 | 0.04 | 1.80 |
| 1.55 | 47.24 | 35.26 | 0.80 | 0.05 | 1.89 |
| 0.74 | 44.51 | 37.43 | 38.06 | 0.05 | 1.78 |
| 1.35 | 43.34 | 32.70 | 0.83 | 0.05 | 1.61 |
