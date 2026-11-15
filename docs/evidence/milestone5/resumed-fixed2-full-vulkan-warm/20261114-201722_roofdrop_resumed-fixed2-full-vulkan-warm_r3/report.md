# roofdrop - 20261114-201722_roofdrop_resumed-fixed2-full-vulkan-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.292 s - 476 frames, 75.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1330 | 54 | 54 | 0 | 57 | 18 | 28 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 781, BelowThresh 495

Body materials: METAL 53, PLASTIC 1

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.363 | 3.138 | 37.205 |
| whole frame, ms | 12.671 (p50) | 15.3 | 49.999 |
| all GE Lua, ms | | 4.234 | 38.237 |
| physics + vehicle Lua, ms | | 0.079 | 0.268 |
| render, ms | | 1.888 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 37.176 ms, worst composite 0.094 ms.
- Detector: 1.387 us per contact, 4.295 ms total, worst frame 0.323 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.00 | 37.21 | 1.07 | 0.12 | 1.40 |
| 2.49 | 49.38 | 36.31 | 1.00 | 0.06 | 1.10 |
| 3.61 | 49.15 | 36.25 | 1.16 | 0.18 | 1.30 |
| 0.80 | 49.14 | 33.85 | 1.00 | 0.06 | 2.02 |
| 5.12 | 48.87 | 36.09 | 0.78 | 0.09 | 1.34 |
