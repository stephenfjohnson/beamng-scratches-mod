# roofdrop - 20261114-172108_roofdrop_candidate-vulkan-disabled-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.32 s - 416 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1076 | 54 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 620, BelowThresh 402

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.02 |
| whole frame, ms | 12.716 (p50) | 14.904 | 17.579 |
| all GE Lua, ms | | 1.212 | 1.568 |
| physics + vehicle Lua, ms | | 0.086 | 0.186 |
| render, ms | | 2.534 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 2.575 us per contact, 4.46 ms total, worst frame 0.598 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.80 | 17.58 | 0.01 | 0.95 | 0.04 | 3.06 |
| 2.27 | 17.21 | 0.01 | 1.14 | 0.07 | 2.71 |
| 2.77 | 17.11 | 0.01 | 0.90 | 0.07 | 1.65 |
| 0.76 | 16.28 | 0.01 | 1.12 | 0.06 | 2.82 |
| 1.36 | 15.97 | 0.01 | 0.92 | 0.06 | 2.42 |
