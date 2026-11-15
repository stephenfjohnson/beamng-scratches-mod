# baseline - 20261114-165320_baseline_candidate-d3d12-warm_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: False after 4.006 s - 346 frames, 86.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4277 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4277

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.011 | 0.015 | 0.072 |
| whole frame, ms | 11.178 (p50) | 13.314 | 101.352 |
| all GE Lua, ms | | 1.392 | 4.343 |
| physics + vehicle Lua, ms | | 0.158 | 0.196 |
| render, ms | | 3.666 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.831 us per contact, 6.354 ms total, worst frame 0.954 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.49 | 101.35 | 0.01 | 1.49 | 0.09 | 3.63 |
| 1.66 | 18.34 | 0.01 | 1.10 | 0.07 | 3.94 |
| 2.30 | 16.69 | 0.01 | 1.13 | 0.05 | 3.32 |
| 2.16 | 16.03 | 0.01 | 1.60 | 0.05 | 3.50 |
| 1.41 | 15.96 | 0.01 | 1.23 | 0.07 | 2.98 |
