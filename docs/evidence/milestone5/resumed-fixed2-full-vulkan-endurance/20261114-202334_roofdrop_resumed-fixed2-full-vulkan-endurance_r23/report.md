# roofdrop - 20261114-202334_roofdrop_resumed-fixed2-full-vulkan-endurance_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.123 s - 387 frames, 75.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1052 | 51 | 51 | 0 | 56 | 14 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 603, BelowThresh 398

Body materials: METAL 50, PLASTIC 1

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.35 | 4.068 | 37.287 |
| whole frame, ms | 12.575 (p50) | 16.767 | 49.785 |
| all GE Lua, ms | | 5.546 | 38.218 |
| physics + vehicle Lua, ms | | 0.106 | 0.193 |
| render, ms | | 2.007 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 37.264 ms, worst composite 0.066 ms.
- Detector: 1.73 us per contact, 4.273 ms total, worst frame 0.547 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 49.78 | 35.31 | 1.14 | 0.17 | 2.07 |
| 2.20 | 49.71 | 36.40 | 1.00 | 0.09 | 1.56 |
| 3.67 | 49.62 | 37.29 | 0.94 | 0.07 | 1.17 |
| 0.80 | 49.52 | 35.55 | 1.08 | 0.07 | 1.42 |
| 1.13 | 49.45 | 35.91 | 0.90 | 0.04 | 1.31 |
