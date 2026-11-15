# roofdrop - 20261114-224025_roofdrop_synth-full-d3d12-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.438 s - 561 frames, 86.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1545 | 53 | 53 | 0 | 56 | 18 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 972, BelowThresh 520

Body materials: METAL 52, PLASTIC 1

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.632 | 0.951 | 21.659 |
| whole frame, ms | 11.358 (p50) | 14.272 | 29.519 |
| all GE Lua, ms | | 1.701 | 22.653 |
| physics + vehicle Lua, ms | | 0.07 | 0.152 |
| render, ms | | 2.184 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 0.929 ms, worst composite 0.093 ms.
- Detector: 1.336 us per contact, 4.832 ms total, worst frame 0.483 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.20 | 29.52 | 17.97 | 1.49 | 0.04 | 2.31 |
| 2.26 | 29.00 | 20.27 | 1.31 | 0.04 | 1.67 |
| 0.61 | 28.87 | 21.66 | 18.21 | 0.06 | 1.74 |
| 0.60 | 28.45 | 17.24 | 1.89 | 0.05 | 2.11 |
| 0.63 | 28.31 | 19.08 | 22.65 | 0.07 | 1.78 |
