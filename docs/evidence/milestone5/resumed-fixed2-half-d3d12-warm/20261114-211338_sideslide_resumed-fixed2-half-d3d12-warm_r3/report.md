# sideslide - 20261114-211338_sideslide_resumed-fixed2-half-d3d12-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.078 s - 312 frames, 76.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3111 | 633 | 81 | 119 | 106 | 95 | 120 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1781, BelowThresh 693, NormalForce 4

Body materials: METAL 480, PLASTIC 153

Surfaces: ASPHALT 633

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.847 | 24.031 | 32.102 |
| whole frame, ms | 10.407 (p50) | 31.436 | 40.018 |
| all GE Lua, ms | | 24.996 | 33.125 |
| physics + vehicle Lua, ms | | 0.09 | 0.459 |
| render, ms | | 1.948 | |

- Painter frames over 4 ms: 101; worst flush (project + bake) 32.074 ms, worst composite 0.108 ms.
- Detector: 1.46 us per contact, 8.983 ms total, worst frame 0.432 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 40.02 | 29.01 | 0.81 | 0.06 | 1.79 |
| 0.61 | 38.52 | 32.10 | 1.05 | 0.06 | 1.43 |
| 2.46 | 38.39 | 29.56 | 1.11 | 0.07 | 2.03 |
| 1.90 | 38.27 | 32.03 | 0.72 | 0.04 | 1.44 |
| 1.42 | 37.34 | 31.63 | 0.98 | 0.03 | 1.45 |
