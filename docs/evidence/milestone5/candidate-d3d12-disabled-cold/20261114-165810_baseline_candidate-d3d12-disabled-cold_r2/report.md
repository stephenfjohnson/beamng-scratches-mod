# baseline - 20261114-165810_baseline_candidate-d3d12-disabled-cold_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.01 s - 360 frames, 89.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4767 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4767

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.022 |
| whole frame, ms | 11.104 (p50) | 13.416 | 17.543 |
| all GE Lua, ms | | 1.296 | 3.489 |
| physics + vehicle Lua, ms | | 0.133 | 0.201 |
| render, ms | | 3.297 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.549 us per contact, 4.234 ms total, worst frame 0.042 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.74 | 17.54 | 0.00 | 0.97 | 0.05 | 1.84 |
| 1.31 | 16.85 | 0.01 | 1.29 | 0.07 | 2.54 |
| 0.91 | 15.10 | 0.01 | 1.11 | 0.09 | 2.90 |
| 3.33 | 15.08 | 0.01 | 1.06 | 0.06 | 3.21 |
| 0.02 | 15.02 | 0.01 | 1.14 | 0.15 | 6.30 |
