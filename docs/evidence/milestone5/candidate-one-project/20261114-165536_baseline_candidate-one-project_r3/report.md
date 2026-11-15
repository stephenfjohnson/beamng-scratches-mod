# baseline - 20261114-165536_baseline_candidate-one-project_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: False after 4.007 s - 340 frames, 85.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4389 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4389

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.011 | 0.014 | 0.021 |
| whole frame, ms | 11.547 (p50) | 14.885 | 17.912 |
| all GE Lua, ms | | 1.406 | 4.805 |
| physics + vehicle Lua, ms | | 0.163 | 0.636 |
| render, ms | | 3.964 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.813 us per contact, 5.97 ms total, worst frame 0.494 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.90 | 17.91 | 0.01 | 1.03 | 0.06 | 3.26 |
| 0.15 | 16.77 | 0.02 | 1.08 | 0.17 | 4.76 |
| 0.55 | 16.27 | 0.01 | 1.34 | 0.14 | 3.59 |
| 0.84 | 16.03 | 0.01 | 1.28 | 0.10 | 3.70 |
| 0.14 | 15.88 | 0.01 | 1.09 | 0.15 | 3.84 |
