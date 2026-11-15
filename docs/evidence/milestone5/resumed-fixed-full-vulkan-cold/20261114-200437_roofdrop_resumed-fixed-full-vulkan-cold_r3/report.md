# roofdrop - 20261114-200437_roofdrop_resumed-fixed-full-vulkan-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.813 s - 373 frames, 77.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1001 | 44 | 44 | 0 | 46 | 14 | 20 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 571, BelowThresh 386

Body materials: METAL 43, PLASTIC 1

Surfaces: ASPHALT 44

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.384 | 2.825 | 36.276 |
| whole frame, ms | 12.441 (p50) | 16.093 | 49.654 |
| all GE Lua, ms | | 3.889 | 37.674 |
| physics + vehicle Lua, ms | | 0.074 | 0.239 |
| render, ms | | 1.582 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 36.258 ms, worst composite 0.059 ms.
- Detector: 1.416 us per contact, 3.523 ms total, worst frame 0.532 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 49.65 | 35.70 | 1.10 | 0.12 | 1.52 |
| 1.14 | 49.01 | 35.53 | 0.84 | 0.04 | 1.31 |
| 1.85 | 48.99 | 36.28 | 0.89 | 0.04 | 1.22 |
| 2.48 | 48.54 | 34.73 | 0.96 | 0.07 | 1.21 |
| 1.41 | 47.78 | 35.48 | 0.85 | 0.04 | 1.12 |
