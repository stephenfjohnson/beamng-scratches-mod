# roofdrop - 20261114-173153_roofdrop_candidate-d3d12-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.938 s - 422 frames, 83.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1042 | 48 | 48 | 0 | 49 | 14 | 13 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 624, BelowThresh 370

Body materials: METAL 46, PLASTIC 2

Surfaces: ASPHALT 48

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.412 | 6.063 | 38.257 |
| whole frame, ms | 11.073 (p50) | 18.781 | 47.917 |
| all GE Lua, ms | | 7.223 | 39.339 |
| physics + vehicle Lua, ms | | 0.087 | 0.246 |
| render, ms | | 2.405 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 38.213 ms, worst composite 0.087 ms.
- Detector: 1.335 us per contact, 3.563 ms total, worst frame 0.34 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.57 | 47.92 | 38.26 | 1.47 | 0.03 | 1.71 |
| 1.58 | 47.58 | 37.53 | 39.34 | 0.06 | 2.63 |
| 0.73 | 44.07 | 33.70 | 0.90 | 0.05 | 1.84 |
| 0.96 | 43.97 | 36.39 | 33.81 | 0.06 | 1.69 |
| 2.20 | 43.83 | 32.19 | 0.85 | 0.09 | 2.76 |
