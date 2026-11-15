# roofdrop - 20261114-165502_roofdrop_candidate-one-project_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(1)`

Settled: True after 4.921 s - 371 frames, 75.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 952 | 46 | 46 | 0 | 50 | 15 | 16 | 0.0% | 0 | 12 |

Rejected contacts: PartExcluded 565, BelowThresh 341

Body materials: METAL 45, PLASTIC 1

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.838 | 15.132 | 41.766 |
| whole frame, ms | 11.37 (p50) | 26.668 | 53.461 |
| all GE Lua, ms | | 16.799 | 42.989 |
| physics + vehicle Lua, ms | | 0.123 | 0.386 |
| render, ms | | 3.706 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 31.04 ms, worst composite 0.143 ms.
- Detector: 2.463 us per contact, 5.887 ms total, worst frame 0.96 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.80 | 53.46 | 41.68 | 30.60 | 0.10 | 3.39 |
| 0.95 | 52.71 | 41.19 | 25.93 | 0.09 | 3.21 |
| 1.36 | 52.39 | 41.77 | 25.67 | 0.09 | 2.64 |
| 1.98 | 43.62 | 34.13 | 22.61 | 0.08 | 2.25 |
| 0.52 | 43.58 | 31.07 | 1.17 | 0.10 | 3.15 |
