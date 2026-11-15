# baseline - 20261114-171109_baseline_candidate-reflections-off_r3

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.005 s - 346 frames, 86.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4604 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4604

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.01 | 0.013 | 0.034 |
| whole frame, ms | 11.531 (p50) | 14.251 | 18.496 |
| all GE Lua, ms | | 1.253 | 3.43 |
| physics + vehicle Lua, ms | | 0.116 | 0.315 |
| render, ms | | 3.296 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.608 us per contact, 4.714 ms total, worst frame 0.61 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.32 | 18.50 | 0.01 | 1.08 | 0.08 | 3.09 |
| 1.72 | 18.20 | 0.01 | 1.01 | 0.06 | 3.04 |
| 3.67 | 16.04 | 0.02 | 1.20 | 0.06 | 3.55 |
| 0.09 | 15.53 | 0.01 | 0.93 | 0.14 | 2.64 |
| 0.27 | 15.36 | 0.01 | 0.92 | 0.10 | 3.06 |
