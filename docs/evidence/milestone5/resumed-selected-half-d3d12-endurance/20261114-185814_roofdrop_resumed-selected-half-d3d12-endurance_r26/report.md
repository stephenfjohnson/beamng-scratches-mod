# roofdrop - 20261114-185814_roofdrop_resumed-selected-half-d3d12-endurance_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.3 s - 462 frames, 87.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1215 | 56 | 56 | 0 | 59 | 14 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 707, BelowThresh 452

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.05 | 4.073 | 30.935 |
| whole frame, ms | 11.109 (p50) | 13.225 | 41.602 |
| all GE Lua, ms | | 4.908 | 31.912 |
| physics + vehicle Lua, ms | | 0.069 | 0.2 |
| render, ms | | 2.188 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 30.901 ms, worst composite 0.059 ms.
- Detector: 1.294 us per contact, 3.801 ms total, worst frame 0.424 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.12 | 41.60 | 29.79 | 0.77 | 0.05 | 1.87 |
| 0.80 | 41.06 | 29.86 | 0.76 | 0.07 | 1.84 |
| 0.52 | 41.03 | 30.03 | 0.79 | 0.08 | 2.06 |
| 2.48 | 41.01 | 28.93 | 0.89 | 0.06 | 1.97 |
| 1.40 | 40.97 | 29.02 | 0.81 | 0.08 | 1.91 |
