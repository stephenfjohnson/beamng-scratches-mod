# sustained - 20261114-201331_sustained_resumed-fixed2-full-vulkan-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.013 s - 2285 frames, 74.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14016 | 7398 | 56 | 499 | 96 | 151 | 171 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5187, BelowThresh 1419, NormalForce 12

Body materials: METAL 7343, PLASTIC 55

Surfaces: ASPHALT 7230, COBBLESTONE 168

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.761 | 17.261 | 46.315 |
| whole frame, ms | 11.873 (p50) | 27.707 | 628.883 |
| all GE Lua, ms | | 18.478 | 47.761 |
| physics + vehicle Lua, ms | | 0.123 | 14.956 |
| render, ms | | 2.518 | |

- Painter frames over 4 ms: 155; worst flush (project + bake) 46.274 ms, worst composite 0.14 ms.
- Detector: 4.613 us per contact, 88.834 ms total, worst frame 1.15 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 17.68 | 628.88 | 0.01 | 1.40 | 0.11 | 1.89 |
| 17.06 | 57.88 | 46.31 | 1.14 | 0.08 | 2.03 |
| 29.58 | 57.18 | 41.53 | 1.34 | 0.09 | 2.33 |
| 24.90 | 52.18 | 40.27 | 1.40 | 0.10 | 2.16 |
| 9.29 | 51.10 | 36.74 | 0.93 | 0.06 | 1.33 |
