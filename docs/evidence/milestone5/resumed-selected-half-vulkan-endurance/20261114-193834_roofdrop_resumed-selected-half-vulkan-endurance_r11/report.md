# roofdrop - 20261114-193834_roofdrop_resumed-selected-half-vulkan-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.111 s - 393 frames, 76.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1049 | 54 | 54 | 0 | 55 | 14 | 21 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 567, BelowThresh 428

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.265 | 0.843 | 38.435 |
| whole frame, ms | 12.544 (p50) | 14.791 | 50.287 |
| all GE Lua, ms | | 1.87 | 39.471 |
| physics + vehicle Lua, ms | | 0.077 | 0.258 |
| render, ms | | 1.832 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 38.411 ms, worst composite 0.051 ms.
- Detector: 1.394 us per contact, 3.778 ms total, worst frame 0.378 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.29 | 36.76 | 0.81 | 0.10 | 1.42 |
| 1.41 | 49.90 | 38.43 | 0.76 | 0.04 | 1.45 |
| 2.21 | 48.81 | 35.98 | 0.82 | 0.04 | 1.28 |
| 1.85 | 48.56 | 36.39 | 1.14 | 0.06 | 1.39 |
| 0.80 | 48.29 | 34.43 | 0.93 | 0.10 | 1.52 |
