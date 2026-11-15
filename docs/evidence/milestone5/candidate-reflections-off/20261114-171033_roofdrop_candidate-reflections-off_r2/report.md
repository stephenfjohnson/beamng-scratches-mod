# roofdrop - 20261114-171033_roofdrop_candidate-reflections-off_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 6.609 s - 573 frames, 80.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1643 | 56 | 56 | 0 | 59 | 20 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 919, BelowThresh 668

Body materials: METAL 55, PLASTIC 1

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.412 | 7.202 | 41.331 |
| whole frame, ms | 11.227 (p50) | 19.422 | 51.564 |
| all GE Lua, ms | | 7.196 | 42.481 |
| physics + vehicle Lua, ms | | 0.09 | 0.389 |
| render, ms | | 3.018 | |

- Painter frames over 4 ms: 32; worst flush (project + bake) 35.57 ms, worst composite 0.11 ms.
- Detector: 1.796 us per contact, 6.31 ms total, worst frame 0.608 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.75 | 51.56 | 41.33 | 32.66 | 0.08 | 2.78 |
| 1.58 | 48.00 | 39.67 | 33.39 | 0.05 | 2.25 |
| 2.28 | 47.22 | 35.60 | 0.69 | 0.04 | 1.79 |
| 0.95 | 45.44 | 37.22 | 30.69 | 0.06 | 2.17 |
| 2.29 | 45.43 | 38.34 | 36.53 | 0.05 | 1.82 |
