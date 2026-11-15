# roofdrop - 20261114-222151_roofdrop_synth-full-vk-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.497 s - 505 frames, 77.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1402 | 57 | 57 | 0 | 62 | 16 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 795, BelowThresh 550

Body materials: METAL 55, PLASTIC 2

Surfaces: ASPHALT 57

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.15 | 0.941 | 4.714 |
| whole frame, ms | 12.86 (p50) | 15.074 | 19.397 |
| all GE Lua, ms | | 1.908 | 5.518 |
| physics + vehicle Lua, ms | | 0.068 | 0.167 |
| render, ms | | 1.437 | |

- Painter frames over 4 ms: 2; worst flush (project + bake) 0.936 ms, worst composite 0.062 ms.
- Detector: 1.344 us per contact, 4.97 ms total, worst frame 0.728 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.27 | 19.40 | 2.98 | 1.57 | 0.05 | 1.50 |
| 0.94 | 18.51 | 0.01 | 0.78 | 0.05 | 1.32 |
| 2.33 | 18.31 | 0.01 | 0.74 | 0.04 | 1.28 |
| 0.61 | 18.15 | 2.97 | 3.52 | 0.06 | 1.29 |
| 0.87 | 17.99 | 3.98 | 1.75 | 0.06 | 1.59 |
