# roofdrop - 20261114-185202_roofdrop_resumed-selected-half-d3d12-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.118 s - 446 frames, 87.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1201 | 46 | 46 | 0 | 51 | 14 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 707, BelowThresh 448

Body materials: METAL 44, PLASTIC 2

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.051 | 3.11 | 30.791 |
| whole frame, ms | 11.088 (p50) | 13.324 | 42.1 |
| all GE Lua, ms | | 4.962 | 31.615 |
| physics + vehicle Lua, ms | | 0.071 | 0.186 |
| render, ms | | 2.431 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 30.762 ms, worst composite 0.087 ms.
- Detector: 1.317 us per contact, 3.656 ms total, worst frame 0.365 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 42.10 | 29.80 | 0.75 | 0.09 | 1.95 |
| 0.52 | 42.02 | 30.49 | 0.88 | 0.07 | 1.80 |
| 2.46 | 41.52 | 29.69 | 0.90 | 0.05 | 1.76 |
| 1.13 | 41.28 | 29.39 | 0.80 | 0.04 | 2.02 |
| 1.83 | 41.14 | 29.06 | 0.72 | 0.04 | 1.70 |
