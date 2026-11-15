# sustained - 20261114-210725_sustained_resumed-grouped-full-b6-vulkan-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2363 frames, 78.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14108 | 7460 | 55 | 529 | 110 | 166 | 153 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5202, BelowThresh 1418, NormalForce 28

Body materials: METAL 7416, PLASTIC 44

Surfaces: ASPHALT 7306, COBBLESTONE 154

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.031 | 25.915 | 38.701 |
| whole frame, ms | 11.585 (p50) | 32.559 | 54.089 |
| all GE Lua, ms | | 26.717 | 39.821 |
| physics + vehicle Lua, ms | | 0.084 | 1.064 |
| render, ms | | 1.761 | |

- Painter frames over 4 ms: 184; worst flush (project + bake) 38.678 ms, worst composite 0.071 ms.
- Detector: 3.482 us per contact, 70.709 ms total, worst frame 0.446 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.28 | 54.09 | 38.70 | 1.08 | 0.08 | 1.30 |
| 14.40 | 46.92 | 35.65 | 1.00 | 0.07 | 1.44 |
| 2.74 | 46.75 | 33.89 | 0.72 | 0.04 | 1.30 |
| 29.58 | 46.68 | 34.66 | 0.70 | 0.06 | 1.30 |
| 10.86 | 46.65 | 35.31 | 0.83 | 0.05 | 1.22 |
