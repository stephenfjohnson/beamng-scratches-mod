# sideslide - 20261114-184537_sideslide_resumed-grouped-half-untraced_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.241 s - 327 frames, 77.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2820 | 643 | 88 | 126 | 106 | 104 | 142 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1501, BelowThresh 674, NormalForce 2

Body materials: METAL 480, PLASTIC 163

Surfaces: ASPHALT 643

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.987 | 25.779 | 38.189 |
| whole frame, ms | 10.243 (p50) | 32.877 | 45.262 |
| all GE Lua, ms | | 26.717 | 39.058 |
| physics + vehicle Lua, ms | | 0.086 | 0.2 |
| render, ms | | 2.136 | |

- Painter frames over 4 ms: 91; worst flush (project + bake) 38.158 ms, worst composite 0.091 ms.
- Detector: 1.482 us per contact, 7.757 ms total, worst frame 0.501 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 45.26 | 38.19 | 2.14 | 0.08 | 1.99 |
| 2.77 | 40.69 | 34.25 | 0.93 | 0.04 | 1.57 |
| 0.18 | 39.46 | 28.38 | 0.69 | 0.09 | 2.18 |
| 0.96 | 38.63 | 31.56 | 2.96 | 0.06 | 1.48 |
| 1.94 | 37.85 | 32.02 | 0.83 | 0.04 | 1.37 |
