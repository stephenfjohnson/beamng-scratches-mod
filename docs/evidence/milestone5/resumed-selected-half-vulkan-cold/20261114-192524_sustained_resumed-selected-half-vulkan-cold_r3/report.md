# sustained - 20261114-192524_sustained_resumed-selected-half-vulkan-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2437 frames, 81.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15834 | 8922 | 37 | 549 | 76 | 136 | 153 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5436, BelowThresh 1465, NormalForce 11

Body materials: METAL 8871, PLASTIC 51

Surfaces: ASPHALT 8759, COBBLESTONE 163

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.654 | 7.525 | 38.97 |
| whole frame, ms | 11.659 (p50) | 16.765 | 50.123 |
| all GE Lua, ms | | 8.286 | 39.842 |
| physics + vehicle Lua, ms | | 0.077 | 0.309 |
| render, ms | | 1.687 | |

- Painter frames over 4 ms: 135; worst flush (project + bake) 38.952 ms, worst composite 0.104 ms.
- Detector: 3.409 us per contact, 73.512 ms total, worst frame 0.533 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.67 | 50.12 | 38.97 | 1.68 | 0.05 | 1.39 |
| 14.38 | 47.69 | 35.33 | 0.69 | 0.05 | 1.18 |
| 12.34 | 47.61 | 34.31 | 0.86 | 0.07 | 1.25 |
| 0.82 | 47.53 | 35.72 | 0.77 | 0.07 | 1.20 |
| 29.84 | 47.44 | 35.08 | 0.98 | 0.06 | 1.37 |
