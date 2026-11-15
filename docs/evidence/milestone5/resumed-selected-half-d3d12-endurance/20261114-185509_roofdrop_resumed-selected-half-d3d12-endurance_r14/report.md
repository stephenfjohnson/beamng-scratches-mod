# roofdrop - 20261114-185509_roofdrop_resumed-selected-half-d3d12-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.375 s - 548 frames, 85.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1595 | 52 | 52 | 0 | 54 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 915, BelowThresh 628

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.986 | 2.675 | 31.387 |
| whole frame, ms | 11.215 (p50) | 15.302 | 42.682 |
| all GE Lua, ms | | 3.502 | 32.31 |
| physics + vehicle Lua, ms | | 0.074 | 0.187 |
| render, ms | | 2.439 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 31.362 ms, worst composite 0.098 ms.
- Detector: 1.35 us per contact, 4.72 ms total, worst frame 0.483 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.12 | 42.68 | 31.39 | 0.84 | 0.04 | 1.83 |
| 2.49 | 41.44 | 26.26 | 0.98 | 0.07 | 2.84 |
| 0.81 | 40.96 | 29.67 | 0.89 | 0.06 | 1.83 |
| 1.13 | 40.78 | 29.36 | 1.18 | 0.06 | 2.06 |
| 1.40 | 40.54 | 29.22 | 0.82 | 0.04 | 2.14 |
