# roofdrop - 20261114-202507_roofdrop_resumed-fixed2-full-vulkan-endurance_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.318 s - 478 frames, 75.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1361 | 56 | 56 | 0 | 54 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 796, BelowThresh 509

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.212 | 3.207 | 37.025 |
| whole frame, ms | 12.652 (p50) | 15.866 | 50.647 |
| all GE Lua, ms | | 4.115 | 38.0 |
| physics + vehicle Lua, ms | | 0.081 | 0.16 |
| render, ms | | 1.801 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 36.999 ms, worst composite 0.067 ms.
- Detector: 1.553 us per contact, 5.01 ms total, worst frame 0.604 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.14 | 50.65 | 36.66 | 1.02 | 0.10 | 1.12 |
| 0.53 | 50.39 | 36.64 | 0.95 | 0.09 | 1.31 |
| 1.40 | 49.29 | 36.74 | 0.94 | 0.04 | 1.26 |
| 2.21 | 49.26 | 36.28 | 0.83 | 0.06 | 1.20 |
| 0.81 | 49.14 | 36.32 | 0.78 | 0.04 | 1.35 |
