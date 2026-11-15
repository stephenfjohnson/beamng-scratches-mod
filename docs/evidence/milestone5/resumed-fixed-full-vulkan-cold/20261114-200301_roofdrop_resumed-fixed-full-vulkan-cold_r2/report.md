# roofdrop - 20261114-200301_roofdrop_resumed-fixed-full-vulkan-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.313 s - 411 frames, 77.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1090 | 55 | 55 | 0 | 61 | 15 | 29 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 620, BelowThresh 415

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.283 | 3.311 | 36.885 |
| whole frame, ms | 12.274 (p50) | 17.283 | 49.314 |
| all GE Lua, ms | | 4.433 | 38.187 |
| physics + vehicle Lua, ms | | 0.085 | 0.257 |
| render, ms | | 1.748 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 36.861 ms, worst composite 0.118 ms.
- Detector: 1.697 us per contact, 4.609 ms total, worst frame 0.648 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.13 | 49.31 | 35.10 | 0.82 | 0.04 | 1.69 |
| 2.20 | 48.52 | 35.70 | 0.91 | 0.04 | 1.13 |
| 1.41 | 48.49 | 36.89 | 1.28 | 0.06 | 1.26 |
| 0.53 | 48.36 | 35.33 | 1.31 | 0.13 | 2.08 |
| 1.84 | 48.09 | 35.47 | 0.79 | 0.07 | 1.08 |
