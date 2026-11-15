# roofdrop - 20261114-174140_roofdrop_d3d12-painter-unloaded_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.127 s - 457 frames, 88.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.03 |
| whole frame, ms | 11.272 (p50) | 12.514 | 14.808 |
| all GE Lua, ms | | 1.039 | 1.628 |
| physics + vehicle Lua, ms | | 0.071 | 0.221 |
| render, ms | | 2.299 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.179 us per contact, 2.066 ms total, worst frame 0.022 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.70 | 14.81 | 0.01 | 0.80 | 0.05 | 2.77 |
| 1.08 | 14.11 | 0.01 | 0.97 | 0.06 | 2.08 |
| 1.35 | 13.97 | 0.01 | 0.90 | 0.07 | 2.78 |
| 0.61 | 13.93 | 0.01 | 0.84 | 0.04 | 1.85 |
| 1.64 | 13.70 | 0.01 | 0.85 | 0.05 | 2.62 |
