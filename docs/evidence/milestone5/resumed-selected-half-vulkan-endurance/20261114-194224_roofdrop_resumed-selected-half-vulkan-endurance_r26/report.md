# roofdrop - 20261114-194224_roofdrop_resumed-selected-half-vulkan-endurance_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.502 s - 425 frames, 77.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1067 | 50 | 50 | 0 | 49 | 16 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 652, BelowThresh 365

Body materials: METAL 49, PLASTIC 1

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.285 | 0.826 | 37.5 |
| whole frame, ms | 12.557 (p50) | 14.411 | 49.785 |
| all GE Lua, ms | | 1.894 | 38.42 |
| physics + vehicle Lua, ms | | 0.068 | 0.186 |
| render, ms | | 1.538 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 37.482 ms, worst composite 0.302 ms.
- Detector: 1.403 us per contact, 3.772 ms total, worst frame 0.434 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.13 | 49.78 | 37.50 | 0.81 | 0.05 | 1.32 |
| 0.53 | 49.49 | 36.66 | 0.88 | 0.07 | 1.17 |
| 1.84 | 49.08 | 36.07 | 1.11 | 0.19 | 1.12 |
| 2.19 | 49.07 | 32.19 | 1.08 | 0.05 | 1.46 |
| 0.80 | 48.66 | 36.10 | 0.82 | 0.07 | 1.25 |
