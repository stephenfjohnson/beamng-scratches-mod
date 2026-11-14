# roofdrop - 20261114-164037_roofdrop_m5-disabled-warm_r1

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 7.743 s - 670 frames, 86.4 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1948 | 63 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 1104, BelowThresh 781

Body materials: METAL 61, PLASTIC 2

Surfaces: ASPHALT 63

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.007 | 0.047 |
| whole frame, ms | 11.461 (p50) | 13.993 | 24.438 |
| all GE Lua, ms | | 1.001 | 3.276 |
| physics + vehicle Lua, ms | | 0.084 | 0.28 |
| render, ms | | 3.071 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.459 us per contact, 6.012 ms total, worst frame 0.052 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.36 | 24.44 | 0.00 | 0.81 | 0.06 | 2.32 |
| 4.46 | 19.62 | 0.00 | 0.88 | 0.06 | 2.48 |
| 4.85 | 18.19 | 0.00 | 0.71 | 0.04 | 2.65 |
| 6.61 | 17.59 | 0.00 | 0.94 | 0.04 | 2.22 |
| 3.67 | 16.60 | 0.01 | 0.86 | 0.05 | 2.66 |
