# roofdrop - 20261114-193746_roofdrop_resumed-selected-half-vulkan-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.321 s - 490 frames, 77.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1369 | 60 | 60 | 0 | 50 | 17 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 787, BelowThresh 522

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.156 | 0.572 | 37.424 |
| whole frame, ms | 12.515 (p50) | 15.984 | 50.277 |
| all GE Lua, ms | | 1.465 | 38.352 |
| physics + vehicle Lua, ms | | 0.068 | 0.387 |
| render, ms | | 1.574 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 37.403 ms, worst composite 0.047 ms.
- Detector: 1.345 us per contact, 4.65 ms total, worst frame 0.508 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.28 | 37.42 | 0.81 | 0.07 | 1.21 |
| 1.14 | 49.19 | 35.55 | 0.70 | 0.05 | 1.34 |
| 1.99 | 48.86 | 35.63 | 0.85 | 0.04 | 1.27 |
| 1.40 | 48.72 | 35.48 | 0.89 | 0.04 | 1.13 |
| 0.80 | 48.56 | 33.91 | 1.09 | 0.06 | 1.25 |
