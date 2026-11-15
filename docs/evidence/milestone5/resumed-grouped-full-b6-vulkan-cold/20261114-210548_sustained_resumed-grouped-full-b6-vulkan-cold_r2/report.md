# sustained - 20261114-210548_sustained_resumed-grouped-full-b6-vulkan-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.003 s - 2258 frames, 75.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13669 | 6901 | 67 | 584 | 135 | 241 | 214 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5184, BelowThresh 1564, NormalForce 20

Body materials: METAL 6863, PLASTIC 38

Surfaces: ASPHALT 6249, COBBLESTONE 652

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.035 | 31.679 | 37.779 |
| whole frame, ms | 11.674 (p50) | 38.682 | 50.92 |
| all GE Lua, ms | | 32.599 | 38.703 |
| physics + vehicle Lua, ms | | 0.097 | 1.307 |
| render, ms | | 1.645 | |

- Painter frames over 4 ms: 254; worst flush (project + bake) 37.757 ms, worst composite 0.141 ms.
- Detector: 3.327 us per contact, 65.551 ms total, worst frame 0.432 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 6.65 | 50.92 | 37.01 | 1.04 | 0.06 | 1.32 |
| 6.92 | 49.30 | 34.81 | 0.83 | 0.05 | 1.64 |
| 10.52 | 48.71 | 34.69 | 0.68 | 0.04 | 1.64 |
| 7.03 | 48.56 | 37.37 | 0.90 | 0.05 | 1.32 |
| 25.44 | 48.39 | 36.12 | 0.94 | 0.06 | 1.22 |
