# roofdrop - 20261114-221331_roofdrop_synth-full-vk-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 7.849 s - 612 frames, 77.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1805 | 67 | 67 | 0 | 55 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1029, BelowThresh 709

Body materials: METAL 65, PLASTIC 2

Surfaces: ASPHALT 67

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.164 | 0.51 | 10.261 |
| whole frame, ms | 12.703 (p50) | 17.175 | 27.416 |
| all GE Lua, ms | | 2.57 | 11.344 |
| physics + vehicle Lua, ms | | 0.088 | 0.319 |
| render, ms | | 2.334 | |

- Painter frames over 4 ms: 5; worst flush (project + bake) 0.898 ms, worst composite 0.081 ms.
- Detector: 1.61 us per contact, 6.712 ms total, worst frame 0.542 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 27.42 | 3.06 | 6.88 | 0.09 | 1.60 |
| 0.54 | 21.29 | 10.26 | 2.04 | 0.19 | 1.64 |
| 0.42 | 20.80 | 0.01 | 1.04 | 0.04 | 2.47 |
| 1.20 | 20.66 | 6.26 | 2.21 | 0.07 | 1.47 |
| 0.87 | 20.50 | 3.58 | 1.82 | 0.05 | 1.60 |
