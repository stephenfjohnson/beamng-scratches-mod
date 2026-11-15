# roofdrop - 20261114-173815_roofdrop_candidate-d3d12-endurance_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.939 s - 412 frames, 80.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1083 | 51 | 51 | 0 | 57 | 20 | 16 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 614, BelowThresh 418

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.765 | 16.187 | 39.435 |
| whole frame, ms | 11.083 (p50) | 23.995 | 61.248 |
| all GE Lua, ms | | 17.365 | 40.482 |
| physics + vehicle Lua, ms | | 0.094 | 0.837 |
| render, ms | | 2.447 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 34.744 ms, worst composite 0.077 ms.
- Detector: 1.278 us per contact, 3.58 ms total, worst frame 0.364 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.39 | 61.25 | 0.01 | 0.86 | 0.06 | 2.45 |
| 0.98 | 49.07 | 39.44 | 37.53 | 0.06 | 2.23 |
| 1.56 | 45.24 | 34.78 | 0.80 | 0.06 | 1.68 |
| 3.85 | 45.10 | 33.22 | 0.98 | 0.03 | 1.83 |
| 0.53 | 44.99 | 33.32 | 0.83 | 0.05 | 2.06 |
