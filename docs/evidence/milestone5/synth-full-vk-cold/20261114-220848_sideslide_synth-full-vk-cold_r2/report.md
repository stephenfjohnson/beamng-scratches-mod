# sideslide - 20261114-220848_sideslide_synth-full-vk-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.198 s - 360 frames, 74.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.197)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2852 | 754 | 79 | 121 | 112 | 107 | 128 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1470, BelowThresh 623, NormalForce 5

Body materials: METAL 542, PLASTIC 212

Surfaces: ASPHALT 754

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.309 | 3.971 | 14.966 |
| whole frame, ms | 12.764 (p50) | 21.111 | 27.63 |
| all GE Lua, ms | | 5.171 | 15.853 |
| physics + vehicle Lua, ms | | 0.094 | 0.249 |
| render, ms | | 1.873 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 3.075 ms, worst composite 0.124 ms.
- Detector: 1.917 us per contact, 10.295 ms total, worst frame 0.555 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.20 | 27.63 | 10.80 | 1.38 | 0.07 | 1.64 |
| 0.25 | 25.98 | 13.27 | 4.27 | 0.05 | 1.44 |
| 0.38 | 25.54 | 14.97 | 3.63 | 0.05 | 1.30 |
| 0.04 | 23.42 | 0.00 | 0.96 | 0.09 | 1.42 |
| 2.07 | 23.25 | 3.49 | 6.87 | 0.12 | 1.39 |
