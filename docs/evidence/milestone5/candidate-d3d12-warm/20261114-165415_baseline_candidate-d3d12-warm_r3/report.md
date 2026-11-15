# baseline - 20261114-165415_baseline_candidate-d3d12-warm_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: False after 4.007 s - 350 frames, 87.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4655 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4655

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.009 | 0.012 | 0.017 |
| whole frame, ms | 11.435 (p50) | 13.749 | 15.472 |
| all GE Lua, ms | | 1.181 | 3.056 |
| physics + vehicle Lua, ms | | 0.117 | 0.167 |
| render, ms | | 3.258 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.616 us per contact, 4.772 ms total, worst frame 0.447 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.25 | 15.47 | 0.01 | 0.79 | 0.05 | 3.61 |
| 2.07 | 15.21 | 0.01 | 0.77 | 0.04 | 2.18 |
| 3.04 | 14.75 | 0.01 | 0.78 | 0.04 | 2.15 |
| 0.28 | 14.64 | 0.01 | 0.85 | 0.09 | 2.87 |
| 0.42 | 14.54 | 0.01 | 0.77 | 0.09 | 3.43 |
