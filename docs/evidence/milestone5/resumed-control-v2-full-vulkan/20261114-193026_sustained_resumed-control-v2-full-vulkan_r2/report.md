# sustained - 20261114-193026_sustained_resumed-control-v2-full-vulkan_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.006 s - 2352 frames, 78.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15456 | 8554 | 46 | 539 | 106 | 149 | 107 | 0.0% | 0 | 2 |

Rejected contacts: PartExcluded 5332, BelowThresh 1562, NormalForce 8

Body materials: METAL 8489, PLASTIC 65

Surfaces: ASPHALT 8224, COBBLESTONE 330

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.491 | 4.84 | 54.856 |
| whole frame, ms | 12.092 (p50) | 16.68 | 67.134 |
| all GE Lua, ms | | 5.736 | 55.898 |
| physics + vehicle Lua, ms | | 0.075 | 0.573 |
| render, ms | | 1.645 | |

- Painter frames over 4 ms: 127; worst flush (project + bake) 54.835 ms, worst composite 0.113 ms.
- Detector: 3.332 us per contact, 69.518 ms total, worst frame 0.442 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.49 | 67.13 | 54.86 | 0.84 | 0.05 | 1.40 |
| 0.70 | 55.36 | 43.23 | 0.88 | 0.05 | 1.74 |
| 12.53 | 54.42 | 43.85 | 0.74 | 0.05 | 1.34 |
| 11.91 | 54.26 | 41.84 | 0.84 | 0.04 | 1.34 |
| 12.73 | 53.24 | 40.28 | 0.97 | 0.04 | 1.35 |
