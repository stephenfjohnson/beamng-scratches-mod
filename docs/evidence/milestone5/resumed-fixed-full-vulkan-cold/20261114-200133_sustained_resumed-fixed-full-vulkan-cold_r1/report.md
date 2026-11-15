# sustained - 20261114-200133_sustained_resumed-fixed-full-vulkan-cold_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.008 s - 2375 frames, 78.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14589 | 8080 | 54 | 518 | 98 | 144 | 162 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5271, BelowThresh 1226, NormalForce 12

Body materials: METAL 8063, PLASTIC 17

Surfaces: ASPHALT 7950, COBBLESTONE 130

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.872 | 10.37 | 477.589 |
| whole frame, ms | 11.691 (p50) | 24.058 | 483.742 |
| all GE Lua, ms | | 11.385 | 478.79 |
| physics + vehicle Lua, ms | | 0.084 | 1.081 |
| render, ms | | 1.794 | |

- Painter frames over 4 ms: 137; worst flush (project + bake) 477.564 ms, worst composite 0.249 ms.
- Detector: 3.332 us per contact, 68.427 ms total, worst frame 0.47 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 15.23 | 483.74 | 477.59 | 0.81 | 0.06 | 1.23 |
| 6.08 | 53.69 | 38.74 | 0.75 | 0.05 | 1.30 |
| 12.41 | 50.07 | 38.52 | 0.74 | 0.05 | 1.17 |
| 17.89 | 48.96 | 38.24 | 0.70 | 0.05 | 1.22 |
| 3.59 | 47.42 | 35.64 | 0.83 | 0.05 | 1.26 |
