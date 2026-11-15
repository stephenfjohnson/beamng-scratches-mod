# sustained - 20261114-192816_sustained_resumed-selected-half-vulkan-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.013 s - 2319 frames, 77.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15008 | 7122 | 54 | 585 | 105 | 200 | 214 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5933, BelowThresh 1929, NormalForce 24

Body materials: METAL 7106, PLASTIC 16

Surfaces: ASPHALT 6396, COBBLESTONE 726

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.587 | 32.789 | 36.688 |
| whole frame, ms | 11.772 (p50) | 39.576 | 49.149 |
| all GE Lua, ms | | 33.882 | 37.591 |
| physics + vehicle Lua, ms | | 0.085 | 1.688 |
| render, ms | | 1.748 | |

- Painter frames over 4 ms: 191; worst flush (project + bake) 36.66 ms, worst composite 0.247 ms.
- Detector: 3.029 us per contact, 67.162 ms total, worst frame 0.447 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.98 | 49.15 | 35.85 | 0.97 | 0.06 | 1.21 |
| 26.00 | 48.77 | 36.03 | 0.95 | 0.07 | 1.66 |
| 29.73 | 48.72 | 35.66 | 1.07 | 0.06 | 1.32 |
| 25.45 | 48.65 | 34.87 | 0.91 | 0.06 | 1.23 |
| 24.21 | 48.64 | 35.65 | 0.83 | 0.06 | 1.40 |
