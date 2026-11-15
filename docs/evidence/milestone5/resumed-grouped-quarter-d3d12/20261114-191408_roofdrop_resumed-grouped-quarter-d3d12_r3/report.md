# roofdrop - 20261114-191408_roofdrop_resumed-grouped-quarter-d3d12_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.517 s - 480 frames, 86.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1225 | 50 | 50 | 0 | 52 | 15 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 749, BelowThresh 426

Body materials: METAL 49, PLASTIC 1

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.96 | 1.795 | 32.123 |
| whole frame, ms | 11.188 (p50) | 12.738 | 43.423 |
| all GE Lua, ms | | 2.821 | 33.33 |
| physics + vehicle Lua, ms | | 0.075 | 0.169 |
| render, ms | | 2.048 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 32.089 ms, worst composite 0.087 ms.
- Detector: 1.328 us per contact, 4.301 ms total, worst frame 0.346 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 43.42 | 32.12 | 0.83 | 0.05 | 1.64 |
| 3.64 | 42.11 | 30.98 | 0.81 | 0.04 | 1.54 |
| 2.48 | 41.95 | 30.18 | 0.90 | 0.04 | 1.62 |
| 1.84 | 41.47 | 29.75 | 0.80 | 0.05 | 1.57 |
| 0.81 | 41.41 | 30.47 | 0.71 | 0.05 | 1.73 |
