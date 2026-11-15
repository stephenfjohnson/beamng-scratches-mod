# roofdrop - 20261114-165802_roofdrop_candidate-d3d12-disabled-cold_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.532 s - 521 frames, 91.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1330 | 53 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 809, BelowThresh 468

Body materials: METAL 52, PLASTIC 1

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.02 |
| whole frame, ms | 10.932 (p50) | 13.385 | 21.384 |
| all GE Lua, ms | | 1.345 | 2.8 |
| physics + vehicle Lua, ms | | 0.091 | 0.525 |
| render, ms | | 2.838 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 2.012 us per contact, 5.086 ms total, worst frame 0.088 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.96 | 21.38 | 0.01 | 0.83 | 0.04 | 1.83 |
| 0.40 | 19.18 | 0.01 | 1.48 | 0.08 | 2.83 |
| 4.25 | 15.96 | 0.01 | 0.78 | 0.05 | 1.77 |
| 3.46 | 15.96 | 0.01 | 0.99 | 0.05 | 1.81 |
| 1.95 | 15.46 | 0.01 | 1.22 | 0.06 | 2.26 |
