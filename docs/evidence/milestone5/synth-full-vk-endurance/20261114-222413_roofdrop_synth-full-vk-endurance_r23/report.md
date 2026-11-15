# roofdrop - 20261114-222413_roofdrop_synth-full-vk-endurance_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.986 s - 390 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1060 | 51 | 50 | 0 | 56 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 594, BelowThresh 415

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.245 | 1.428 | 13.748 |
| whole frame, ms | 12.732 (p50) | 15.544 | 26.209 |
| all GE Lua, ms | | 2.406 | 14.873 |
| physics + vehicle Lua, ms | | 0.078 | 0.128 |
| render, ms | | 1.881 | |

- Painter frames over 4 ms: 9; worst flush (project + bake) 1.221 ms, worst composite 0.077 ms.
- Detector: 1.428 us per contact, 3.924 ms total, worst frame 0.4 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 26.21 | 13.75 | 1.49 | 0.10 | 1.48 |
| 0.89 | 23.12 | 3.42 | 4.93 | 0.05 | 1.46 |
| 0.61 | 22.57 | 2.99 | 5.30 | 0.05 | 1.55 |
| 2.27 | 18.29 | 4.11 | 1.16 | 0.03 | 1.40 |
| 1.52 | 18.20 | 4.09 | 1.48 | 0.05 | 1.46 |
