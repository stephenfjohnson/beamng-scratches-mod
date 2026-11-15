# roofdrop - 20261114-201324_roofdrop_resumed-fixed2-full-vulkan-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.294 s - 395 frames, 74.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1065 | 52 | 52 | 0 | 58 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 625, BelowThresh 388

Body materials: METAL 51, PLASTIC 1

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.485 | 4.213 | 36.895 |
| whole frame, ms | 12.557 (p50) | 20.213 | 49.811 |
| all GE Lua, ms | | 5.147 | 39.45 |
| physics + vehicle Lua, ms | | 0.083 | 0.32 |
| render, ms | | 2.004 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 36.875 ms, worst composite 0.053 ms.
- Detector: 1.766 us per contact, 4.634 ms total, worst frame 0.646 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 49.81 | 36.89 | 0.80 | 0.11 | 1.81 |
| 0.81 | 48.51 | 34.78 | 0.78 | 0.04 | 1.39 |
| 1.41 | 48.18 | 35.49 | 0.93 | 0.05 | 1.20 |
| 3.64 | 47.94 | 34.59 | 1.00 | 0.04 | 1.47 |
| 1.84 | 47.85 | 35.58 | 0.81 | 0.05 | 1.13 |
