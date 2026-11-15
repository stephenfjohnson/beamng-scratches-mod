# roofdrop - 20261114-210717_roofdrop_resumed-grouped-full-b6-vulkan-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.291 s - 464 frames, 73.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1273 | 58 | 58 | 0 | 55 | 17 | 18 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 681, BelowThresh 534

Body materials: METAL 56, PLASTIC 2

Surfaces: ASPHALT 58

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.387 | 3.279 | 54.763 |
| whole frame, ms | 12.487 (p50) | 24.764 | 74.526 |
| all GE Lua, ms | | 4.17 | 55.687 |
| physics + vehicle Lua, ms | | 0.082 | 1.457 |
| render, ms | | 1.682 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 54.742 ms, worst composite 0.043 ms.
- Detector: 1.329 us per contact, 4.4 ms total, worst frame 0.61 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.55 | 74.53 | 54.76 | 0.99 | 0.13 | 1.44 |
| 0.82 | 50.22 | 31.07 | 0.76 | 0.04 | 1.79 |
| 1.41 | 50.18 | 37.27 | 0.78 | 0.07 | 1.35 |
| 5.01 | 49.78 | 37.69 | 0.76 | 0.06 | 1.27 |
| 2.21 | 48.32 | 36.20 | 0.83 | 0.03 | 1.18 |
