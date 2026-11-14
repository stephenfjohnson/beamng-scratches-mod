# roofdrop - 20261114-164046_roofdrop_m5-disabled-warm_r2

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.136 s - 445 frames, 86.4 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1199 | 53 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 689, BelowThresh 457

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.007 | 0.018 |
| whole frame, ms | 11.502 (p50) | 14.282 | 19.503 |
| all GE Lua, ms | | 1.095 | 4.318 |
| physics + vehicle Lua, ms | | 0.092 | 0.269 |
| render, ms | | 3.35 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.59 us per contact, 5.148 ms total, worst frame 0.885 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.37 | 19.50 | 0.00 | 4.32 | 0.08 | 2.69 |
| 1.93 | 17.17 | 0.01 | 1.13 | 0.27 | 3.19 |
| 0.12 | 17.06 | 0.01 | 0.91 | 0.06 | 2.95 |
| 3.40 | 16.78 | 0.00 | 0.81 | 0.05 | 2.07 |
| 4.71 | 16.58 | 0.01 | 0.72 | 0.05 | 5.03 |
