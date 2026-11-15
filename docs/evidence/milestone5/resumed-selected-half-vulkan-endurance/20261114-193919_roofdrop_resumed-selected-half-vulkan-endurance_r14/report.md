# roofdrop - 20261114-193919_roofdrop_resumed-selected-half-vulkan-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.177 s - 471 frames, 76.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1318 | 60 | 60 | 0 | 61 | 18 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 767, BelowThresh 491

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.321 | 0.758 | 37.909 |
| whole frame, ms | 12.612 (p50) | 15.02 | 52.304 |
| all GE Lua, ms | | 1.757 | 39.474 |
| physics + vehicle Lua, ms | | 0.068 | 0.148 |
| render, ms | | 1.669 | |

- Painter frames over 4 ms: 20; worst flush (project + bake) 37.878 ms, worst composite 0.064 ms.
- Detector: 1.33 us per contact, 4.571 ms total, worst frame 0.48 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 52.30 | 37.91 | 1.03 | 0.10 | 1.17 |
| 1.13 | 49.50 | 36.34 | 0.84 | 0.03 | 1.24 |
| 1.41 | 49.29 | 36.49 | 0.92 | 0.05 | 1.59 |
| 2.22 | 49.20 | 35.02 | 0.87 | 0.03 | 1.36 |
| 3.61 | 49.05 | 36.38 | 0.73 | 0.03 | 1.10 |
