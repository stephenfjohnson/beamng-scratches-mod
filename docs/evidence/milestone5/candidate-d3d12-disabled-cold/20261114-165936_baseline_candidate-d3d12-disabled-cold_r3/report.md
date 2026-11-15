# baseline - 20261114-165936_baseline_candidate-d3d12-disabled-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.002 s - 331 frames, 83.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4280 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4280

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.009 | 0.011 | 0.039 |
| whole frame, ms | 11.177 (p50) | 17.805 | 25.623 |
| all GE Lua, ms | | 1.559 | 6.784 |
| physics + vehicle Lua, ms | | 0.173 | 0.273 |
| render, ms | | 3.43 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.746 us per contact, 5.039 ms total, worst frame 0.128 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.68 | 25.62 | 0.01 | 4.25 | 0.12 | 3.28 |
| 1.52 | 22.06 | 0.01 | 3.71 | 0.10 | 2.69 |
| 0.31 | 20.72 | 0.01 | 1.18 | 0.16 | 2.85 |
| 2.34 | 19.90 | 0.01 | 1.18 | 0.07 | 2.82 |
| 1.95 | 19.88 | 0.01 | 1.13 | 0.08 | 3.14 |
