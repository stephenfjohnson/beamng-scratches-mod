# roofdrop - 20261114-195605_roofdrop_resumed-selected-full-fast-vulkan-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.112 s - 388 frames, 75.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1004 | 55 | 55 | 0 | 60 | 17 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 566, BelowThresh 383

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.681 | 3.387 | 37.038 |
| whole frame, ms | 12.551 (p50) | 15.453 | 50.259 |
| all GE Lua, ms | | 4.265 | 37.908 |
| physics + vehicle Lua, ms | | 0.073 | 0.541 |
| render, ms | | 1.559 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 37.011 ms, worst composite 0.141 ms.
- Detector: 1.389 us per contact, 3.389 ms total, worst frame 0.332 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.26 | 36.26 | 0.71 | 0.04 | 1.55 |
| 2.20 | 49.28 | 34.66 | 0.76 | 0.04 | 1.56 |
| 2.47 | 49.25 | 36.23 | 0.76 | 0.03 | 1.20 |
| 3.64 | 49.23 | 36.57 | 0.92 | 0.05 | 1.28 |
| 1.41 | 49.20 | 36.26 | 0.72 | 0.03 | 1.11 |
