# baseline - 20261114-165442_baseline_candidate-one-project_r1

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: False after 4.008 s - 344 frames, 85.6 fps average (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4583 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4583

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.011 | 0.015 | 0.019 |
| whole frame, ms | 11.584 (p50) | 13.76 | 23.409 |
| all GE Lua, ms | | 1.389 | 4.788 |
| physics + vehicle Lua, ms | | 0.117 | 0.231 |
| render, ms | | 3.829 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.747 us per contact, 6.126 ms total, worst frame 0.87 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.73 | 23.41 | 0.01 | 4.79 | 0.11 | 3.56 |
| 2.26 | 19.67 | 0.01 | 1.09 | 0.06 | 4.02 |
| 3.78 | 18.87 | 0.01 | 1.12 | 0.06 | 3.89 |
| 0.87 | 18.20 | 0.01 | 0.91 | 0.06 | 2.56 |
| 2.40 | 17.36 | 0.01 | 1.10 | 0.08 | 3.68 |
