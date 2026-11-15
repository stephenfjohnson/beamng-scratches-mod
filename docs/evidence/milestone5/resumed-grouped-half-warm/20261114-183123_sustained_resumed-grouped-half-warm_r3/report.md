# sustained - 20261114-183123_sustained_resumed-grouped-half-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.007 s - 2528 frames, 83.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 19093 | 10102 | 45 | 696 | 83 | 206 | 225 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 7087, BelowThresh 1863, NormalForce 41

Body materials: METAL 10091, PLASTIC 11

Surfaces: ASPHALT 8564, COBBLESTONE 1538

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.333 | 24.88 | 363.468 |
| whole frame, ms | 10.665 (p50) | 31.46 | 373.773 |
| all GE Lua, ms | | 25.845 | 364.769 |
| physics + vehicle Lua, ms | | 0.089 | 0.342 |
| render, ms | | 2.37 | |

- Painter frames over 4 ms: 224; worst flush (project + bake) 363.41 ms, worst composite 0.211 ms.
- Detector: 3.193 us per contact, 82.732 ms total, worst frame 0.388 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.39 | 373.77 | 363.47 | 1.01 | 0.06 | 2.00 |
| 20.70 | 47.26 | 36.08 | 0.91 | 0.07 | 1.84 |
| 1.75 | 44.54 | 37.70 | 1.01 | 0.05 | 1.63 |
| 1.24 | 44.39 | 31.92 | 0.86 | 0.05 | 2.02 |
| 11.75 | 44.18 | 32.48 | 0.98 | 0.08 | 1.77 |
