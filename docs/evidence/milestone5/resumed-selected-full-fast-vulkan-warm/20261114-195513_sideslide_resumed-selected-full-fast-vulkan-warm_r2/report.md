# sideslide - 20261114-195513_sideslide_resumed-selected-full-fast-vulkan-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.135 s - 254 frames, 62.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.148)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2573 | 540 | 78 | 114 | 125 | 86 | 137 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1437, BelowThresh 594, NormalForce 2

Body materials: METAL 403, PLASTIC 137

Surfaces: ASPHALT 540

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.751 | 18.93 | 41.513 |
| whole frame, ms | 14.593 (p50) | 31.902 | 52.999 |
| all GE Lua, ms | | 19.796 | 42.593 |
| physics + vehicle Lua, ms | | 0.093 | 0.2 |
| render, ms | | 1.743 | |

- Painter frames over 4 ms: 41; worst flush (project + bake) 41.49 ms, worst composite 0.329 ms.
- Detector: 1.439 us per contact, 7.326 ms total, worst frame 0.389 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 53.00 | 41.51 | 0.96 | 0.08 | 1.53 |
| 0.31 | 39.62 | 26.14 | 2.40 | 0.05 | 1.63 |
| 1.71 | 36.57 | 22.19 | 2.51 | 0.07 | 1.87 |
| 1.00 | 36.55 | 21.01 | 4.38 | 0.05 | 1.34 |
| 2.20 | 36.37 | 21.76 | 3.61 | 0.07 | 1.24 |
