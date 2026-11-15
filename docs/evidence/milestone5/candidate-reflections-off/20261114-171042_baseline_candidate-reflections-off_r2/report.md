# baseline - 20261114-171042_baseline_candidate-reflections-off_r2

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.007 s - 340 frames, 85.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4341 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4341

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.011 | 0.014 | 0.129 |
| whole frame, ms | 11.575 (p50) | 15.252 | 24.047 |
| all GE Lua, ms | | 1.598 | 4.379 |
| physics + vehicle Lua, ms | | 0.161 | 0.356 |
| render, ms | | 3.884 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.734 us per contact, 5.27 ms total, worst frame 0.561 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.44 | 24.05 | 0.01 | 1.23 | 0.05 | 2.73 |
| 3.38 | 21.10 | 0.01 | 1.08 | 0.05 | 3.24 |
| 2.08 | 18.24 | 0.01 | 1.21 | 0.05 | 3.11 |
| 3.71 | 17.16 | 0.01 | 1.25 | 0.07 | 4.20 |
| 3.45 | 16.74 | 0.01 | 4.38 | 0.09 | 2.64 |
