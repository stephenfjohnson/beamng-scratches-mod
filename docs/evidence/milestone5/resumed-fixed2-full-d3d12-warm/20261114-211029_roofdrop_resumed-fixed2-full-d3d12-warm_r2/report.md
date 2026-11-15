# roofdrop - 20261114-211029_roofdrop_resumed-fixed2-full-d3d12-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.282 s - 449 frames, 83.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1205 | 54 | 54 | 0 | 55 | 17 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 705, BelowThresh 446

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.671 | 16.398 | 30.332 |
| whole frame, ms | 11.063 (p50) | 23.94 | 41.576 |
| all GE Lua, ms | | 17.257 | 31.506 |
| physics + vehicle Lua, ms | | 0.079 | 0.575 |
| render, ms | | 2.099 | |

- Painter frames over 4 ms: 41; worst flush (project + bake) 30.304 ms, worst composite 0.101 ms.
- Detector: 1.308 us per contact, 3.696 ms total, worst frame 0.336 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 41.58 | 29.66 | 0.87 | 0.08 | 1.94 |
| 3.60 | 41.23 | 29.43 | 0.80 | 0.03 | 1.62 |
| 1.14 | 41.16 | 30.33 | 0.95 | 0.04 | 1.72 |
| 1.41 | 40.83 | 30.22 | 1.14 | 0.05 | 1.60 |
| 1.84 | 40.81 | 30.09 | 0.78 | 0.04 | 1.67 |
