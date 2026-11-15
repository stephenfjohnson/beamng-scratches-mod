# baseline - 20261114-165348_baseline_candidate-d3d12-warm_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: False after 4.001 s - 346 frames, 86.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4268 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4268

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.011 | 0.014 | 0.05 |
| whole frame, ms | 11.204 (p50) | 15.235 | 21.037 |
| all GE Lua, ms | | 1.514 | 4.142 |
| physics + vehicle Lua, ms | | 0.185 | 0.432 |
| render, ms | | 3.831 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.911 us per contact, 6.639 ms total, worst frame 1.064 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.55 | 21.04 | 0.01 | 3.88 | 0.17 | 3.42 |
| 2.40 | 20.21 | 0.01 | 1.43 | 0.05 | 3.85 |
| 0.30 | 17.88 | 0.01 | 4.14 | 0.22 | 3.66 |
| 3.28 | 17.21 | 0.01 | 1.20 | 0.05 | 3.44 |
| 3.21 | 17.12 | 0.01 | 1.04 | 0.07 | 3.43 |
