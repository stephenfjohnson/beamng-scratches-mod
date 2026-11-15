# roofdrop - 20261114-210540_roofdrop_resumed-grouped-full-b6-vulkan-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.463 s - 498 frames, 77.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1416 | 62 | 62 | 0 | 55 | 16 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 785, BelowThresh 569

Body materials: METAL 60, PLASTIC 2

Surfaces: ASPHALT 62

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.182 | 1.841 | 35.992 |
| whole frame, ms | 12.504 (p50) | 15.45 | 48.581 |
| all GE Lua, ms | | 3.522 | 36.985 |
| physics + vehicle Lua, ms | | 0.069 | 0.219 |
| render, ms | | 1.569 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 35.966 ms, worst composite 0.05 ms.
- Detector: 1.41 us per contact, 4.639 ms total, worst frame 0.604 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.47 | 48.58 | 32.95 | 0.94 | 0.04 | 1.74 |
| 4.99 | 48.53 | 34.78 | 0.85 | 0.06 | 1.41 |
| 1.40 | 47.92 | 34.84 | 0.82 | 0.07 | 1.15 |
| 3.61 | 47.80 | 34.61 | 0.81 | 0.04 | 1.10 |
| 1.82 | 47.59 | 35.99 | 0.76 | 0.04 | 1.20 |
