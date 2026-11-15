# roofdrop - 20261114-173720_roofdrop_candidate-d3d12-endurance_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.147 s - 413 frames, 77.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1017 | 50 | 50 | 0 | 56 | 17 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 623, BelowThresh 344

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.791 | 17.101 | 43.657 |
| whole frame, ms | 11.689 (p50) | 24.645 | 51.679 |
| all GE Lua, ms | | 18.044 | 44.61 |
| physics + vehicle Lua, ms | | 0.088 | 0.952 |
| render, ms | | 2.934 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 37.558 ms, worst composite 0.084 ms.
- Detector: 1.436 us per contact, 3.786 ms total, worst frame 0.406 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.96 | 51.68 | 43.66 | 41.29 | 0.06 | 1.61 |
| 0.94 | 49.23 | 40.24 | 34.61 | 0.06 | 2.07 |
| 2.26 | 48.92 | 37.68 | 37.55 | 0.06 | 2.42 |
| 1.57 | 48.77 | 37.61 | 0.84 | 0.04 | 1.83 |
| 0.74 | 47.40 | 39.73 | 36.09 | 0.06 | 1.86 |
