# sustained - 20261114-220903_sustained_synth-full-vk-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.012 s - 2497 frames, 82.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15725 | 7631 | 77 | 600 | 133 | 205 | 221 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6071, BelowThresh 1991, NormalForce 32

Body materials: METAL 7607, PLASTIC 24

Surfaces: ASPHALT 6948, COBBLESTONE 683

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.265 | 2.131 | 12.853 |
| whole frame, ms | 11.893 (p50) | 15.6 | 417.662 |
| all GE Lua, ms | | 3.187 | 13.926 |
| physics + vehicle Lua, ms | | 0.085 | 0.232 |
| render, ms | | 1.998 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.901 ms, worst composite 0.116 ms.
- Detector: 3.318 us per contact, 75.457 ms total, worst frame 0.524 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 15.62 | 417.66 | 0.01 | 0.94 | 0.05 | 1.51 |
| 0.42 | 25.57 | 12.85 | 1.41 | 0.05 | 1.46 |
| 12.04 | 24.60 | 9.65 | 1.30 | 0.06 | 1.57 |
| 11.83 | 24.54 | 6.68 | 1.59 | 0.07 | 1.74 |
| 1.58 | 23.51 | 3.34 | 1.66 | 0.06 | 1.97 |
