# sustained - 20261114-222811_sustained_synth-full-vk-endurance_r39

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.006 s - 2451 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15078 | 7339 | 68 | 594 | 121 | 201 | 224 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6110, BelowThresh 1610, NormalForce 19

Body materials: METAL 7316, PLASTIC 23

Surfaces: ASPHALT 6081, COBBLESTONE 1258

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.287 | 2.261 | 13.277 |
| whole frame, ms | 12.13 (p50) | 15.449 | 24.36 |
| all GE Lua, ms | | 3.246 | 14.193 |
| physics + vehicle Lua, ms | | 0.087 | 0.289 |
| render, ms | | 2.061 | |

- Painter frames over 4 ms: 28; worst flush (project + bake) 1.977 ms, worst composite 0.356 ms.
- Detector: 3.116 us per contact, 72.182 ms total, worst frame 0.426 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.79 | 24.36 | 2.38 | 1.29 | 0.05 | 2.59 |
| 11.88 | 22.60 | 9.72 | 1.12 | 0.05 | 1.50 |
| 0.35 | 21.87 | 9.20 | 1.95 | 0.05 | 1.67 |
| 12.46 | 21.34 | 8.28 | 2.12 | 0.05 | 1.44 |
| 0.68 | 21.26 | 3.26 | 1.73 | 0.06 | 1.51 |
