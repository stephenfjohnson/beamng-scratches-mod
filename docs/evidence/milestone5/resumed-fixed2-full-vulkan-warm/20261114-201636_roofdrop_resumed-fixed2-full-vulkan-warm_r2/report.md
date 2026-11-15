# roofdrop - 20261114-201636_roofdrop_resumed-fixed2-full-vulkan-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.955 s - 374 frames, 75.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 947 | 52 | 52 | 0 | 59 | 16 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 566, BelowThresh 329

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.638 | 3.906 | 38.529 |
| whole frame, ms | 12.534 (p50) | 18.289 | 51.001 |
| all GE Lua, ms | | 5.292 | 39.415 |
| physics + vehicle Lua, ms | | 0.087 | 0.189 |
| render, ms | | 1.63 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 38.507 ms, worst composite 0.32 ms.
- Detector: 1.62 us per contact, 3.595 ms total, worst frame 0.333 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 51.00 | 38.53 | 0.91 | 0.12 | 1.21 |
| 0.80 | 49.43 | 37.15 | 0.74 | 0.05 | 1.36 |
| 1.13 | 48.94 | 36.12 | 0.87 | 0.04 | 1.25 |
| 1.41 | 48.61 | 36.26 | 0.81 | 0.05 | 1.32 |
| 1.83 | 48.53 | 35.92 | 0.84 | 0.05 | 1.57 |
