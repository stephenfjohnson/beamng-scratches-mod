# roofdrop - 20261114-173101_roofdrop_candidate-d3d12-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.115 s - 425 frames, 81.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1112 | 52 | 52 | 0 | 59 | 18 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 641, BelowThresh 419

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.791 | 22.659 | 42.038 |
| whole frame, ms | 11.099 (p50) | 30.837 | 49.16 |
| all GE Lua, ms | | 23.677 | 42.944 |
| physics + vehicle Lua, ms | | 0.093 | 0.776 |
| render, ms | | 2.447 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 34.37 ms, worst composite 0.139 ms.
- Detector: 1.575 us per contact, 3.848 ms total, worst frame 0.426 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.75 | 49.16 | 42.04 | 39.78 | 0.06 | 1.47 |
| 1.56 | 47.45 | 34.42 | 0.85 | 0.06 | 2.61 |
| 0.72 | 47.31 | 32.70 | 0.87 | 0.05 | 1.98 |
| 0.73 | 46.72 | 38.74 | 33.57 | 0.06 | 2.20 |
| 0.97 | 45.96 | 39.59 | 36.28 | 0.05 | 1.38 |
