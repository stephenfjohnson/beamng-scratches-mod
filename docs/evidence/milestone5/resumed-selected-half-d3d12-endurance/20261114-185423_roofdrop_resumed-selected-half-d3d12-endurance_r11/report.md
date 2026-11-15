# roofdrop - 20261114-185423_roofdrop_resumed-selected-half-d3d12-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.418 s - 469 frames, 86.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1318 | 56 | 56 | 0 | 58 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 735, BelowThresh 527

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.04 | 4.497 | 30.776 |
| whole frame, ms | 11.111 (p50) | 13.486 | 42.727 |
| all GE Lua, ms | | 5.41 | 32.053 |
| physics + vehicle Lua, ms | | 0.072 | 0.19 |
| render, ms | | 2.286 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 30.744 ms, worst composite 0.087 ms.
- Detector: 1.316 us per contact, 3.98 ms total, worst frame 0.462 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 42.73 | 30.71 | 0.88 | 0.08 | 1.84 |
| 5.25 | 42.02 | 30.72 | 1.08 | 0.05 | 2.32 |
| 0.80 | 41.64 | 30.52 | 0.78 | 0.07 | 1.82 |
| 1.12 | 41.09 | 28.87 | 0.86 | 0.07 | 1.93 |
| 1.84 | 41.07 | 29.25 | 0.85 | 0.04 | 1.74 |
