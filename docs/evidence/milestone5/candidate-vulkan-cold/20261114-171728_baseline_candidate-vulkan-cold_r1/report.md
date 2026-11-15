# baseline - 20261114-171728_baseline_candidate-vulkan-cold_r1

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.012 s - 318 frames, 79.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4084 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4084

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.016 |
| whole frame, ms | 12.488 (p50) | 16.188 | 21.917 |
| all GE Lua, ms | | 1.527 | 3.784 |
| physics + vehicle Lua, ms | | 0.14 | 0.816 |
| render, ms | | 2.702 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.712 us per contact, 5.444 ms total, worst frame 0.898 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.39 | 21.92 | 0.01 | 1.37 | 0.08 | 2.50 |
| 2.31 | 20.69 | 0.01 | 1.27 | 0.11 | 2.38 |
| 1.36 | 20.25 | 0.01 | 1.27 | 0.08 | 2.52 |
| 1.41 | 19.97 | 0.01 | 3.78 | 0.10 | 2.94 |
| 3.90 | 17.84 | 0.01 | 1.07 | 0.04 | 2.17 |
