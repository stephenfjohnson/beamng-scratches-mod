# roofdrop - 20261114-185336_roofdrop_resumed-selected-half-d3d12-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.349 s - 552 frames, 86.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1517 | 56 | 56 | 0 | 51 | 15 | 21 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 894, BelowThresh 567

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.9 | 1.902 | 30.839 |
| whole frame, ms | 11.16 (p50) | 13.307 | 41.856 |
| all GE Lua, ms | | 2.815 | 32.071 |
| physics + vehicle Lua, ms | | 0.071 | 0.165 |
| render, ms | | 2.298 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 30.804 ms, worst composite 0.087 ms.
- Detector: 1.271 us per contact, 4.325 ms total, worst frame 0.336 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.10 | 41.86 | 30.58 | 0.83 | 0.04 | 1.84 |
| 1.47 | 41.83 | 30.84 | 0.77 | 0.05 | 1.48 |
| 0.52 | 41.50 | 30.17 | 0.88 | 0.05 | 2.11 |
| 1.13 | 40.85 | 29.42 | 0.81 | 0.04 | 1.90 |
| 1.40 | 40.70 | 28.15 | 0.84 | 0.05 | 2.16 |
