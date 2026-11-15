# roofdrop - 20261114-174126_roofdrop_d3d12-painter-unloaded_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.335 s - 475 frames, 88.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.009 | 0.018 |
| whole frame, ms | 11.255 (p50) | 12.676 | 17.529 |
| all GE Lua, ms | | 1.031 | 2.515 |
| physics + vehicle Lua, ms | | 0.075 | 0.179 |
| render, ms | | 2.455 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.181 us per contact, 2.391 ms total, worst frame 0.116 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.12 | 17.53 | 0.01 | 0.86 | 0.05 | 2.71 |
| 2.93 | 17.01 | 0.01 | 0.96 | 0.04 | 2.89 |
| 4.05 | 14.15 | 0.01 | 0.87 | 0.08 | 3.02 |
| 1.43 | 14.11 | 0.01 | 1.03 | 0.05 | 3.14 |
| 3.58 | 13.89 | 0.01 | 1.19 | 0.08 | 3.10 |
