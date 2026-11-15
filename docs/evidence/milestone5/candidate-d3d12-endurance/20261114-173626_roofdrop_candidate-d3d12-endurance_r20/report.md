# roofdrop - 20261114-173626_roofdrop_candidate-d3d12-endurance_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.11 s - 439 frames, 82.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1158 | 50 | 50 | 0 | 57 | 16 | 16 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 666, BelowThresh 442

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.534 | 6.275 | 37.372 |
| whole frame, ms | 11.058 (p50) | 17.775 | 45.635 |
| all GE Lua, ms | | 7.185 | 38.276 |
| physics + vehicle Lua, ms | | 0.08 | 0.388 |
| render, ms | | 2.491 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 33.322 ms, worst composite 0.129 ms.
- Detector: 1.319 us per contact, 3.804 ms total, worst frame 0.474 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.57 | 45.64 | 32.74 | 0.81 | 0.06 | 1.82 |
| 0.53 | 45.18 | 33.35 | 0.71 | 0.04 | 1.74 |
| 0.96 | 44.40 | 37.37 | 34.10 | 0.06 | 1.60 |
| 0.73 | 44.20 | 32.58 | 0.89 | 0.05 | 1.89 |
| 2.20 | 43.17 | 31.88 | 0.80 | 0.04 | 1.74 |
