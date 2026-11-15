# sustained - 20261114-201643_sustained_resumed-fixed2-full-vulkan-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.005 s - 2306 frames, 76.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16644 | 9109 | 37 | 619 | 90 | 161 | 174 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6013, BelowThresh 1458, NormalForce 64

Body materials: METAL 9092, PLASTIC 17

Surfaces: ASPHALT 7564, COBBLESTONE 1545

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.111 | 26.906 | 37.117 |
| whole frame, ms | 11.91 (p50) | 33.972 | 436.309 |
| all GE Lua, ms | | 27.861 | 38.145 |
| physics + vehicle Lua, ms | | 0.094 | 1.188 |
| render, ms | | 1.893 | |

- Painter frames over 4 ms: 159; worst flush (project + bake) 37.093 ms, worst composite 0.097 ms.
- Detector: 3.558 us per contact, 80.018 ms total, worst frame 0.374 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.53 | 436.31 | 0.01 | 1.15 | 0.06 | 1.19 |
| 0.29 | 49.33 | 34.86 | 1.12 | 0.11 | 1.44 |
| 15.65 | 48.99 | 37.12 | 0.79 | 0.04 | 1.33 |
| 17.15 | 48.12 | 35.15 | 0.83 | 0.05 | 1.27 |
| 13.61 | 47.98 | 36.96 | 0.71 | 0.05 | 1.19 |
