# roofdrop - 20261114-192516_roofdrop_resumed-selected-half-vulkan-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.173 s - 479 frames, 77.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1341 | 57 | 57 | 0 | 62 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 788, BelowThresh 496

Body materials: METAL 55, PLASTIC 2

Surfaces: ASPHALT 57

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.201 | 0.726 | 36.693 |
| whole frame, ms | 12.408 (p50) | 14.657 | 49.559 |
| all GE Lua, ms | | 1.769 | 37.731 |
| physics + vehicle Lua, ms | | 0.069 | 0.155 |
| render, ms | | 1.579 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 36.672 ms, worst composite 0.041 ms.
- Detector: 1.349 us per contact, 4.395 ms total, worst frame 0.726 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.11 | 49.56 | 35.55 | 0.98 | 0.06 | 1.39 |
| 0.53 | 48.98 | 36.40 | 0.90 | 0.08 | 1.54 |
| 1.86 | 48.83 | 36.36 | 0.65 | 0.04 | 1.23 |
| 2.21 | 48.33 | 36.69 | 0.67 | 0.06 | 1.31 |
| 1.40 | 47.97 | 35.48 | 0.82 | 0.03 | 1.10 |
