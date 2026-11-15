# baseline - 20261114-170319_baseline_candidate-d3d12-cold_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.005 s - 355 frames, 88.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4513 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4513

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.01 | 0.012 | 0.071 |
| whole frame, ms | 10.913 (p50) | 14.241 | 21.852 |
| all GE Lua, ms | | 1.539 | 5.271 |
| physics + vehicle Lua, ms | | 0.166 | 2.818 |
| render, ms | | 3.588 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.183 us per contact, 8.373 ms total, worst frame 0.927 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.46 | 21.85 | 0.01 | 3.85 | 0.16 | 3.57 |
| 0.03 | 17.22 | 0.01 | 1.23 | 0.21 | 8.53 |
| 2.85 | 17.16 | 0.01 | 5.27 | 0.10 | 2.79 |
| 1.78 | 16.09 | 0.01 | 1.18 | 0.10 | 3.83 |
| 2.09 | 15.87 | 0.01 | 1.36 | 0.08 | 3.39 |
