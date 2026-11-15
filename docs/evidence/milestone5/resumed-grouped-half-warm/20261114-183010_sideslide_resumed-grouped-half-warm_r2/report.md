# sideslide - 20261114-183010_sideslide_resumed-grouped-half-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.76 s - 359 frames, 75.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2780 | 556 | 109 | 113 | 147 | 96 | 148 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1340, BelowThresh 881, NormalForce 3

Body materials: METAL 410, PLASTIC 146

Surfaces: ASPHALT 556

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.725 | 25.336 | 36.033 |
| whole frame, ms | 10.656 (p50) | 32.092 | 43.131 |
| all GE Lua, ms | | 26.097 | 37.009 |
| physics + vehicle Lua, ms | | 0.095 | 0.207 |
| render, ms | | 2.185 | |

- Painter frames over 4 ms: 99; worst flush (project + bake) 36.0 ms, worst composite 0.114 ms.
- Detector: 1.582 us per contact, 8.11 ms total, worst frame 0.37 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.99 | 43.13 | 36.03 | 1.25 | 0.05 | 1.60 |
| 3.17 | 42.95 | 33.45 | 0.86 | 0.04 | 1.86 |
| 2.19 | 41.45 | 34.24 | 1.00 | 0.05 | 1.74 |
| 0.10 | 41.40 | 30.31 | 0.78 | 0.06 | 1.68 |
| 1.39 | 40.42 | 33.00 | 0.79 | 0.05 | 1.53 |
