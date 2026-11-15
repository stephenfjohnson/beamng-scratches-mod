# sustained - 20261114-211306_sustained_resumed-fixed2-half-d3d12-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.0 s - 2583 frames, 86.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14993 | 8155 | 49 | 499 | 127 | 179 | 194 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5719, BelowThresh 1086, NormalForce 33

Body materials: METAL 8129, PLASTIC 26

Surfaces: ASPHALT 8000, COBBLESTONE 155

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.796 | 21.996 | 35.322 |
| whole frame, ms | 10.644 (p50) | 28.997 | 46.854 |
| all GE Lua, ms | | 22.994 | 36.482 |
| physics + vehicle Lua, ms | | 0.086 | 0.356 |
| render, ms | | 2.375 | |

- Painter frames over 4 ms: 202; worst flush (project + bake) 35.278 ms, worst composite 0.105 ms.
- Detector: 3.611 us per contact, 74.433 ms total, worst frame 0.461 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 22.04 | 46.85 | 35.32 | 0.85 | 0.05 | 1.91 |
| 8.35 | 43.94 | 31.34 | 0.87 | 0.05 | 2.00 |
| 13.10 | 43.70 | 32.80 | 1.07 | 0.05 | 1.61 |
| 2.09 | 43.17 | 33.60 | 0.83 | 0.06 | 1.82 |
| 3.43 | 43.01 | 29.21 | 0.88 | 0.05 | 1.71 |
