# sustained - 20261114-200308_sustained_resumed-fixed-full-vulkan-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.003 s - 2322 frames, 76.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14502 | 7840 | 55 | 565 | 114 | 185 | 209 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5623, BelowThresh 1018, NormalForce 21

Body materials: METAL 7823, PLASTIC 17

Surfaces: ASPHALT 6475, COBBLESTONE 1365

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.414 | 29.982 | 39.041 |
| whole frame, ms | 11.666 (p50) | 36.553 | 406.212 |
| all GE Lua, ms | | 30.821 | 39.882 |
| physics + vehicle Lua, ms | | 0.092 | 0.939 |
| render, ms | | 1.837 | |

- Painter frames over 4 ms: 188; worst flush (project + bake) 38.925 ms, worst composite 0.143 ms.
- Detector: 3.357 us per contact, 69.646 ms total, worst frame 0.431 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 10.29 | 406.21 | 0.01 | 0.89 | 0.06 | 1.27 |
| 15.27 | 48.56 | 39.04 | 0.70 | 0.04 | 1.17 |
| 28.38 | 47.75 | 35.06 | 1.03 | 0.07 | 1.20 |
| 13.79 | 47.72 | 34.84 | 0.98 | 0.05 | 1.17 |
| 19.04 | 47.64 | 34.55 | 0.94 | 0.05 | 1.26 |
