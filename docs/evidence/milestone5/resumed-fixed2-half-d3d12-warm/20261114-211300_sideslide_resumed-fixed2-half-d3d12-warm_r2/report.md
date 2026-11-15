# sideslide - 20261114-211300_sideslide_resumed-fixed2-half-d3d12-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.309 s - 333 frames, 77.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.202)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2573 | 603 | 88 | 109 | 122 | 101 | 126 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1303, BelowThresh 664, NormalForce 3

Body materials: METAL 429, PLASTIC 174

Surfaces: ASPHALT 603

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.897 | 25.724 | 37.668 |
| whole frame, ms | 10.278 (p50) | 32.556 | 45.74 |
| all GE Lua, ms | | 26.821 | 38.571 |
| physics + vehicle Lua, ms | | 0.086 | 0.986 |
| render, ms | | 1.943 | |

- Painter frames over 4 ms: 89; worst flush (project + bake) 37.627 ms, worst composite 0.097 ms.
- Detector: 1.609 us per contact, 8.582 ms total, worst frame 0.477 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.89 | 45.74 | 34.71 | 0.90 | 0.06 | 1.61 |
| 1.71 | 44.14 | 37.67 | 0.94 | 0.04 | 1.34 |
| 2.33 | 41.89 | 34.69 | 0.80 | 0.04 | 1.46 |
| 0.18 | 40.22 | 29.54 | 0.74 | 0.07 | 1.69 |
| 2.86 | 37.01 | 30.12 | 0.88 | 0.05 | 1.43 |
