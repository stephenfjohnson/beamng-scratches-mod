# baseline - 20261114-164354_baseline_original-d3d12-cold_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: False after 4.005 s - 357 frames, 89.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4443 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4443

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.01 | 0.013 |
| whole frame, ms | 11.045 (p50) | 14.241 | 16.324 |
| all GE Lua, ms | | 1.266 | 3.682 |
| physics + vehicle Lua, ms | | 0.117 | 0.304 |
| render, ms | | 3.147 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.703 us per contact, 4.969 ms total, worst frame 0.402 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.00 | 16.32 | 0.01 | 1.23 | 0.10 | 2.06 |
| 3.43 | 16.23 | 0.01 | 1.29 | 0.09 | 3.07 |
| 2.50 | 16.15 | 0.01 | 3.29 | 0.05 | 3.56 |
| 2.20 | 16.08 | 0.01 | 1.07 | 0.05 | 3.20 |
| 0.37 | 16.06 | 0.01 | 1.02 | 0.12 | 3.35 |
