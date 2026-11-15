# sustained - 20261114-195612_sustained_resumed-selected-full-fast-vulkan-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.008 s - 2258 frames, 75.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14526 | 7796 | 55 | 598 | 127 | 227 | 260 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5080, BelowThresh 1627, NormalForce 23

Body materials: METAL 7772, PLASTIC 24

Surfaces: ASPHALT 6920, COBBLESTONE 876

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.852 | 28.827 | 36.175 |
| whole frame, ms | 11.721 (p50) | 36.187 | 48.572 |
| all GE Lua, ms | | 29.667 | 37.13 |
| physics + vehicle Lua, ms | | 0.093 | 1.234 |
| render, ms | | 1.822 | |

- Painter frames over 4 ms: 224; worst flush (project + bake) 36.143 ms, worst composite 0.111 ms.
- Detector: 3.36 us per contact, 68.853 ms total, worst frame 0.401 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.99 | 48.57 | 33.63 | 0.90 | 0.05 | 1.29 |
| 21.70 | 48.16 | 34.38 | 0.85 | 0.05 | 1.51 |
| 15.02 | 48.02 | 32.96 | 1.04 | 0.06 | 1.37 |
| 23.19 | 48.01 | 34.17 | 0.90 | 0.06 | 1.28 |
| 25.59 | 47.85 | 34.99 | 0.90 | 0.05 | 1.23 |
