# baseline - 20261114-163925_baseline_m5-original-warm_r3

_upright, coasting at 15 m/s - should leave no marks_

Settled: False after 4.002 s - 354 frames, 88.2 fps average (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4717 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4717

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.004 | 0.006 | 0.007 |
| whole frame, ms | 11.143 (p50) | 14.24 | 16.918 |
| all GE Lua, ms | | 1.02 | 5.214 |
| physics + vehicle Lua, ms | | 0.128 | 0.229 |
| render, ms | | 3.245 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.436 us per contact, 4.161 ms total, worst frame 0.671 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.58 | 16.92 | 0.00 | 0.66 | 0.04 | 3.42 |
| 0.22 | 16.62 | 0.00 | 0.72 | 0.13 | 3.36 |
| 0.19 | 16.50 | 0.00 | 0.80 | 0.14 | 3.17 |
| 0.51 | 16.38 | 0.00 | 0.76 | 0.09 | 2.81 |
| 0.38 | 15.78 | 0.00 | 0.74 | 0.13 | 2.56 |
