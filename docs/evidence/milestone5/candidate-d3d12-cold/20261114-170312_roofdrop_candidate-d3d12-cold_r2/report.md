# roofdrop - 20261114-170312_roofdrop_candidate-d3d12-cold_r2

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.31 s - 445 frames, 83.6 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1155 | 53 | 53 | 0 | 52 | 15 | 13 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 681, BelowThresh 421

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.312 | 7.55 | 51.626 |
| whole frame, ms | 10.731 (p50) | 26.148 | 61.477 |
| all GE Lua, ms | | 8.973 | 53.021 |
| physics + vehicle Lua, ms | | 0.121 | 0.557 |
| render, ms | | 3.29 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 28.735 ms, worst composite 0.163 ms.
- Detector: 2.614 us per contact, 7.01 ms total, worst frame 0.683 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.75 | 61.48 | 51.63 | 45.22 | 0.08 | 2.31 |
| 0.95 | 57.97 | 43.60 | 15.90 | 0.11 | 2.69 |
| 1.57 | 57.68 | 45.95 | 30.13 | 0.08 | 2.84 |
| 0.74 | 54.39 | 43.92 | 25.85 | 0.10 | 2.82 |
| 2.28 | 52.06 | 41.19 | 18.86 | 0.07 | 2.35 |
