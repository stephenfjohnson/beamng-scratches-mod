# sideslide - 20261114-174134_sideslide_d3d12-painter-unloaded_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 4.229 s - 398 frames, 93.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.166)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.009 | 0.04 |
| whole frame, ms | 10.594 (p50) | 12.278 | 14.165 |
| all GE Lua, ms | | 1.182 | 3.235 |
| physics + vehicle Lua, ms | | 0.085 | 0.146 |
| render, ms | | 2.592 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.104 us per contact, 2.055 ms total, worst frame 0.023 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.90 | 14.17 | 0.01 | 0.91 | 0.05 | 2.06 |
| 3.58 | 14.11 | 0.01 | 0.76 | 0.06 | 2.15 |
| 1.00 | 13.94 | 0.01 | 0.83 | 0.05 | 2.36 |
| 2.57 | 13.58 | 0.01 | 0.89 | 0.05 | 1.89 |
| 3.78 | 13.55 | 0.00 | 0.87 | 0.04 | 1.94 |
