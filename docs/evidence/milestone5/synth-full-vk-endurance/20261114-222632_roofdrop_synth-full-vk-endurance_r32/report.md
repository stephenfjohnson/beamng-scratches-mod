# roofdrop - 20261114-222632_roofdrop_synth-full-vk-endurance_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.942 s - 387 frames, 77.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 982 | 51 | 51 | 0 | 52 | 13 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 567, BelowThresh 364

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.201 | 1.321 | 7.493 |
| whole frame, ms | 12.745 (p50) | 16.204 | 22.116 |
| all GE Lua, ms | | 2.322 | 8.444 |
| physics + vehicle Lua, ms | | 0.077 | 0.201 |
| render, ms | | 1.87 | |

- Painter frames over 4 ms: 5; worst flush (project + bake) 0.753 ms, worst composite 0.057 ms.
- Detector: 1.353 us per contact, 3.629 ms total, worst frame 0.35 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 22.12 | 1.79 | 4.95 | 0.06 | 1.93 |
| 1.21 | 20.63 | 2.92 | 4.52 | 0.06 | 2.19 |
| 0.54 | 20.14 | 7.49 | 1.65 | 0.09 | 1.30 |
| 0.95 | 19.31 | 0.01 | 0.91 | 0.04 | 1.54 |
| 0.88 | 18.90 | 3.19 | 1.55 | 0.05 | 1.44 |
