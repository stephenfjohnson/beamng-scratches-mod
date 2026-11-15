# roofdrop - 20261114-165646_roofdrop_candidate-d3d12-disabled-cold_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.368 s - 508 frames, 90.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1404 | 54 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 732, BelowThresh 618

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.037 |
| whole frame, ms | 10.916 (p50) | 13.854 | 16.962 |
| all GE Lua, ms | | 1.367 | 4.115 |
| physics + vehicle Lua, ms | | 0.098 | 0.346 |
| render, ms | | 3.063 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 2.146 us per contact, 5.262 ms total, worst frame 0.078 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.29 | 16.96 | 0.01 | 1.23 | 0.06 | 1.93 |
| 3.01 | 16.24 | 0.01 | 1.23 | 0.06 | 1.95 |
| 5.14 | 15.60 | 0.01 | 0.99 | 0.09 | 2.89 |
| 3.88 | 15.46 | 0.01 | 3.42 | 0.06 | 2.58 |
| 0.21 | 15.21 | 0.01 | 1.12 | 0.08 | 3.29 |
