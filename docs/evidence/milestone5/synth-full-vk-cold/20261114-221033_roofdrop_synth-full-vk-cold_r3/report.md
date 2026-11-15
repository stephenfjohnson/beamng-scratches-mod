# roofdrop - 20261114-221033_roofdrop_synth-full-vk-cold_r3

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.944 s - 401 frames, 81.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1059 | 47 | 47 | 0 | 52 | 15 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 580, BelowThresh 432

Body materials: METAL 46, PLASTIC 1

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.161 | 1.364 | 5.513 |
| whole frame, ms | 12.317 (p50) | 14.974 | 19.789 |
| all GE Lua, ms | | 2.243 | 6.433 |
| physics + vehicle Lua, ms | | 0.07 | 0.163 |
| render, ms | | 1.737 | |

- Painter frames over 4 ms: 1; worst flush (project + bake) 1.067 ms, worst composite 0.074 ms.
- Detector: 1.416 us per contact, 3.984 ms total, worst frame 0.67 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.87 | 19.79 | 3.08 | 4.41 | 0.05 | 1.38 |
| 0.60 | 19.55 | 5.51 | 1.82 | 0.04 | 1.89 |
| 2.27 | 19.15 | 1.38 | 1.03 | 0.04 | 1.32 |
| 0.66 | 18.63 | 0.01 | 0.73 | 0.04 | 1.50 |
| 1.47 | 17.08 | 2.99 | 1.24 | 0.04 | 1.19 |
