# roofdrop - 20261114-172021_roofdrop_candidate-vulkan-disabled-warm_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.138 s - 411 frames, 79.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1092 | 53 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 611, BelowThresh 428

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.056 |
| whole frame, ms | 12.414 (p50) | 15.723 | 20.243 |
| all GE Lua, ms | | 1.353 | 4.092 |
| physics + vehicle Lua, ms | | 0.093 | 0.26 |
| render, ms | | 2.285 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 2.177 us per contact, 4.064 ms total, worst frame 0.133 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.13 | 20.24 | 0.01 | 0.99 | 0.06 | 1.45 |
| 3.21 | 19.75 | 0.01 | 1.33 | 0.05 | 1.98 |
| 4.07 | 19.02 | 0.01 | 0.83 | 0.05 | 2.01 |
| 3.11 | 18.84 | 0.02 | 0.88 | 0.04 | 2.22 |
| 2.29 | 18.81 | 0.01 | 1.22 | 0.07 | 2.60 |
