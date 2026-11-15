# roofdrop - 20261114-181227_roofdrop_resumed-quarter-b1-retry

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(1)`

Settled: True after 5.131 s - 448 frames, 87.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1138 | 45 | 45 | 0 | 46 | 15 | 46 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 677, BelowThresh 416

Body materials: METAL 43, PLASTIC 2

Surfaces: ASPHALT 45

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.793 | 0.984 | 38.169 |
| whole frame, ms | 11.031 (p50) | 13.995 | 49.215 |
| all GE Lua, ms | | 2.711 | 39.041 |
| physics + vehicle Lua, ms | | 0.078 | 0.284 |
| render, ms | | 2.471 | |

- Painter frames over 4 ms: 14; worst flush (project + bake) 38.136 ms, worst composite 0.074 ms.
- Detector: 1.351 us per contact, 3.658 ms total, worst frame 0.383 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.72 | 49.21 | 38.17 | 0.85 | 0.05 | 1.85 |
| 1.55 | 45.22 | 33.60 | 0.83 | 0.04 | 1.67 |
| 1.34 | 43.68 | 31.32 | 0.95 | 0.04 | 2.01 |
| 0.93 | 42.27 | 31.04 | 0.79 | 0.05 | 2.04 |
| 2.20 | 42.09 | 31.84 | 1.01 | 0.08 | 1.82 |
