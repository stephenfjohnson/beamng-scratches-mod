# sustained - 20261114-182507_sustained_resumed-v2-half-b3_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true)`

Settled: False after 30.006 s - 2590 frames, 86.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18476 | 10486 | 42 | 655 | 91 | 198 | 199 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6021, BelowThresh 1934, NormalForce 35

Body materials: METAL 10456, PLASTIC 30

Surfaces: ASPHALT 8849, COBBLESTONE 1637

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.9 | 23.511 | 40.093 |
| whole frame, ms | 10.701 (p50) | 30.287 | 47.174 |
| all GE Lua, ms | | 24.349 | 41.034 |
| physics + vehicle Lua, ms | | 0.08 | 0.331 |
| render, ms | | 2.116 | |

- Painter frames over 4 ms: 209; worst flush (project + bake) 40.043 ms, worst composite 0.214 ms.
- Detector: 3.383 us per contact, 82.47 ms total, worst frame 0.543 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.33 | 47.17 | 40.09 | 0.97 | 0.06 | 1.50 |
| 13.82 | 45.96 | 34.76 | 0.79 | 0.04 | 1.35 |
| 1.17 | 44.97 | 34.61 | 0.81 | 0.05 | 1.83 |
| 13.91 | 42.53 | 30.82 | 0.68 | 0.04 | 1.78 |
| 12.97 | 41.89 | 32.14 | 0.91 | 0.05 | 1.76 |
