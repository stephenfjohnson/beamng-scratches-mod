# roofdrop - 20261114-222717_roofdrop_synth-full-vk-endurance_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.51 s - 421 frames, 74.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1077 | 50 | 50 | 0 | 53 | 18 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 646, BelowThresh 381

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.176 | 1.221 | 5.856 |
| whole frame, ms | 12.851 (p50) | 15.607 | 248.219 |
| all GE Lua, ms | | 2.164 | 6.688 |
| physics + vehicle Lua, ms | | 0.071 | 0.131 |
| render, ms | | 1.829 | |

- Painter frames over 4 ms: 3; worst flush (project + bake) 1.104 ms, worst composite 0.106 ms.
- Detector: 1.369 us per contact, 3.941 ms total, worst frame 0.363 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.91 | 248.22 | 0.01 | 1.13 | 0.04 | 1.31 |
| 0.60 | 20.94 | 5.86 | 1.33 | 0.04 | 1.42 |
| 1.54 | 20.08 | 3.60 | 1.37 | 0.06 | 1.51 |
| 0.89 | 19.15 | 3.10 | 4.56 | 0.06 | 1.52 |
| 0.61 | 19.13 | 2.41 | 6.69 | 0.05 | 1.51 |
