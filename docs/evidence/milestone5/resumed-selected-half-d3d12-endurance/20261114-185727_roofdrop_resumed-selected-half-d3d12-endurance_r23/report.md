# roofdrop - 20261114-185727_roofdrop_resumed-selected-half-d3d12-endurance_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.539 s - 569 frames, 86.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1635 | 51 | 51 | 0 | 58 | 18 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 906, BelowThresh 678

Body materials: METAL 50, PLASTIC 1

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.017 | 4.01 | 32.122 |
| whole frame, ms | 11.11 (p50) | 13.292 | 41.954 |
| all GE Lua, ms | | 4.811 | 33.022 |
| physics + vehicle Lua, ms | | 0.074 | 0.215 |
| render, ms | | 2.243 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 32.087 ms, worst composite 0.098 ms.
- Detector: 1.265 us per contact, 4.704 ms total, worst frame 0.389 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.52 | 41.95 | 30.92 | 0.75 | 0.04 | 1.78 |
| 2.48 | 41.65 | 30.17 | 1.08 | 0.06 | 1.71 |
| 2.21 | 41.44 | 29.22 | 0.73 | 0.04 | 1.96 |
| 1.85 | 40.86 | 29.35 | 0.75 | 0.04 | 1.74 |
| 5.01 | 40.82 | 28.81 | 1.07 | 0.07 | 2.22 |
