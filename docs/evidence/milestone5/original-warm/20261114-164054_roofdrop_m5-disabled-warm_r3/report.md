# roofdrop - 20261114-164054_roofdrop_m5-disabled-warm_r3

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.969 s - 430 frames, 86.3 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1051 | 49 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 611, BelowThresh 391

Body materials: METAL 48, PLASTIC 1

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.007 | 0.015 |
| whole frame, ms | 11.465 (p50) | 15.154 | 19.722 |
| all GE Lua, ms | | 1.185 | 5.276 |
| physics + vehicle Lua, ms | | 0.105 | 0.384 |
| render, ms | | 3.49 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.682 us per contact, 4.029 ms total, worst frame 0.031 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.62 | 19.72 | 0.01 | 0.97 | 0.05 | 3.22 |
| 1.77 | 17.95 | 0.01 | 0.99 | 0.07 | 2.39 |
| 3.91 | 17.59 | 0.01 | 0.79 | 0.04 | 3.38 |
| 4.23 | 17.55 | 0.01 | 0.79 | 0.06 | 3.39 |
| 1.04 | 17.23 | 0.01 | 1.08 | 0.07 | 3.93 |
