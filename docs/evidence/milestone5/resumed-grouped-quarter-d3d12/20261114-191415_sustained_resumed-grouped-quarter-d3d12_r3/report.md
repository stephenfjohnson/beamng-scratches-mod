# sustained - 20261114-191415_sustained_resumed-grouped-quarter-d3d12_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2569 frames, 85.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15876 | 7481 | 51 | 574 | 121 | 207 | 234 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6636, BelowThresh 1725, NormalForce 34

Body materials: METAL 7465, PLASTIC 16

Surfaces: ASPHALT 6694, COBBLESTONE 787

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.049 | 25.223 | 36.944 |
| whole frame, ms | 10.65 (p50) | 32.26 | 44.081 |
| all GE Lua, ms | | 26.202 | 37.688 |
| physics + vehicle Lua, ms | | 0.083 | 0.305 |
| render, ms | | 2.247 | |

- Painter frames over 4 ms: 190; worst flush (project + bake) 36.913 ms, worst composite 0.159 ms.
- Detector: 3.112 us per contact, 71.813 ms total, worst frame 0.405 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.86 | 44.08 | 32.18 | 1.13 | 0.05 | 1.68 |
| 24.42 | 43.54 | 28.86 | 0.92 | 0.07 | 1.87 |
| 2.99 | 43.16 | 31.41 | 0.79 | 0.05 | 1.96 |
| 0.44 | 42.95 | 36.94 | 1.01 | 0.06 | 1.37 |
| 0.27 | 42.94 | 33.42 | 0.93 | 0.06 | 2.09 |
