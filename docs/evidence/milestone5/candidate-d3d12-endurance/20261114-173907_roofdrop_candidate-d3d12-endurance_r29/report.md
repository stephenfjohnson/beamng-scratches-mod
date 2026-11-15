# roofdrop - 20261114-173907_roofdrop_candidate-d3d12-endurance_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.305 s - 455 frames, 82.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1179 | 53 | 53 | 0 | 54 | 14 | 14 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 667, BelowThresh 459

Body materials: METAL 52, PLASTIC 1

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.421 | 6.241 | 40.912 |
| whole frame, ms | 11.156 (p50) | 17.585 | 49.124 |
| all GE Lua, ms | | 7.219 | 41.805 |
| physics + vehicle Lua, ms | | 0.09 | 0.226 |
| render, ms | | 2.48 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 35.435 ms, worst composite 0.114 ms.
- Detector: 1.342 us per contact, 4.056 ms total, worst frame 0.416 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.96 | 49.12 | 40.91 | 34.40 | 0.07 | 1.91 |
| 0.75 | 47.03 | 38.37 | 36.54 | 0.08 | 2.00 |
| 0.74 | 45.83 | 35.48 | 0.93 | 0.06 | 1.96 |
| 0.53 | 45.28 | 34.40 | 1.16 | 0.09 | 1.94 |
| 1.56 | 45.07 | 34.72 | 1.01 | 0.05 | 2.03 |
