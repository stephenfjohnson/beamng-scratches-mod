# sustained - 20261114-192348_sustained_resumed-selected-half-vulkan-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2363 frames, 78.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15953 | 8199 | 47 | 604 | 90 | 178 | 205 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6050, BelowThresh 1680, NormalForce 24

Body materials: METAL 8184, PLASTIC 15

Surfaces: ASPHALT 6808, COBBLESTONE 1391

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.245 | 31.391 | 36.8 |
| whole frame, ms | 11.736 (p50) | 37.746 | 49.553 |
| all GE Lua, ms | | 32.299 | 37.703 |
| physics + vehicle Lua, ms | | 0.086 | 0.632 |
| render, ms | | 1.796 | |

- Painter frames over 4 ms: 169; worst flush (project + bake) 36.778 ms, worst composite 0.088 ms.
- Detector: 3.235 us per contact, 73.611 ms total, worst frame 0.415 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.56 | 49.55 | 36.58 | 0.87 | 0.05 | 1.42 |
| 13.09 | 48.78 | 36.24 | 0.96 | 0.06 | 1.16 |
| 14.07 | 48.49 | 36.20 | 0.74 | 0.05 | 1.21 |
| 1.26 | 48.22 | 36.80 | 1.39 | 0.06 | 1.18 |
| 23.32 | 48.09 | 34.74 | 1.16 | 0.06 | 1.49 |
