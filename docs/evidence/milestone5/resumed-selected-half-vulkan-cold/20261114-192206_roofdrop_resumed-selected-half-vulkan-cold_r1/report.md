# roofdrop - 20261114-192206_roofdrop_resumed-selected-half-vulkan-cold_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.24 s - 406 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1134 | 49 | 49 | 0 | 53 | 14 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 670, BelowThresh 415

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.123 | 0.833 | 36.075 |
| whole frame, ms | 12.365 (p50) | 14.718 | 48.565 |
| all GE Lua, ms | | 1.794 | 36.96 |
| physics + vehicle Lua, ms | | 0.073 | 0.207 |
| render, ms | | 1.746 | |

- Painter frames over 4 ms: 13; worst flush (project + bake) 36.056 ms, worst composite 0.076 ms.
- Detector: 1.51 us per contact, 3.988 ms total, worst frame 0.536 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 48.56 | 35.26 | 0.84 | 0.09 | 1.75 |
| 1.13 | 48.35 | 36.07 | 0.83 | 0.06 | 1.22 |
| 0.52 | 48.29 | 35.43 | 1.08 | 0.06 | 1.97 |
| 1.83 | 47.77 | 35.70 | 0.83 | 0.05 | 1.30 |
| 1.39 | 47.60 | 35.44 | 1.24 | 0.09 | 1.43 |
