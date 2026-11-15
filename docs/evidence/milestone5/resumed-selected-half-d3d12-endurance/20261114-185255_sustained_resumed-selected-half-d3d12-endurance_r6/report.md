# sustained - 20261114-185255_sustained_resumed-selected-half-d3d12-endurance_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.001 s - 2537 frames, 84.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15094 | 7545 | 68 | 604 | 132 | 222 | 253 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6020, BelowThresh 1485, NormalForce 44

Body materials: METAL 7534, PLASTIC 11

Surfaces: ASPHALT 6694, COBBLESTONE 851

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.365 | 26.154 | 38.939 |
| whole frame, ms | 10.593 (p50) | 33.708 | 45.928 |
| all GE Lua, ms | | 27.306 | 39.985 |
| physics + vehicle Lua, ms | | 0.089 | 0.341 |
| render, ms | | 2.435 | |

- Painter frames over 4 ms: 271; worst flush (project + bake) 38.916 ms, worst composite 0.106 ms.
- Detector: 3.073 us per contact, 68.166 ms total, worst frame 0.467 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 20.74 | 45.93 | 35.77 | 0.75 | 0.05 | 1.83 |
| 0.45 | 45.59 | 38.94 | 0.88 | 0.05 | 1.44 |
| 19.28 | 42.24 | 30.34 | 0.87 | 0.04 | 1.73 |
| 29.97 | 41.79 | 26.15 | 1.28 | 0.08 | 3.21 |
| 21.61 | 41.69 | 30.23 | 0.72 | 0.05 | 1.76 |
