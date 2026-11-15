# roofdrop - 20261114-220855_roofdrop_synth-full-vk-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.164 s - 491 frames, 78.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1387 | 54 | 54 | 0 | 56 | 17 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 801, BelowThresh 532

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.173 | 1.17 | 7.83 |
| whole frame, ms | 12.556 (p50) | 16.468 | 23.08 |
| all GE Lua, ms | | 2.678 | 8.809 |
| physics + vehicle Lua, ms | | 0.08 | 0.208 |
| render, ms | | 2.482 | |

- Painter frames over 4 ms: 2; worst flush (project + bake) 1.355 ms, worst composite 0.068 ms.
- Detector: 1.734 us per contact, 5.293 ms total, worst frame 0.48 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.12 | 23.08 | 0.48 | 0.88 | 0.09 | 1.41 |
| 0.86 | 20.38 | 3.08 | 2.17 | 0.05 | 2.12 |
| 0.54 | 19.43 | 7.83 | 1.25 | 0.12 | 1.88 |
| 0.59 | 19.14 | 5.62 | 2.09 | 0.07 | 1.48 |
| 2.29 | 18.87 | 2.32 | 1.25 | 0.05 | 1.66 |
