# roofdrop - 20261114-224551_roofdrop_synth-full-d3d12-endurance_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.971 s - 434 frames, 87.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1073 | 49 | 49 | 0 | 52 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 624, BelowThresh 400

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.775 | 5.67 | 21.245 |
| whole frame, ms | 11.232 (p50) | 15.213 | 30.23 |
| all GE Lua, ms | | 6.445 | 22.296 |
| physics + vehicle Lua, ms | | 0.075 | 0.176 |
| render, ms | | 2.003 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.387 ms, worst composite 0.088 ms.
- Detector: 1.362 us per contact, 3.593 ms total, worst frame 0.44 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.52 | 30.23 | 18.94 | 1.27 | 0.03 | 1.71 |
| 1.85 | 29.58 | 18.33 | 1.36 | 0.04 | 1.87 |
| 0.81 | 29.26 | 17.83 | 1.20 | 0.04 | 1.75 |
| 0.88 | 28.79 | 20.53 | 22.30 | 0.07 | 1.98 |
| 0.87 | 28.11 | 21.24 | 2.31 | 0.09 | 1.74 |
