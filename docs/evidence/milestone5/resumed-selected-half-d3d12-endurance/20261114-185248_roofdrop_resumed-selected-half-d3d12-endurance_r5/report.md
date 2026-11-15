# roofdrop - 20261114-185248_roofdrop_resumed-selected-half-d3d12-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.302 s - 453 frames, 80.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1213 | 51 | 51 | 0 | 49 | 16 | 21 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 688, BelowThresh 474

Body materials: METAL 50, PLASTIC 1

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.146 | 3.434 | 30.906 |
| whole frame, ms | 11.09 (p50) | 13.106 | 399.069 |
| all GE Lua, ms | | 4.228 | 31.974 |
| physics + vehicle Lua, ms | | 0.07 | 0.127 |
| render, ms | | 2.151 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 30.883 ms, worst composite 0.087 ms.
- Detector: 1.266 us per contact, 3.531 ms total, worst frame 0.323 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.94 | 399.07 | 0.00 | 0.79 | 0.05 | 393.15 |
| 0.53 | 42.38 | 30.91 | 0.75 | 0.06 | 1.98 |
| 1.41 | 41.65 | 29.40 | 0.79 | 0.07 | 2.11 |
| 0.80 | 41.36 | 29.94 | 0.88 | 0.06 | 1.89 |
| 2.19 | 40.91 | 29.48 | 0.78 | 0.03 | 1.79 |
