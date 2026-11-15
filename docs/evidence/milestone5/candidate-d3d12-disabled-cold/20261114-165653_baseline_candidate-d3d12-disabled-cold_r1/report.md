# baseline - 20261114-165653_baseline_candidate-d3d12-disabled-cold_r1

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.01 s - 358 frames, 89.0 fps average (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4776 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4776

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.014 |
| whole frame, ms | 10.972 (p50) | 14.411 | 18.777 |
| all GE Lua, ms | | 1.427 | 4.182 |
| physics + vehicle Lua, ms | | 0.154 | 0.359 |
| render, ms | | 3.463 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.579 us per contact, 4.372 ms total, worst frame 0.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.71 | 18.78 | 0.01 | 1.26 | 0.06 | 3.02 |
| 0.70 | 18.40 | 0.01 | 1.56 | 0.12 | 3.28 |
| 0.26 | 17.73 | 0.01 | 4.18 | 0.19 | 3.00 |
| 0.02 | 17.39 | 0.01 | 1.10 | 0.16 | 7.68 |
| 0.40 | 16.96 | 0.01 | 1.01 | 0.14 | 2.98 |
