# baseline - 20261114-170122_baseline_candidate-d3d12-cold_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.002 s - 333 frames, 83.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4115 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4115

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.01 | 0.013 | 0.125 |
| whole frame, ms | 11.69 (p50) | 14.249 | 25.999 |
| all GE Lua, ms | | 1.66 | 4.791 |
| physics + vehicle Lua, ms | | 0.187 | 0.379 |
| render, ms | | 3.961 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.933 us per contact, 6.656 ms total, worst frame 0.873 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.28 | 26.00 | 0.12 | 1.45 | 0.16 | 3.29 |
| 1.03 | 23.70 | 0.01 | 1.27 | 0.07 | 3.53 |
| 0.03 | 21.97 | 0.01 | 4.02 | 0.31 | 8.41 |
| 3.53 | 18.42 | 0.01 | 1.55 | 0.06 | 5.95 |
| 0.97 | 18.20 | 0.01 | 1.24 | 0.09 | 3.23 |
