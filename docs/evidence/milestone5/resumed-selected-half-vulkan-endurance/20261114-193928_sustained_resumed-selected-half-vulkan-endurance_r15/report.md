# sustained - 20261114-193928_sustained_resumed-selected-half-vulkan-endurance_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.005 s - 2330 frames, 77.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15721 | 8558 | 74 | 680 | 137 | 196 | 234 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5811, BelowThresh 1307, NormalForce 45

Body materials: METAL 8517, PLASTIC 41

Surfaces: ASPHALT 7417, COBBLESTONE 1141

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.54 | 32.463 | 40.69 |
| whole frame, ms | 11.747 (p50) | 39.239 | 51.454 |
| all GE Lua, ms | | 33.52 | 41.743 |
| physics + vehicle Lua, ms | | 0.084 | 0.683 |
| render, ms | | 1.798 | |

- Painter frames over 4 ms: 189; worst flush (project + bake) 40.671 ms, worst composite 0.445 ms.
- Detector: 3.295 us per contact, 75.018 ms total, worst frame 0.484 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 13.17 | 51.45 | 38.62 | 0.85 | 0.06 | 1.28 |
| 0.87 | 49.10 | 36.17 | 0.71 | 0.07 | 1.61 |
| 29.83 | 49.08 | 36.30 | 0.72 | 0.04 | 1.17 |
| 0.28 | 48.99 | 35.81 | 0.74 | 0.06 | 1.56 |
| 7.83 | 48.47 | 36.82 | 0.96 | 0.07 | 1.43 |
