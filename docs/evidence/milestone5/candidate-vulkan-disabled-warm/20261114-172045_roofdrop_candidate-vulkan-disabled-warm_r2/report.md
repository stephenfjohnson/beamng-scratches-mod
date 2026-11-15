# roofdrop - 20261114-172045_roofdrop_candidate-vulkan-disabled-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.053 s - 408 frames, 80.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1019 | 51 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 593, BelowThresh 375

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.01 | 0.111 |
| whole frame, ms | 12.477 (p50) | 14.909 | 18.834 |
| all GE Lua, ms | | 1.149 | 2.845 |
| physics + vehicle Lua, ms | | 0.082 | 0.439 |
| render, ms | | 2.161 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.806 us per contact, 3.512 ms total, worst frame 0.122 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.51 | 18.83 | 0.01 | 0.92 | 0.04 | 1.29 |
| 3.26 | 16.75 | 0.01 | 1.08 | 0.06 | 1.43 |
| 3.19 | 16.50 | 0.01 | 0.91 | 0.04 | 2.26 |
| 2.90 | 16.43 | 0.01 | 0.89 | 0.05 | 2.05 |
| 4.01 | 16.21 | 0.01 | 0.82 | 0.04 | 1.50 |
