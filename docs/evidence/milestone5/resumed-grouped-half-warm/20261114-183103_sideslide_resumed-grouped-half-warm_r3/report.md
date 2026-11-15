# sideslide - 20261114-183103_sideslide_resumed-grouped-half-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.225 s - 305 frames, 72.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2603 | 580 | 82 | 120 | 116 | 100 | 145 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1390, BelowThresh 632, NormalForce 1

Body materials: METAL 428, PLASTIC 152

Surfaces: ASPHALT 580

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.099 | 25.116 | 34.936 |
| whole frame, ms | 10.858 (p50) | 32.548 | 42.577 |
| all GE Lua, ms | | 25.996 | 36.013 |
| physics + vehicle Lua, ms | | 0.091 | 0.156 |
| render, ms | | 2.269 | |

- Painter frames over 4 ms: 88; worst flush (project + bake) 34.911 ms, worst composite 0.17 ms.
- Detector: 1.611 us per contact, 7.668 ms total, worst frame 0.411 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.74 | 42.58 | 28.68 | 2.94 | 0.09 | 2.54 |
| 0.59 | 42.45 | 34.43 | 2.90 | 0.07 | 2.17 |
| 2.27 | 41.64 | 34.94 | 1.02 | 0.05 | 1.49 |
| 0.17 | 41.60 | 29.34 | 0.78 | 0.05 | 1.99 |
| 2.99 | 39.26 | 32.41 | 0.78 | 0.05 | 1.67 |
