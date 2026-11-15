# roofdrop - 20261114-224333_roofdrop_synth-full-d3d12-endurance_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.344 s - 556 frames, 87.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1586 | 57 | 56 | 0 | 53 | 19 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 934, BelowThresh 595

Body materials: METAL 55, PLASTIC 2

Surfaces: ASPHALT 57

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.586 | 0.469 | 20.85 |
| whole frame, ms | 11.296 (p50) | 13.593 | 29.475 |
| all GE Lua, ms | | 1.517 | 21.712 |
| physics + vehicle Lua, ms | | 0.07 | 0.272 |
| render, ms | | 2.046 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.016 ms, worst composite 0.095 ms.
- Detector: 1.302 us per contact, 4.67 ms total, worst frame 0.407 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.27 | 29.47 | 18.32 | 1.13 | 0.04 | 1.71 |
| 1.52 | 28.23 | 17.12 | 1.31 | 0.04 | 1.66 |
| 0.89 | 28.12 | 20.42 | 19.47 | 0.05 | 2.19 |
| 1.21 | 27.94 | 20.85 | 17.21 | 0.05 | 1.69 |
| 5.19 | 27.91 | 17.24 | 1.24 | 0.04 | 1.52 |
