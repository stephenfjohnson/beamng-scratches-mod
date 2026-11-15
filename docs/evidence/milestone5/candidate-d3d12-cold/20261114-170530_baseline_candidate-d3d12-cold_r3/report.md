# baseline - 20261114-170530_baseline_candidate-d3d12-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.004 s - 341 frames, 85.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4518 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4518

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.01 | 0.013 | 0.049 |
| whole frame, ms | 11.35 (p50) | 15.619 | 27.244 |
| all GE Lua, ms | | 1.637 | 4.701 |
| physics + vehicle Lua, ms | | 0.181 | 0.548 |
| render, ms | | 3.722 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.741 us per contact, 6.046 ms total, worst frame 0.835 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.92 | 27.24 | 0.01 | 1.23 | 0.08 | 2.74 |
| 0.04 | 22.10 | 0.01 | 1.29 | 0.19 | 3.20 |
| 0.56 | 21.85 | 0.01 | 4.20 | 0.14 | 3.46 |
| 3.91 | 20.76 | 0.01 | 1.36 | 0.10 | 2.83 |
| 0.03 | 19.19 | 0.01 | 1.25 | 0.19 | 8.71 |
