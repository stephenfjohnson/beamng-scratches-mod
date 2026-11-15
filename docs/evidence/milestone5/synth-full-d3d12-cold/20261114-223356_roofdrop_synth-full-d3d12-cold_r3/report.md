# roofdrop - 20261114-223356_roofdrop_synth-full-d3d12-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.537 s - 489 frames, 88.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1275 | 49 | 49 | 0 | 53 | 17 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 778, BelowThresh 448

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.728 | 1.806 | 24.332 |
| whole frame, ms | 10.976 (p50) | 15.135 | 32.197 |
| all GE Lua, ms | | 3.179 | 25.36 |
| physics + vehicle Lua, ms | | 0.077 | 0.175 |
| render, ms | | 2.298 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.752 ms, worst composite 0.081 ms.
- Detector: 1.647 us per contact, 4.929 ms total, worst frame 0.827 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.90 | 32.20 | 19.95 | 23.28 | 0.06 | 3.03 |
| 0.91 | 31.27 | 24.33 | 21.02 | 0.06 | 1.54 |
| 0.88 | 30.17 | 21.97 | 2.00 | 0.06 | 2.31 |
| 3.66 | 30.05 | 18.31 | 1.60 | 0.06 | 2.81 |
| 0.62 | 29.74 | 22.71 | 22.01 | 0.06 | 1.82 |
