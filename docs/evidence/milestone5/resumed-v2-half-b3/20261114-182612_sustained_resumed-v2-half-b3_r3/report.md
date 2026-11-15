# sustained - 20261114-182612_sustained_resumed-v2-half-b3_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 30.0 s - 2508 frames, 83.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17112 | 9462 | 49 | 656 | 121 | 268 | 263 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5902, BelowThresh 1729, NormalForce 19

Body materials: METAL 9443, PLASTIC 19

Surfaces: ASPHALT 8381, COBBLESTONE 1081

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.682 | 26.947 | 38.867 |
| whole frame, ms | 10.558 (p50) | 33.916 | 50.462 |
| all GE Lua, ms | | 27.888 | 39.846 |
| physics + vehicle Lua, ms | | 0.087 | 0.349 |
| render, ms | | 2.256 | |

- Painter frames over 4 ms: 294; worst flush (project + bake) 38.834 ms, worst composite 0.186 ms.
- Detector: 3.478 us per contact, 79.015 ms total, worst frame 0.428 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 18.15 | 50.46 | 38.87 | 0.96 | 0.05 | 1.78 |
| 0.33 | 44.74 | 38.50 | 0.75 | 0.07 | 1.41 |
| 1.36 | 44.26 | 33.44 | 0.76 | 0.05 | 1.71 |
| 19.15 | 43.25 | 31.24 | 0.90 | 0.05 | 1.94 |
| 15.29 | 42.61 | 31.95 | 0.88 | 0.05 | 1.76 |
