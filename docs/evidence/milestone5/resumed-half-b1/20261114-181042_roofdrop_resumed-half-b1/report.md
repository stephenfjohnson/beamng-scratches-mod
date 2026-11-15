# roofdrop - 20261114-181042_roofdrop_resumed-half-b1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1)`

Settled: True after 4.982 s - 435 frames, 87.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1187 | 46 | 45 | 0 | 48 | 14 | 48 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 689, BelowThresh 452

Body materials: METAL 44, PLASTIC 2

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.933 | 3.065 | 37.016 |
| whole frame, ms | 11.141 (p50) | 12.624 | 47.704 |
| all GE Lua, ms | | 3.806 | 37.952 |
| physics + vehicle Lua, ms | | 0.076 | 0.172 |
| render, ms | | 2.107 | |

- Painter frames over 4 ms: 14; worst flush (project + bake) 36.992 ms, worst composite 0.086 ms.
- Detector: 1.175 us per contact, 3.419 ms total, worst frame 0.401 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.74 | 47.70 | 37.01 | 0.79 | 0.04 | 1.71 |
| 0.53 | 45.87 | 37.02 | 0.85 | 0.10 | 1.68 |
| 1.56 | 45.69 | 34.14 | 0.74 | 0.04 | 1.67 |
| 1.15 | 41.97 | 31.67 | 0.88 | 0.06 | 1.79 |
| 3.73 | 41.72 | 30.12 | 0.70 | 0.04 | 1.82 |
