# sideslide - 20261114-200429_sideslide_resumed-fixed-full-vulkan-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.809 s - 376 frames, 66.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2865 | 572 | 103 | 130 | 117 | 109 | 138 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1336, BelowThresh 954, NormalForce 3

Body materials: METAL 424, PLASTIC 148

Surfaces: ASPHALT 572

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.853 | 22.157 | 36.673 |
| whole frame, ms | 12.486 (p50) | 31.805 | 45.243 |
| all GE Lua, ms | | 23.279 | 37.511 |
| physics + vehicle Lua, ms | | 0.098 | 0.24 |
| render, ms | | 1.879 | |

- Painter frames over 4 ms: 62; worst flush (project + bake) 36.651 ms, worst composite 0.117 ms.
- Detector: 1.68 us per contact, 9.782 ms total, worst frame 0.598 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 45.24 | 32.21 | 0.86 | 0.06 | 1.96 |
| 3.04 | 42.23 | 36.67 | 0.93 | 0.04 | 1.21 |
| 0.34 | 40.23 | 26.02 | 3.60 | 0.05 | 2.42 |
| 0.69 | 38.24 | 23.48 | 4.48 | 0.06 | 1.17 |
| 1.71 | 38.17 | 31.67 | 1.06 | 0.05 | 1.34 |
