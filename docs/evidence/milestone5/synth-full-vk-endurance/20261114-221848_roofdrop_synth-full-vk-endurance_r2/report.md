# roofdrop - 20261114-221848_roofdrop_synth-full-vk-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.157 s - 409 frames, 79.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1024 | 50 | 49 | 0 | 51 | 16 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 611, BelowThresh 363

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.218 | 1.176 | 10.449 |
| whole frame, ms | 12.605 (p50) | 16.563 | 22.523 |
| all GE Lua, ms | | 2.835 | 11.466 |
| physics + vehicle Lua, ms | | 0.08 | 0.183 |
| render, ms | | 1.794 | |

- Painter frames over 4 ms: 7; worst flush (project + bake) 1.14 ms, worst composite 0.093 ms.
- Detector: 1.498 us per contact, 3.96 ms total, worst frame 0.364 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 22.52 | 10.45 | 1.86 | 0.12 | 1.45 |
| 0.89 | 21.90 | 4.04 | 4.24 | 0.13 | 1.42 |
| 1.21 | 21.07 | 2.04 | 5.26 | 0.06 | 2.14 |
| 0.61 | 20.63 | 1.20 | 7.26 | 0.06 | 1.64 |
| 1.54 | 20.07 | 3.16 | 1.34 | 0.06 | 1.40 |
