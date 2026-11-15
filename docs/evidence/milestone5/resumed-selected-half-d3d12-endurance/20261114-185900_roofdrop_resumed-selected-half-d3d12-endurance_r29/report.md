# roofdrop - 20261114-185900_roofdrop_resumed-selected-half-d3d12-endurance_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.142 s - 443 frames, 85.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1091 | 54 | 54 | 0 | 54 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 657, BelowThresh 380

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.181 | 7.657 | 30.507 |
| whole frame, ms | 11.105 (p50) | 15.164 | 42.36 |
| all GE Lua, ms | | 8.5 | 31.506 |
| physics + vehicle Lua, ms | | 0.075 | 0.163 |
| render, ms | | 2.37 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 30.479 ms, worst composite 0.077 ms.
- Detector: 1.392 us per contact, 3.805 ms total, worst frame 0.431 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 42.36 | 29.97 | 0.83 | 0.05 | 2.02 |
| 0.53 | 42.24 | 30.14 | 0.95 | 0.05 | 2.03 |
| 2.19 | 41.03 | 29.46 | 1.20 | 0.06 | 2.03 |
| 1.84 | 40.88 | 29.96 | 0.86 | 0.04 | 1.67 |
| 3.63 | 40.56 | 28.53 | 0.79 | 0.04 | 1.87 |
