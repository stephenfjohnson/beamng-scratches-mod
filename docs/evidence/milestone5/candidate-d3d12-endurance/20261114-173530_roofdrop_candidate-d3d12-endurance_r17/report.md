# roofdrop - 20261114-173530_roofdrop_candidate-d3d12-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 6.356 s - 533 frames, 81.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1464 | 56 | 56 | 0 | 55 | 21 | 17 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 842, BelowThresh 566

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.356 | 5.772 | 38.955 |
| whole frame, ms | 11.443 (p50) | 17.555 | 47.297 |
| all GE Lua, ms | | 6.696 | 39.955 |
| physics + vehicle Lua, ms | | 0.074 | 0.174 |
| render, ms | | 2.364 | |

- Painter frames over 4 ms: 30; worst flush (project + bake) 35.269 ms, worst composite 0.104 ms.
- Detector: 1.231 us per contact, 4.551 ms total, worst frame 0.405 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.31 | 47.30 | 34.31 | 1.11 | 0.06 | 2.18 |
| 0.96 | 47.04 | 38.96 | 32.88 | 0.07 | 1.74 |
| 2.26 | 46.40 | 35.32 | 0.94 | 0.05 | 1.77 |
| 0.53 | 44.77 | 31.47 | 0.94 | 0.12 | 2.60 |
| 0.54 | 43.89 | 36.47 | 32.45 | 0.12 | 1.84 |
