# baseline - 20261114-172116_baseline_candidate-vulkan-disabled-warm_r3

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.005 s - 311 frames, 69.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3975 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 3975

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.014 |
| whole frame, ms | 12.651 (p50) | 14.937 | 524.387 |
| all GE Lua, ms | | 1.243 | 2.929 |
| physics + vehicle Lua, ms | | 0.123 | 0.189 |
| render, ms | | 2.792 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.533 us per contact, 3.555 ms total, worst frame 0.079 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.88 | 524.39 | 0.01 | 0.81 | 0.03 | 2.57 |
| 0.67 | 16.63 | 0.01 | 0.84 | 0.09 | 2.12 |
| 1.31 | 16.63 | 0.01 | 1.31 | 0.07 | 2.79 |
| 0.98 | 16.40 | 0.01 | 0.90 | 0.07 | 2.50 |
| 0.38 | 16.08 | 0.01 | 1.23 | 0.14 | 3.18 |
