# sideslide - 20261114-174107_sideslide_d3d12-painter-unloaded_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.234 s - 399 frames, 93.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.01 | 0.087 |
| whole frame, ms | 10.566 (p50) | 12.206 | 23.938 |
| all GE Lua, ms | | 1.178 | 3.435 |
| physics + vehicle Lua, ms | | 0.087 | 0.234 |
| render, ms | | 2.663 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.114 us per contact, 2.238 ms total, worst frame 0.038 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.87 | 23.94 | 0.01 | 3.38 | 0.09 | 2.90 |
| 2.58 | 19.91 | 0.01 | 1.49 | 0.05 | 2.56 |
| 3.02 | 16.13 | 0.01 | 1.22 | 0.09 | 3.56 |
| 2.83 | 15.13 | 0.01 | 0.95 | 0.06 | 2.02 |
| 2.90 | 14.23 | 0.01 | 1.18 | 0.07 | 1.79 |
