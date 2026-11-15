# sustained - 20261114-201155_sustained_resumed-fixed2-full-vulkan-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.012 s - 2261 frames, 74.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15170 | 8882 | 53 | 590 | 116 | 192 | 207 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5358, BelowThresh 921, NormalForce 9

Body materials: METAL 8846, PLASTIC 36

Surfaces: ASPHALT 8005, COBBLESTONE 877

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.33 | 26.719 | 47.925 |
| whole frame, ms | 11.958 (p50) | 34.065 | 294.857 |
| all GE Lua, ms | | 27.672 | 49.0 |
| physics + vehicle Lua, ms | | 0.096 | 1.786 |
| render, ms | | 1.89 | |

- Painter frames over 4 ms: 187; worst flush (project + bake) 47.887 ms, worst composite 0.11 ms.
- Detector: 3.719 us per contact, 78.726 ms total, worst frame 0.63 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 24.15 | 294.86 | 0.00 | 0.87 | 0.05 | 1.29 |
| 7.95 | 65.94 | 47.93 | 0.82 | 0.06 | 1.52 |
| 0.28 | 49.47 | 36.23 | 0.85 | 0.06 | 1.40 |
| 18.39 | 49.36 | 36.65 | 0.90 | 0.06 | 1.28 |
| 8.24 | 49.30 | 35.71 | 0.86 | 0.05 | 1.42 |
