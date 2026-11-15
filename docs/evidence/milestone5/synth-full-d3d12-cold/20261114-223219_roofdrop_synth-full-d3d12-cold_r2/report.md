# roofdrop - 20261114-223219_roofdrop_synth-full-d3d12-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.365 s - 483 frames, 89.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1355 | 52 | 52 | 0 | 46 | 19 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 708, BelowThresh 595

Body materials: METAL 51, PLASTIC 1

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.616 | 0.78 | 21.655 |
| whole frame, ms | 10.975 (p50) | 15.108 | 32.895 |
| all GE Lua, ms | | 3.481 | 22.799 |
| physics + vehicle Lua, ms | | 0.068 | 0.153 |
| render, ms | | 2.117 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 0.737 ms, worst composite 0.143 ms.
- Detector: 1.413 us per contact, 4.421 ms total, worst frame 0.588 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 32.90 | 21.65 | 1.52 | 0.11 | 2.90 |
| 1.14 | 30.44 | 20.25 | 1.37 | 0.04 | 1.68 |
| 2.22 | 28.96 | 17.55 | 1.24 | 0.05 | 1.83 |
| 1.46 | 27.18 | 16.39 | 1.40 | 0.08 | 1.55 |
| 1.52 | 26.76 | 16.43 | 1.59 | 0.04 | 1.63 |
