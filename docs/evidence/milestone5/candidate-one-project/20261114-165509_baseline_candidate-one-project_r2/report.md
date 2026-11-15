# baseline - 20261114-165509_baseline_candidate-one-project_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: False after 4.003 s - 333 frames, 83.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4416 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4416

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.012 | 0.015 | 0.12 |
| whole frame, ms | 11.615 (p50) | 15.463 | 19.231 |
| all GE Lua, ms | | 1.589 | 4.418 |
| physics + vehicle Lua, ms | | 0.165 | 0.237 |
| render, ms | | 4.24 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.83 us per contact, 6.357 ms total, worst frame 0.871 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.23 | 19.23 | 0.01 | 1.20 | 0.18 | 5.01 |
| 2.61 | 19.11 | 0.01 | 1.23 | 0.06 | 3.39 |
| 0.53 | 18.36 | 0.01 | 1.17 | 0.14 | 4.27 |
| 2.74 | 18.10 | 0.01 | 0.99 | 0.05 | 3.60 |
| 2.48 | 17.19 | 0.01 | 1.33 | 0.06 | 3.29 |
