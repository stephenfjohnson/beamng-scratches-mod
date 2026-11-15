# roofdrop - 20261114-171009_roofdrop_candidate-reflections-off_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 6.283 s - 537 frames, 81.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1482 | 58 | 58 | 0 | 54 | 17 | 16 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 801, BelowThresh 623

Body materials: METAL 56, PLASTIC 2

Surfaces: ASPHALT 58

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.395 | 5.611 | 41.672 |
| whole frame, ms | 11.232 (p50) | 18.602 | 49.866 |
| all GE Lua, ms | | 6.501 | 42.587 |
| physics + vehicle Lua, ms | | 0.085 | 0.222 |
| render, ms | | 2.688 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 33.47 ms, worst composite 0.099 ms.
- Detector: 1.842 us per contact, 5.679 ms total, worst frame 0.524 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.96 | 49.87 | 41.67 | 37.54 | 0.06 | 1.97 |
| 1.15 | 47.98 | 38.51 | 30.62 | 0.05 | 2.30 |
| 1.57 | 46.22 | 37.71 | 34.53 | 0.06 | 1.79 |
| 0.74 | 45.63 | 37.63 | 34.10 | 0.05 | 1.94 |
| 0.95 | 45.07 | 36.56 | 34.50 | 0.07 | 2.08 |
