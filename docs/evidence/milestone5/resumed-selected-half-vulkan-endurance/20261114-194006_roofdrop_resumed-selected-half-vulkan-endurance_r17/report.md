# roofdrop - 20261114-194006_roofdrop_resumed-selected-half-vulkan-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.123 s - 392 frames, 76.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 972 | 49 | 49 | 0 | 55 | 16 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 582, BelowThresh 341

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.368 | 0.722 | 36.947 |
| whole frame, ms | 12.455 (p50) | 17.401 | 50.452 |
| all GE Lua, ms | | 3.127 | 38.209 |
| physics + vehicle Lua, ms | | 0.078 | 0.138 |
| render, ms | | 1.937 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 36.929 ms, worst composite 0.058 ms.
- Detector: 1.591 us per contact, 3.959 ms total, worst frame 0.473 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.52 | 50.45 | 36.49 | 0.98 | 0.11 | 1.32 |
| 0.80 | 50.29 | 36.93 | 0.86 | 0.10 | 1.30 |
| 1.83 | 49.69 | 36.85 | 0.81 | 0.04 | 1.10 |
| 2.48 | 49.21 | 34.98 | 0.79 | 0.04 | 1.24 |
| 1.14 | 49.15 | 34.88 | 0.80 | 0.05 | 1.65 |
