# sustained - 20261114-183031_sustained_resumed-grouped-half-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.007 s - 2547 frames, 84.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14860 | 7617 | 54 | 526 | 102 | 174 | 207 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5679, BelowThresh 1541, NormalForce 23

Body materials: METAL 7585, PLASTIC 32

Surfaces: ASPHALT 7329, COBBLESTONE 288

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.9 | 24.092 | 41.569 |
| whole frame, ms | 10.857 (p50) | 30.977 | 53.084 |
| all GE Lua, ms | | 24.914 | 42.646 |
| physics + vehicle Lua, ms | | 0.079 | 0.229 |
| render, ms | | 2.282 | |

- Painter frames over 4 ms: 194; worst flush (project + bake) 41.522 ms, worst composite 0.185 ms.
- Detector: 3.325 us per contact, 67.641 ms total, worst frame 0.36 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.65 | 53.08 | 41.57 | 0.91 | 0.05 | 2.51 |
| 2.67 | 44.59 | 34.10 | 0.86 | 0.05 | 1.75 |
| 1.39 | 44.49 | 33.11 | 0.81 | 0.06 | 1.86 |
| 0.56 | 43.70 | 32.69 | 0.82 | 0.05 | 1.79 |
| 13.90 | 43.57 | 32.06 | 0.79 | 0.04 | 1.95 |
