# sideslide - 20261114-211023_sideslide_resumed-fixed2-full-d3d12-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.672 s - 242 frames, 53.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2027 | 369 | 85 | 76 | 161 | 68 | 109 | 0.0% | 0 | 3 |

Rejected contacts: Wheel 973, BelowThresh 685

Body materials: METAL 266, PLASTIC 103

Surfaces: ASPHALT 369

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 9.393 | 26.533 | 34.063 |
| whole frame, ms | 18.518 (p50) | 35.52 | 41.369 |
| all GE Lua, ms | | 27.439 | 35.022 |
| physics + vehicle Lua, ms | | 0.101 | 2.571 |
| render, ms | | 2.046 | |

- Painter frames over 4 ms: 129; worst flush (project + bake) 34.024 ms, worst composite 0.091 ms.
- Detector: 1.471 us per contact, 6.884 ms total, worst frame 0.454 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.59 | 41.37 | 32.34 | 17.08 | 0.06 | 2.02 |
| 1.11 | 41.20 | 32.00 | 18.56 | 0.10 | 1.86 |
| 2.82 | 40.67 | 34.06 | 11.71 | 0.08 | 1.52 |
| 4.67 | 40.44 | 28.33 | 0.72 | 0.04 | 1.86 |
| 1.36 | 40.37 | 30.52 | 21.17 | 0.08 | 1.55 |
