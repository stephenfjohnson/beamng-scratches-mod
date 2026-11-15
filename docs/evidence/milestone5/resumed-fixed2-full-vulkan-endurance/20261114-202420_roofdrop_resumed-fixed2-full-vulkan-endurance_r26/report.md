# roofdrop - 20261114-202420_roofdrop_resumed-fixed2-full-vulkan-endurance_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.28 s - 398 frames, 75.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1087 | 51 | 51 | 0 | 56 | 18 | 28 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 620, BelowThresh 416

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.667 | 3.941 | 36.788 |
| whole frame, ms | 12.491 (p50) | 17.691 | 50.394 |
| all GE Lua, ms | | 4.937 | 37.813 |
| physics + vehicle Lua, ms | | 0.088 | 0.74 |
| render, ms | | 1.813 | |

- Painter frames over 4 ms: 20; worst flush (project + bake) 36.76 ms, worst composite 0.05 ms.
- Detector: 1.529 us per contact, 3.891 ms total, worst frame 0.368 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.39 | 36.71 | 0.90 | 0.06 | 1.37 |
| 2.47 | 49.31 | 36.62 | 0.88 | 0.09 | 1.45 |
| 2.21 | 49.24 | 36.73 | 1.05 | 0.04 | 1.40 |
| 1.13 | 49.23 | 35.66 | 0.97 | 0.09 | 1.33 |
| 2.90 | 49.09 | 36.14 | 0.72 | 0.06 | 1.17 |
