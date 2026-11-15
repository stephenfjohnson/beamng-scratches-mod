# roofdrop - 20261114-171836_roofdrop_candidate-vulkan-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 6.067 s - 455 frames, 75.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1271 | 58 | 58 | 0 | 57 | 19 | 17 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 753, BelowThresh 460

Body materials: METAL 56, PLASTIC 2

Surfaces: ASPHALT 58

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.298 | 2.416 | 45.059 |
| whole frame, ms | 12.356 (p50) | 17.74 | 61.786 |
| all GE Lua, ms | | 4.124 | 45.95 |
| physics + vehicle Lua, ms | | 0.093 | 0.483 |
| render, ms | | 2.267 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 45.028 ms, worst composite 0.077 ms.
- Detector: 1.729 us per contact, 5.135 ms total, worst frame 0.64 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.75 | 61.79 | 45.06 | 0.88 | 0.05 | 1.32 |
| 2.22 | 53.51 | 41.19 | 1.03 | 0.07 | 1.49 |
| 0.73 | 52.95 | 39.55 | 1.05 | 0.07 | 1.45 |
| 0.53 | 51.25 | 37.88 | 1.03 | 0.11 | 1.83 |
| 1.55 | 50.19 | 36.72 | 0.99 | 0.05 | 1.48 |
