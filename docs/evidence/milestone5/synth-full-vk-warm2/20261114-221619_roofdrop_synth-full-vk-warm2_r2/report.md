# roofdrop - 20261114-221619_roofdrop_synth-full-vk-warm2_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.437 s - 428 frames, 78.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1135 | 60 | 60 | 0 | 60 | 19 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 588, BelowThresh 487

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.209 | 1.622 | 6.701 |
| whole frame, ms | 12.683 (p50) | 15.121 | 18.891 |
| all GE Lua, ms | | 2.639 | 7.771 |
| physics + vehicle Lua, ms | | 0.073 | 0.158 |
| render, ms | | 1.71 | |

- Painter frames over 4 ms: 4; worst flush (project + bake) 0.899 ms, worst composite 0.047 ms.
- Detector: 1.339 us per contact, 4.337 ms total, worst frame 0.59 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 18.89 | 6.70 | 1.80 | 0.08 | 1.42 |
| 0.59 | 18.59 | 6.39 | 1.61 | 0.06 | 1.37 |
| 2.29 | 18.31 | 0.01 | 1.08 | 0.04 | 1.39 |
| 1.20 | 18.28 | 1.04 | 4.22 | 0.05 | 1.38 |
| 0.93 | 18.03 | 0.01 | 0.76 | 0.04 | 1.51 |
