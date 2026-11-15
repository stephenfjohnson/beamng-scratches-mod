# sustained - 20261114-201730_sustained_resumed-fixed2-full-vulkan-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2295 frames, 76.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15852 | 9742 | 34 | 586 | 107 | 190 | 196 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5114, BelowThresh 984, NormalForce 12

Body materials: METAL 9721, PLASTIC 21

Surfaces: ASPHALT 9239, COBBLESTONE 503

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.284 | 27.304 | 36.618 |
| whole frame, ms | 11.947 (p50) | 34.106 | 48.926 |
| all GE Lua, ms | | 28.277 | 37.504 |
| physics + vehicle Lua, ms | | 0.086 | 0.908 |
| render, ms | | 1.674 | |

- Painter frames over 4 ms: 174; worst flush (project + bake) 36.596 ms, worst composite 0.118 ms.
- Detector: 3.601 us per contact, 75.716 ms total, worst frame 0.582 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 15.65 | 48.93 | 36.43 | 0.89 | 0.08 | 1.17 |
| 16.72 | 48.62 | 35.51 | 0.95 | 0.06 | 1.38 |
| 29.69 | 48.58 | 36.47 | 0.82 | 0.05 | 1.24 |
| 16.21 | 48.57 | 36.12 | 0.83 | 0.05 | 1.35 |
| 14.25 | 48.44 | 36.31 | 0.74 | 0.07 | 1.22 |
