# sideslide - 20261114-221613_sideslide_synth-full-vk-warm2_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.145 s - 308 frames, 74.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.152)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2981 | 687 | 88 | 129 | 123 | 110 | 138 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1617, BelowThresh 672, NormalForce 5

Body materials: METAL 524, PLASTIC 163

Surfaces: ASPHALT 687

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.621 | 4.491 | 14.106 |
| whole frame, ms | 12.551 (p50) | 19.8 | 30.081 |
| all GE Lua, ms | | 5.675 | 15.171 |
| physics + vehicle Lua, ms | | 0.093 | 0.15 |
| render, ms | | 1.877 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 2.507 ms, worst composite 0.105 ms.
- Detector: 1.389 us per contact, 8.87 ms total, worst frame 0.67 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.88 | 30.08 | 12.15 | 5.57 | 0.13 | 2.78 |
| 0.20 | 24.79 | 14.11 | 1.89 | 0.07 | 1.54 |
| 0.27 | 23.83 | 3.28 | 9.13 | 0.07 | 1.70 |
| 1.21 | 23.09 | 3.04 | 7.79 | 0.06 | 1.50 |
| 0.34 | 23.07 | 11.01 | 3.28 | 0.06 | 1.62 |
