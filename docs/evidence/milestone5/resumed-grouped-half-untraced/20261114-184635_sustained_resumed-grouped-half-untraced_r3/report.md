# sustained - 20261114-184635_sustained_resumed-grouped-half-untraced_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2568 frames, 84.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17646 | 9327 | 54 | 565 | 129 | 207 | 217 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 7271, BelowThresh 1029, NormalForce 19

Body materials: METAL 9298, PLASTIC 29

Surfaces: ASPHALT 8107, COBBLESTONE 1220

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.173 | 23.42 | 402.512 |
| whole frame, ms | 10.609 (p50) | 30.519 | 409.773 |
| all GE Lua, ms | | 24.458 | 403.573 |
| physics + vehicle Lua, ms | | 0.086 | 0.675 |
| render, ms | | 2.304 | |

- Painter frames over 4 ms: 224; worst flush (project + bake) 38.623 ms, worst composite 0.093 ms.
- Detector: 3.126 us per contact, 74.674 ms total, worst frame 0.518 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 13.46 | 409.77 | 402.51 | 26.01 | 0.06 | 1.52 |
| 0.44 | 46.43 | 38.65 | 0.76 | 0.05 | 1.78 |
| 25.62 | 46.17 | 35.32 | 0.90 | 0.05 | 1.75 |
| 1.12 | 44.58 | 32.30 | 0.92 | 0.07 | 1.84 |
| 25.39 | 43.79 | 32.67 | 0.82 | 0.05 | 1.63 |
