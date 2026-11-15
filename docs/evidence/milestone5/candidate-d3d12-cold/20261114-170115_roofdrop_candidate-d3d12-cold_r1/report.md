# roofdrop - 20261114-170115_roofdrop_candidate-d3d12-cold_r1

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 5.128 s - 406 frames, 79.0 fps average (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1095 | 50 | 50 | 0 | 55 | 16 | 17 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 632, BelowThresh 413

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.546 | 8.356 | 53.116 |
| whole frame, ms | 11.555 (p50) | 24.968 | 65.55 |
| all GE Lua, ms | | 10.154 | 54.462 |
| physics + vehicle Lua, ms | | 0.145 | 0.577 |
| render, ms | | 3.524 | |

- Painter frames over 4 ms: 28; worst flush (project + bake) 24.769 ms, worst composite 0.165 ms.
- Detector: 2.597 us per contact, 6.522 ms total, worst frame 1.012 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.57 | 65.55 | 51.50 | 24.93 | 0.08 | 2.21 |
| 0.75 | 64.82 | 53.12 | 47.68 | 0.09 | 2.58 |
| 2.23 | 62.50 | 49.92 | 19.25 | 0.07 | 3.30 |
| 0.97 | 60.91 | 50.99 | 47.50 | 0.09 | 2.06 |
| 0.95 | 59.39 | 46.10 | 17.01 | 0.10 | 4.44 |
