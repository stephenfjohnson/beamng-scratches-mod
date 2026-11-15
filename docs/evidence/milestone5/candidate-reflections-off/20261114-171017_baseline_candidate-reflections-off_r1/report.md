# baseline - 20261114-171017_baseline_candidate-reflections-off_r1

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.006 s - 350 frames, 87.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4355 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4355

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.011 | 0.013 | 0.191 |
| whole frame, ms | 11.303 (p50) | 14.799 | 20.792 |
| all GE Lua, ms | | 1.438 | 4.063 |
| physics + vehicle Lua, ms | | 0.126 | 0.18 |
| render, ms | | 3.402 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.732 us per contact, 5.127 ms total, worst frame 0.491 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.23 | 20.79 | 0.01 | 1.05 | 0.06 | 3.16 |
| 2.67 | 18.66 | 0.01 | 4.06 | 0.07 | 3.24 |
| 1.31 | 18.21 | 0.01 | 1.08 | 0.07 | 6.41 |
| 3.14 | 17.71 | 0.01 | 1.06 | 0.06 | 2.98 |
| 2.68 | 17.53 | 0.01 | 1.07 | 0.06 | 2.99 |
