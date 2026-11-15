# roofdrop - 20261114-201011_roofdrop_resumed-fixed2-full-vulkan-cold_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.115 s - 390 frames, 76.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 956 | 52 | 52 | 0 | 55 | 15 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 568, BelowThresh 336

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.279 | 3.533 | 36.221 |
| whole frame, ms | 12.495 (p50) | 15.798 | 49.024 |
| all GE Lua, ms | | 4.415 | 37.35 |
| physics + vehicle Lua, ms | | 0.083 | 0.256 |
| render, ms | | 1.895 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 36.185 ms, worst composite 0.185 ms.
- Detector: 1.729 us per contact, 4.204 ms total, worst frame 0.645 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.21 | 49.02 | 36.22 | 0.90 | 0.07 | 1.24 |
| 0.53 | 48.79 | 35.43 | 0.89 | 0.10 | 1.80 |
| 1.41 | 48.29 | 35.29 | 0.77 | 0.07 | 1.18 |
| 3.65 | 48.21 | 35.80 | 0.99 | 0.04 | 1.16 |
| 1.85 | 48.03 | 35.43 | 0.93 | 0.05 | 1.12 |
