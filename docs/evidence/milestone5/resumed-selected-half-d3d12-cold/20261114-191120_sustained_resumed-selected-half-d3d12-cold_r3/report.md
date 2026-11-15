# sustained - 20261114-191120_sustained_resumed-selected-half-d3d12-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.01 s - 2549 frames, 84.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16203 | 8387 | 74 | 589 | 126 | 203 | 237 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6377, BelowThresh 1426, NormalForce 13

Body materials: METAL 8385, PLASTIC 2

Surfaces: ASPHALT 7488, COBBLESTONE 899

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.148 | 23.149 | 43.254 |
| whole frame, ms | 10.61 (p50) | 30.255 | 50.432 |
| all GE Lua, ms | | 24.297 | 44.412 |
| physics + vehicle Lua, ms | | 0.087 | 0.665 |
| render, ms | | 2.313 | |

- Painter frames over 4 ms: 277; worst flush (project + bake) 43.222 ms, worst composite 0.175 ms.
- Detector: 3.29 us per contact, 75.081 ms total, worst frame 0.509 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.44 | 50.43 | 43.25 | 1.01 | 0.05 | 1.40 |
| 1.59 | 45.35 | 34.70 | 0.80 | 0.05 | 1.95 |
| 16.60 | 43.85 | 32.65 | 0.87 | 0.08 | 1.78 |
| 18.70 | 42.89 | 30.61 | 0.81 | 0.05 | 1.77 |
| 4.27 | 42.80 | 31.91 | 0.76 | 0.04 | 1.72 |
