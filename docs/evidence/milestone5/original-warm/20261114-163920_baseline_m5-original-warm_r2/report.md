# baseline - 20261114-163920_baseline_m5-original-warm_r2

_upright, coasting at 15 m/s - should leave no marks_

Settled: False after 4.008 s - 356 frames, 88.6 fps average (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4740 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4740

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.006 | 0.025 |
| whole frame, ms | 11.12 (p50) | 14.491 | 18.407 |
| all GE Lua, ms | | 1.113 | 6.776 |
| physics + vehicle Lua, ms | | 0.126 | 0.212 |
| render, ms | | 3.537 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.461 us per contact, 4.296 ms total, worst frame 0.565 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.58 | 18.41 | 0.00 | 0.72 | 0.07 | 2.21 |
| 1.39 | 17.69 | 0.01 | 0.85 | 0.07 | 2.83 |
| 0.97 | 16.47 | 0.00 | 0.79 | 0.05 | 3.20 |
| 0.96 | 16.17 | 0.00 | 0.76 | 0.07 | 3.11 |
| 2.57 | 15.98 | 0.00 | 0.91 | 0.06 | 3.45 |
