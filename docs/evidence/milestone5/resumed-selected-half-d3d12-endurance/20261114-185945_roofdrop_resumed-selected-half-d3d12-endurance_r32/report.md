# roofdrop - 20261114-185945_roofdrop_resumed-selected-half-d3d12-endurance_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 7.861 s - 677 frames, 86.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2010 | 60 | 60 | 0 | 61 | 19 | 29 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1214, BelowThresh 736

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.94 | 1.79 | 30.73 |
| whole frame, ms | 11.235 (p50) | 13.02 | 42.489 |
| all GE Lua, ms | | 3.067 | 31.703 |
| physics + vehicle Lua, ms | | 0.07 | 0.18 |
| render, ms | | 2.244 | |

- Painter frames over 4 ms: 28; worst flush (project + bake) 30.705 ms, worst composite 0.173 ms.
- Detector: 1.212 us per contact, 5.394 ms total, worst frame 0.375 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 6.61 | 42.49 | 30.73 | 0.86 | 0.07 | 1.77 |
| 4.99 | 42.41 | 30.51 | 0.71 | 0.06 | 1.73 |
| 1.13 | 41.78 | 30.42 | 0.81 | 0.08 | 2.02 |
| 0.80 | 41.08 | 30.02 | 0.89 | 0.07 | 1.86 |
| 3.60 | 41.06 | 30.05 | 0.86 | 0.14 | 1.84 |
