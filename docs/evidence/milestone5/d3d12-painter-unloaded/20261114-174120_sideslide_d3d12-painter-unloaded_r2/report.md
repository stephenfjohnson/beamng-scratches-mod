# sideslide - 20261114-174120_sideslide_d3d12-painter-unloaded_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.405 s - 415 frames, 94.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.172)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.05 |
| whole frame, ms | 10.58 (p50) | 11.97 | 15.956 |
| all GE Lua, ms | | 0.998 | 1.385 |
| physics + vehicle Lua, ms | | 0.083 | 0.27 |
| render, ms | | 2.276 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.105 us per contact, 1.977 ms total, worst frame 0.026 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.06 | 15.96 | 0.01 | 0.96 | 0.05 | 3.26 |
| 4.14 | 15.11 | 0.01 | 0.70 | 0.03 | 2.42 |
| 0.32 | 14.48 | 0.01 | 0.83 | 0.05 | 1.80 |
| 1.30 | 13.32 | 0.01 | 1.05 | 0.06 | 2.50 |
| 3.75 | 13.26 | 0.01 | 0.78 | 0.03 | 1.75 |
