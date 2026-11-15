# sustained - 20261114-221626_sustained_synth-full-vk-warm2_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.001 s - 2461 frames, 81.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15139 | 7220 | 83 | 617 | 135 | 216 | 231 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5681, BelowThresh 2207, NormalForce 31

Body materials: METAL 7187, PLASTIC 33

Surfaces: ASPHALT 6706, COBBLESTONE 514

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.28 | 2.106 | 14.767 |
| whole frame, ms | 12.093 (p50) | 15.389 | 413.97 |
| all GE Lua, ms | | 3.146 | 15.603 |
| physics + vehicle Lua, ms | | 0.08 | 0.258 |
| render, ms | | 1.872 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 1.756 ms, worst composite 0.115 ms.
- Detector: 3.022 us per contact, 69.659 ms total, worst frame 0.435 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 22.74 | 413.97 | 0.01 | 0.94 | 0.07 | 1.67 |
| 0.41 | 32.25 | 14.77 | 1.42 | 0.04 | 1.42 |
| 0.69 | 24.44 | 8.55 | 4.78 | 0.07 | 1.56 |
| 25.03 | 22.52 | 0.01 | 5.12 | 0.06 | 2.58 |
| 13.01 | 22.26 | 0.01 | 1.23 | 0.09 | 2.90 |
