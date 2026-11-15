# sustained - 20261114-221040_sustained_synth-full-vk-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.007 s - 2542 frames, 84.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14520 | 6836 | 70 | 578 | 116 | 229 | 252 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5841, BelowThresh 1825, NormalForce 18

Body materials: METAL 6809, PLASTIC 27

Surfaces: ASPHALT 6371, COBBLESTONE 465

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.274 | 2.096 | 13.702 |
| whole frame, ms | 11.73 (p50) | 15.354 | 26.575 |
| all GE Lua, ms | | 3.049 | 14.549 |
| physics + vehicle Lua, ms | | 0.081 | 0.311 |
| render, ms | | 1.747 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 2.074 ms, worst composite 0.265 ms.
- Detector: 2.952 us per contact, 65.225 ms total, worst frame 0.456 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.41 | 26.58 | 9.52 | 1.20 | 0.05 | 1.65 |
| 12.03 | 24.70 | 8.25 | 1.12 | 0.04 | 1.44 |
| 0.72 | 20.61 | 0.66 | 5.83 | 0.07 | 1.37 |
| 0.46 | 20.26 | 13.70 | 1.52 | 0.04 | 1.54 |
| 24.86 | 19.96 | 3.34 | 1.49 | 0.06 | 1.38 |
