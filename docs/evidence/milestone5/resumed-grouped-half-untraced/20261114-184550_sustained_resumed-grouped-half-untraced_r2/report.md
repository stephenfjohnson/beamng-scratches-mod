# sustained - 20261114-184550_sustained_resumed-grouped-half-untraced_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2613 frames, 87.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16769 | 8484 | 48 | 543 | 95 | 151 | 184 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6727, BelowThresh 1540, NormalForce 18

Body materials: METAL 8462, PLASTIC 22

Surfaces: ASPHALT 8330, COBBLESTONE 154

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.557 | 12.09 | 37.07 |
| whole frame, ms | 10.732 (p50) | 19.122 | 48.503 |
| all GE Lua, ms | | 14.238 | 38.202 |
| physics + vehicle Lua, ms | | 0.081 | 0.288 |
| render, ms | | 2.306 | |

- Painter frames over 4 ms: 183; worst flush (project + bake) 37.043 ms, worst composite 0.122 ms.
- Detector: 3.118 us per contact, 71.448 ms total, worst frame 0.393 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.96 | 48.50 | 37.07 | 1.00 | 0.06 | 1.87 |
| 17.90 | 45.87 | 34.66 | 0.73 | 0.07 | 1.75 |
| 24.86 | 44.15 | 32.05 | 0.76 | 0.05 | 1.93 |
| 30.02 | 43.88 | 31.92 | 0.92 | 0.06 | 1.80 |
| 29.31 | 42.99 | 32.38 | 0.81 | 0.05 | 1.72 |
