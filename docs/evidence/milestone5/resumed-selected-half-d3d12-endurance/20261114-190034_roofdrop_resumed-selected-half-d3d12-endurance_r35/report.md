# roofdrop - 20261114-190034_roofdrop_resumed-selected-half-d3d12-endurance_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.305 s - 461 frames, 86.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1217 | 52 | 52 | 0 | 54 | 12 | 20 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 698, BelowThresh 467

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.847 | 2.752 | 31.707 |
| whole frame, ms | 11.097 (p50) | 14.752 | 42.514 |
| all GE Lua, ms | | 3.747 | 32.746 |
| physics + vehicle Lua, ms | | 0.078 | 0.131 |
| render, ms | | 2.577 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 31.678 ms, worst composite 0.099 ms.
- Detector: 1.383 us per contact, 3.947 ms total, worst frame 0.34 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 42.51 | 30.61 | 0.86 | 0.05 | 1.80 |
| 1.14 | 41.11 | 30.57 | 1.03 | 0.05 | 1.95 |
| 1.83 | 40.88 | 29.46 | 0.92 | 0.04 | 1.66 |
| 1.40 | 40.80 | 28.93 | 1.02 | 0.04 | 1.85 |
| 2.19 | 40.70 | 31.71 | 1.13 | 0.10 | 1.76 |
