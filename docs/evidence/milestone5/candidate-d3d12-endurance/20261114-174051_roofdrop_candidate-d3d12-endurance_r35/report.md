# roofdrop - 20261114-174051_roofdrop_candidate-d3d12-endurance_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 7.639 s - 634 frames, 82.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1867 | 66 | 66 | 0 | 59 | 20 | 16 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1080, BelowThresh 721

Body materials: METAL 64, PLASTIC 2

Surfaces: ASPHALT 66

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.292 | 0.015 | 51.531 |
| whole frame, ms | 11.327 (p50) | 15.461 | 61.168 |
| all GE Lua, ms | | 3.231 | 52.621 |
| physics + vehicle Lua, ms | | 0.078 | 1.68 |
| render, ms | | 2.294 | |

- Painter frames over 4 ms: 30; worst flush (project + bake) 43.014 ms, worst composite 0.119 ms.
- Detector: 1.254 us per contact, 5.346 ms total, worst frame 0.489 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 61.17 | 51.53 | 36.36 | 0.15 | 2.18 |
| 1.15 | 54.89 | 43.05 | 3.41 | 0.09 | 1.99 |
| 0.98 | 49.40 | 41.17 | 34.42 | 0.06 | 1.45 |
| 0.53 | 46.14 | 34.41 | 0.89 | 0.09 | 1.64 |
| 0.75 | 45.04 | 35.35 | 34.84 | 0.07 | 2.68 |
