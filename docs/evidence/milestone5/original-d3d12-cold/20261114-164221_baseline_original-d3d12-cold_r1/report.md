# baseline - 20261114-164221_baseline_original-d3d12-cold_r1

_upright, coasting at 15 m/s - should leave no marks_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: False after 4.01 s - 359 frames, 89.3 fps average (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4675 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4675

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.011 | 0.016 |
| whole frame, ms | 11.039 (p50) | 13.595 | 42.227 |
| all GE Lua, ms | | 1.176 | 2.99 |
| physics + vehicle Lua, ms | | 0.13 | 0.325 |
| render, ms | | 2.836 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.586 us per contact, 4.93 ms total, worst frame 0.868 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.02 | 42.23 | 0.01 | 0.79 | 0.11 | 6.59 |
| 0.03 | 39.66 | 0.01 | 2.99 | 0.17 | 3.62 |
| 3.97 | 17.14 | 0.01 | 1.32 | 0.07 | 3.44 |
| 3.70 | 16.91 | 0.01 | 1.05 | 0.21 | 2.33 |
| 2.50 | 15.59 | 0.01 | 1.00 | 0.05 | 2.58 |
