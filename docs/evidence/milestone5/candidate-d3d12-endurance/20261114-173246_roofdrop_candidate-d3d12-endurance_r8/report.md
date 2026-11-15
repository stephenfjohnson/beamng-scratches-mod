# roofdrop - 20261114-173246_roofdrop_candidate-d3d12-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 7.637 s - 651 frames, 82.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1876 | 67 | 67 | 0 | 62 | 20 | 19 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1059, BelowThresh 750

Body materials: METAL 65, PLASTIC 2

Surfaces: ASPHALT 67

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.293 | 6.299 | 41.396 |
| whole frame, ms | 11.28 (p50) | 18.848 | 48.965 |
| all GE Lua, ms | | 7.211 | 42.546 |
| physics + vehicle Lua, ms | | 0.085 | 0.149 |
| render, ms | | 2.551 | |

- Painter frames over 4 ms: 34; worst flush (project + bake) 34.258 ms, worst composite 0.102 ms.
- Detector: 1.338 us per contact, 6.73 ms total, worst frame 1.331 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.96 | 48.96 | 41.40 | 34.65 | 0.10 | 1.69 |
| 0.73 | 45.15 | 34.31 | 1.03 | 0.08 | 2.27 |
| 0.74 | 44.75 | 37.30 | 35.24 | 0.06 | 1.90 |
| 0.75 | 44.31 | 37.33 | 38.20 | 0.06 | 1.46 |
| 2.27 | 43.83 | 32.13 | 0.82 | 0.05 | 1.98 |
