# sustained - 20261114-192731_sustained_resumed-selected-half-vulkan-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.007 s - 2380 frames, 79.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15974 | 9126 | 34 | 601 | 81 | 150 | 165 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5375, BelowThresh 1424, NormalForce 49

Body materials: METAL 9101, PLASTIC 25

Surfaces: ASPHALT 8079, COBBLESTONE 1047

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.881 | 27.954 | 41.72 |
| whole frame, ms | 11.77 (p50) | 34.878 | 49.054 |
| all GE Lua, ms | | 28.929 | 42.686 |
| physics + vehicle Lua, ms | | 0.08 | 0.398 |
| render, ms | | 1.688 | |

- Painter frames over 4 ms: 142; worst flush (project + bake) 41.693 ms, worst composite 0.107 ms.
- Detector: 3.325 us per contact, 73.869 ms total, worst frame 1.167 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.46 | 49.05 | 41.72 | 1.09 | 0.06 | 1.62 |
| 7.41 | 48.19 | 35.56 | 0.89 | 0.07 | 1.19 |
| 14.77 | 48.07 | 34.65 | 0.76 | 0.04 | 1.16 |
| 13.20 | 48.06 | 34.88 | 0.74 | 0.05 | 1.24 |
| 16.90 | 48.06 | 36.02 | 1.04 | 0.05 | 1.44 |
