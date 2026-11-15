# roofdrop - 20261114-202029_roofdrop_resumed-fixed2-full-vulkan-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.132 s - 462 frames, 75.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1282 | 55 | 55 | 0 | 61 | 19 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 747, BelowThresh 480

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.48 | 3.52 | 36.767 |
| whole frame, ms | 12.527 (p50) | 18.265 | 50.191 |
| all GE Lua, ms | | 4.551 | 37.817 |
| physics + vehicle Lua, ms | | 0.083 | 0.309 |
| render, ms | | 1.82 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 36.745 ms, worst composite 0.097 ms.
- Detector: 1.466 us per contact, 4.598 ms total, worst frame 0.433 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.19 | 36.49 | 0.85 | 0.08 | 1.29 |
| 1.85 | 50.16 | 36.77 | 0.79 | 0.04 | 1.12 |
| 3.62 | 49.54 | 36.25 | 1.17 | 0.05 | 1.14 |
| 5.07 | 49.27 | 36.75 | 1.07 | 0.04 | 1.36 |
| 2.21 | 48.46 | 35.43 | 0.96 | 0.05 | 1.13 |
