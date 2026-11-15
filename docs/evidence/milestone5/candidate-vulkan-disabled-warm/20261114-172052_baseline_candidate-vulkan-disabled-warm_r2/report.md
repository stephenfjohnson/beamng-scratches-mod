# baseline - 20261114-172052_baseline_candidate-vulkan-disabled-warm_r2

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.012 s - 320 frames, 79.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4090 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4090

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.042 |
| whole frame, ms | 12.589 (p50) | 14.943 | 18.562 |
| all GE Lua, ms | | 1.29 | 4.344 |
| physics + vehicle Lua, ms | | 0.122 | 0.41 |
| render, ms | | 2.542 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.573 us per contact, 3.711 ms total, worst frame 0.297 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.94 | 18.56 | 0.01 | 0.74 | 0.04 | 1.72 |
| 2.03 | 17.45 | 0.01 | 4.34 | 0.15 | 2.72 |
| 2.04 | 17.24 | 0.01 | 1.24 | 0.07 | 2.75 |
| 1.95 | 16.38 | 0.01 | 1.45 | 0.11 | 2.14 |
| 1.94 | 16.26 | 0.01 | 1.34 | 0.06 | 2.55 |
