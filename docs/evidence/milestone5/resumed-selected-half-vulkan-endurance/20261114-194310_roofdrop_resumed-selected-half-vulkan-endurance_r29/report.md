# roofdrop - 20261114-194310_roofdrop_resumed-selected-half-vulkan-endurance_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.139 s - 393 frames, 76.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 973 | 50 | 50 | 0 | 52 | 14 | 20 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 584, BelowThresh 339

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.135 | 0.779 | 37.897 |
| whole frame, ms | 12.514 (p50) | 14.868 | 53.105 |
| all GE Lua, ms | | 1.92 | 39.215 |
| physics + vehicle Lua, ms | | 0.088 | 0.326 |
| render, ms | | 1.949 | |

- Painter frames over 4 ms: 13; worst flush (project + bake) 37.872 ms, worst composite 0.058 ms.
- Detector: 1.523 us per contact, 3.873 ms total, worst frame 0.426 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 53.10 | 37.90 | 0.87 | 0.10 | 1.62 |
| 0.80 | 49.24 | 36.65 | 1.01 | 0.09 | 1.59 |
| 2.48 | 48.30 | 34.68 | 1.29 | 0.11 | 1.21 |
| 2.20 | 48.29 | 36.76 | 0.85 | 0.05 | 1.24 |
| 1.13 | 48.15 | 35.22 | 0.88 | 0.06 | 1.72 |
