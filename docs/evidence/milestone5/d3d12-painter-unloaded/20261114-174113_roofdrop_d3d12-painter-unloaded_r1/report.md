# roofdrop - 20261114-174113_roofdrop_d3d12-painter-unloaded_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.048 s - 451 frames, 89.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.009 | 0.023 |
| whole frame, ms | 11.182 (p50) | 12.946 | 22.036 |
| all GE Lua, ms | | 1.077 | 2.001 |
| physics + vehicle Lua, ms | | 0.074 | 0.131 |
| render, ms | | 2.351 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.187 us per contact, 2.135 ms total, worst frame 0.048 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.96 | 22.04 | 0.01 | 0.82 | 0.04 | 1.69 |
| 4.36 | 17.56 | 0.01 | 0.94 | 0.05 | 2.10 |
| 4.41 | 16.95 | 0.01 | 0.90 | 0.04 | 2.41 |
| 3.81 | 15.66 | 0.01 | 0.87 | 0.04 | 1.89 |
| 2.56 | 14.75 | 0.00 | 0.77 | 0.04 | 1.89 |
