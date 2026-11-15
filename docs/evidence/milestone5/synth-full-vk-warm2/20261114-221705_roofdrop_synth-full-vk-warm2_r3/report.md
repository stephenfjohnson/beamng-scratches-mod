# roofdrop - 20261114-221705_roofdrop_synth-full-vk-warm2_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.169 s - 413 frames, 79.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1101 | 50 | 50 | 0 | 50 | 14 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 621, BelowThresh 430

Body materials: METAL 49, PLASTIC 1

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.156 | 0.878 | 4.119 |
| whole frame, ms | 12.546 (p50) | 14.851 | 22.891 |
| all GE Lua, ms | | 1.769 | 5.104 |
| physics + vehicle Lua, ms | | 0.073 | 0.127 |
| render, ms | | 1.539 | |

- Painter frames over 4 ms: 2; worst flush (project + bake) 1.283 ms, worst composite 0.048 ms.
- Detector: 1.325 us per contact, 3.707 ms total, worst frame 0.335 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 22.89 | 2.76 | 5.10 | 0.08 | 1.39 |
| 0.93 | 19.21 | 0.01 | 0.88 | 0.08 | 1.43 |
| 1.20 | 18.69 | 2.65 | 4.43 | 0.05 | 1.48 |
| 1.25 | 18.53 | 0.01 | 0.91 | 0.04 | 1.32 |
| 1.49 | 18.27 | 2.83 | 1.61 | 0.07 | 1.31 |
