# sustained - 20261114-193359_sustained_resumed-control-v2-disabled-vulkan-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.006 s - 2519 frames, 82.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14918 | 7465 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5655, BelowThresh 1773, NormalForce 25

Body materials: METAL 7446, PLASTIC 19

Surfaces: ASPHALT 6932, COBBLESTONE 533

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.04 |
| whole frame, ms | 12.002 (p50) | 13.671 | 56.527 |
| all GE Lua, ms | | 1.14 | 3.917 |
| physics + vehicle Lua, ms | | 0.082 | 3.634 |
| render, ms | | 1.865 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.535 us per contact, 31.549 ms total, worst frame 0.111 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 24.91 | 56.53 | 0.01 | 3.92 | 0.08 | 1.49 |
| 25.01 | 46.77 | 0.01 | 1.13 | 0.07 | 1.50 |
| 24.93 | 39.12 | 0.01 | 0.95 | 0.05 | 1.48 |
| 24.89 | 36.76 | 0.01 | 2.63 | 0.07 | 1.57 |
| 24.95 | 33.36 | 0.01 | 1.34 | 0.05 | 1.47 |
