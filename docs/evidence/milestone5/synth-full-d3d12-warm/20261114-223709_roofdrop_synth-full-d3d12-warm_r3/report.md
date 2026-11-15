# roofdrop - 20261114-223709_roofdrop_synth-full-d3d12-warm_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.098 s - 446 frames, 87.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1193 | 51 | 51 | 0 | 52 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 668, BelowThresh 474

Body materials: METAL 50, PLASTIC 1

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.726 | 6.0 | 24.031 |
| whole frame, ms | 11.23 (p50) | 15.162 | 34.615 |
| all GE Lua, ms | | 6.864 | 24.877 |
| physics + vehicle Lua, ms | | 0.076 | 0.295 |
| render, ms | | 2.189 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 0.949 ms, worst composite 0.084 ms.
- Detector: 1.363 us per contact, 3.889 ms total, worst frame 0.596 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 34.62 | 24.03 | 1.18 | 0.11 | 1.65 |
| 1.14 | 29.16 | 17.88 | 1.79 | 0.05 | 1.95 |
| 2.22 | 28.74 | 17.92 | 1.72 | 0.09 | 1.89 |
| 0.81 | 28.07 | 16.99 | 1.40 | 0.07 | 1.93 |
| 1.52 | 27.72 | 17.73 | 1.66 | 0.07 | 2.04 |
