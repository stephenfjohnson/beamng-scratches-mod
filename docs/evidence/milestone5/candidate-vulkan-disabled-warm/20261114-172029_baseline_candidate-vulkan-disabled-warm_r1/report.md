# baseline - 20261114-172029_baseline_candidate-vulkan-disabled-warm_r1

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.003 s - 322 frames, 80.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4099 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4099

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.029 |
| whole frame, ms | 12.388 (p50) | 14.806 | 18.842 |
| all GE Lua, ms | | 1.247 | 3.3 |
| physics + vehicle Lua, ms | | 0.12 | 0.175 |
| render, ms | | 2.619 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.527 us per contact, 3.285 ms total, worst frame 0.059 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.28 | 18.84 | 0.01 | 0.85 | 0.04 | 1.83 |
| 3.64 | 16.73 | 0.01 | 3.30 | 0.07 | 1.91 |
| 0.27 | 16.16 | 0.01 | 1.05 | 0.12 | 2.65 |
| 2.39 | 16.07 | 0.01 | 0.86 | 0.03 | 1.96 |
| 1.36 | 16.07 | 0.01 | 1.31 | 0.07 | 3.19 |
