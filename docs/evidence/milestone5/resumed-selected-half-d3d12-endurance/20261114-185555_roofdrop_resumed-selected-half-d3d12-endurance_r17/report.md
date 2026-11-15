# roofdrop - 20261114-185555_roofdrop_resumed-selected-half-d3d12-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.332 s - 460 frames, 86.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1170 | 52 | 52 | 0 | 62 | 20 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 696, BelowThresh 422

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.37 | 5.695 | 31.499 |
| whole frame, ms | 11.027 (p50) | 14.129 | 42.533 |
| all GE Lua, ms | | 6.471 | 32.331 |
| physics + vehicle Lua, ms | | 0.075 | 0.279 |
| render, ms | | 2.256 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 31.473 ms, worst composite 0.063 ms.
- Detector: 1.312 us per contact, 3.665 ms total, worst frame 0.337 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 42.53 | 30.19 | 0.70 | 0.06 | 1.88 |
| 5.08 | 42.52 | 30.54 | 0.92 | 0.06 | 1.73 |
| 3.62 | 42.25 | 30.37 | 0.71 | 0.04 | 1.94 |
| 3.84 | 41.44 | 28.90 | 0.97 | 0.08 | 1.86 |
| 0.81 | 41.43 | 29.99 | 0.86 | 0.06 | 1.79 |
