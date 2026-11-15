# roofdrop - 20261114-222324_roofdrop_synth-full-vk-endurance_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.51 s - 504 frames, 77.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1430 | 59 | 59 | 0 | 62 | 17 | 28 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 829, BelowThresh 542

Body materials: METAL 57, PLASTIC 2

Surfaces: ASPHALT 59

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.21 | 1.195 | 13.185 |
| whole frame, ms | 12.832 (p50) | 16.593 | 28.296 |
| all GE Lua, ms | | 2.911 | 14.112 |
| physics + vehicle Lua, ms | | 0.085 | 0.213 |
| render, ms | | 2.161 | |

- Painter frames over 4 ms: 7; worst flush (project + bake) 0.909 ms, worst composite 0.067 ms.
- Detector: 1.485 us per contact, 5.155 ms total, worst frame 0.395 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.62 | 28.30 | 3.25 | 5.24 | 0.07 | 1.58 |
| 0.55 | 25.92 | 13.18 | 1.94 | 0.10 | 1.57 |
| 0.89 | 22.81 | 3.04 | 6.35 | 0.06 | 1.49 |
| 1.59 | 22.71 | 0.01 | 0.84 | 0.06 | 1.79 |
| 0.96 | 22.28 | 0.01 | 0.87 | 0.04 | 2.16 |
