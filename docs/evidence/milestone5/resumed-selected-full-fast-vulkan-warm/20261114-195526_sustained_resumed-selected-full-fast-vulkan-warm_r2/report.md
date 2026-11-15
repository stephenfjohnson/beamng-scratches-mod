# sustained - 20261114-195526_sustained_resumed-selected-full-fast-vulkan-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2328 frames, 76.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13693 | 7285 | 66 | 531 | 122 | 166 | 199 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5097, BelowThresh 1292, NormalForce 19

Body materials: METAL 7250, PLASTIC 35

Surfaces: ASPHALT 7168, COBBLESTONE 117

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.34 | 26.577 | 519.798 |
| whole frame, ms | 11.78 (p50) | 33.265 | 525.902 |
| all GE Lua, ms | | 27.592 | 520.642 |
| physics + vehicle Lua, ms | | 0.087 | 0.593 |
| render, ms | | 1.807 | |

- Painter frames over 4 ms: 166; worst flush (project + bake) 519.771 ms, worst composite 0.103 ms.
- Detector: 3.378 us per contact, 66.187 ms total, worst frame 0.455 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 22.87 | 525.90 | 519.80 | 0.75 | 0.05 | 1.40 |
| 4.06 | 50.01 | 35.23 | 0.85 | 0.05 | 1.32 |
| 3.79 | 49.14 | 36.16 | 0.77 | 0.05 | 1.22 |
| 0.27 | 48.95 | 35.57 | 0.71 | 0.04 | 1.57 |
| 1.54 | 48.88 | 30.69 | 0.82 | 0.07 | 1.34 |
