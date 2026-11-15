# roofdrop - 20261114-165929_roofdrop_candidate-d3d12-disabled-cold_r3

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.158 s - 452 frames, 87.4 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1136 | 45 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 665, BelowThresh 426

Body materials: METAL 43, PLASTIC 2

Surfaces: ASPHALT 45

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.009 | 0.011 | 0.077 |
| whole frame, ms | 10.889 (p50) | 16.595 | 23.428 |
| all GE Lua, ms | | 1.694 | 5.206 |
| physics + vehicle Lua, ms | | 0.118 | 0.341 |
| render, ms | | 3.155 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 2.376 us per contact, 4.936 ms total, worst frame 0.125 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.43 | 23.43 | 0.01 | 4.09 | 0.09 | 3.05 |
| 1.72 | 22.45 | 0.01 | 1.27 | 0.07 | 2.37 |
| 0.23 | 22.43 | 0.01 | 1.35 | 0.09 | 2.87 |
| 0.32 | 22.17 | 0.01 | 1.22 | 0.10 | 2.57 |
| 4.80 | 20.15 | 0.01 | 3.43 | 0.06 | 2.92 |
