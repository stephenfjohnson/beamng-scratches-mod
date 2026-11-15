# roofdrop - 20261114-211115_roofdrop_resumed-fixed2-full-d3d12-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.187 s - 526 frames, 83.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1461 | 52 | 52 | 0 | 58 | 18 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 866, BelowThresh 543

Body materials: METAL 51, PLASTIC 1

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.507 | 16.183 | 34.743 |
| whole frame, ms | 11.199 (p50) | 23.612 | 45.448 |
| all GE Lua, ms | | 17.199 | 35.678 |
| physics + vehicle Lua, ms | | 0.077 | 0.222 |
| render, ms | | 2.3 | |

- Painter frames over 4 ms: 43; worst flush (project + bake) 34.711 ms, worst composite 0.094 ms.
- Detector: 1.346 us per contact, 4.59 ms total, worst frame 0.538 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.61 | 45.45 | 34.74 | 0.71 | 0.07 | 1.54 |
| 2.21 | 42.22 | 30.22 | 0.96 | 0.04 | 1.64 |
| 0.52 | 42.17 | 30.40 | 0.91 | 0.09 | 1.71 |
| 5.11 | 41.77 | 29.13 | 0.78 | 0.04 | 1.60 |
| 1.85 | 40.78 | 29.99 | 0.76 | 0.07 | 1.57 |
