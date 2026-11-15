# roofdrop - 20261114-193659_roofdrop_resumed-selected-half-vulkan-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.318 s - 482 frames, 76.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1350 | 60 | 60 | 0 | 61 | 18 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 792, BelowThresh 498

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.36 | 0.731 | 38.217 |
| whole frame, ms | 12.552 (p50) | 14.974 | 53.758 |
| all GE Lua, ms | | 1.772 | 39.604 |
| physics + vehicle Lua, ms | | 0.075 | 0.222 |
| render, ms | | 1.61 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 38.187 ms, worst composite 0.07 ms.
- Detector: 1.332 us per contact, 4.144 ms total, worst frame 0.413 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.28 | 53.76 | 0.01 | 1.05 | 0.04 | 1.26 |
| 0.53 | 51.43 | 38.22 | 0.85 | 0.08 | 1.32 |
| 1.14 | 50.26 | 37.63 | 0.76 | 0.04 | 1.35 |
| 3.64 | 49.99 | 37.70 | 0.93 | 0.07 | 1.17 |
| 0.80 | 49.83 | 37.18 | 0.88 | 0.06 | 1.27 |
