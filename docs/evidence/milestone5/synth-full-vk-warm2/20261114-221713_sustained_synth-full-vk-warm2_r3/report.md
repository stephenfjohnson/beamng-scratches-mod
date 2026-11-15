# sustained - 20261114-221713_sustained_synth-full-vk-warm2_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.002 s - 2502 frames, 83.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15652 | 8003 | 77 | 594 | 159 | 237 | 258 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5638, BelowThresh 1970, NormalForce 41

Body materials: METAL 7972, PLASTIC 31

Surfaces: ASPHALT 7584, COBBLESTONE 419

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.304 | 2.225 | 10.649 |
| whole frame, ms | 11.945 (p50) | 15.43 | 28.975 |
| all GE Lua, ms | | 3.179 | 11.538 |
| physics + vehicle Lua, ms | | 0.084 | 0.464 |
| render, ms | | 1.762 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 1.975 ms, worst composite 0.099 ms.
- Detector: 3.058 us per contact, 70.616 ms total, worst frame 0.361 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.41 | 28.98 | 8.59 | 1.49 | 0.06 | 1.79 |
| 22.38 | 24.53 | 8.59 | 1.11 | 0.04 | 1.41 |
| 0.48 | 23.57 | 6.70 | 11.54 | 0.06 | 2.01 |
| 29.19 | 23.02 | 6.43 | 1.24 | 0.07 | 1.43 |
| 29.71 | 22.36 | 4.47 | 1.39 | 0.05 | 1.44 |
