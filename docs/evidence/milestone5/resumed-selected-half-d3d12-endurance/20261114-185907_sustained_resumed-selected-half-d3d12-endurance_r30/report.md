# sustained - 20261114-185907_sustained_resumed-selected-half-d3d12-endurance_r30

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.01 s - 2547 frames, 84.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15800 | 7745 | 70 | 575 | 119 | 200 | 236 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 7017, BelowThresh 1016, NormalForce 22

Body materials: METAL 7739, PLASTIC 6

Surfaces: ASPHALT 7164, COBBLESTONE 581

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.217 | 24.89 | 35.847 |
| whole frame, ms | 10.659 (p50) | 31.995 | 44.061 |
| all GE Lua, ms | | 25.971 | 36.983 |
| physics + vehicle Lua, ms | | 0.086 | 0.223 |
| render, ms | | 2.358 | |

- Painter frames over 4 ms: 258; worst flush (project + bake) 35.823 ms, worst composite 0.146 ms.
- Detector: 3.086 us per contact, 69.495 ms total, worst frame 0.505 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.69 | 44.06 | 33.33 | 0.84 | 0.06 | 1.79 |
| 11.84 | 43.72 | 35.85 | 1.00 | 0.04 | 1.50 |
| 15.80 | 43.61 | 32.92 | 1.00 | 0.09 | 1.72 |
| 16.65 | 43.08 | 30.72 | 0.84 | 0.06 | 1.94 |
| 12.09 | 42.94 | 31.78 | 0.82 | 0.04 | 2.00 |
