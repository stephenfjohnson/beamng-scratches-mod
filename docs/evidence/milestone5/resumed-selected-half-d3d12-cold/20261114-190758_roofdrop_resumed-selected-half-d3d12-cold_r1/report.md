# roofdrop - 20261114-190758_roofdrop_resumed-selected-half-d3d12-cold_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.527 s - 398 frames, 87.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1028 | 48 | 48 | 0 | 57 | 14 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 598, BelowThresh 382

Body materials: METAL 46, PLASTIC 2

Surfaces: ASPHALT 48

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.243 | 6.763 | 32.263 |
| whole frame, ms | 10.862 (p50) | 14.91 | 42.793 |
| all GE Lua, ms | | 7.871 | 33.315 |
| physics + vehicle Lua, ms | | 0.074 | 0.128 |
| render, ms | | 2.149 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 32.192 ms, worst composite 0.099 ms.
- Detector: 1.492 us per contact, 3.636 ms total, worst frame 0.473 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.40 | 42.79 | 32.26 | 0.75 | 0.06 | 1.73 |
| 2.19 | 42.55 | 31.15 | 0.89 | 0.07 | 1.95 |
| 0.52 | 41.51 | 29.89 | 0.92 | 0.05 | 2.06 |
| 2.48 | 40.27 | 29.05 | 0.94 | 0.05 | 1.63 |
| 0.80 | 40.18 | 29.02 | 0.92 | 0.06 | 1.75 |
