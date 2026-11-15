# sideslide - 20261114-184622_sideslide_resumed-grouped-half-untraced_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.127 s - 325 frames, 78.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.149)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3144 | 681 | 83 | 136 | 113 | 105 | 158 | 0.0% | 0 | 3 |

Rejected contacts: Wheel 1706, BelowThresh 750, NormalForce 7

Body materials: METAL 515, PLASTIC 166

Surfaces: ASPHALT 681

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.788 | 29.408 | 35.405 |
| whole frame, ms | 10.288 (p50) | 36.159 | 46.001 |
| all GE Lua, ms | | 30.541 | 36.406 |
| physics + vehicle Lua, ms | | 0.089 | 0.262 |
| render, ms | | 1.972 | |

- Painter frames over 4 ms: 91; worst flush (project + bake) 35.38 ms, worst composite 0.121 ms.
- Detector: 1.366 us per contact, 8.135 ms total, worst frame 0.348 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.00 | 35.29 | 0.81 | 0.09 | 1.86 |
| 3.14 | 42.12 | 31.92 | 0.78 | 0.05 | 1.74 |
| 2.92 | 41.63 | 35.41 | 0.86 | 0.04 | 1.46 |
| 1.96 | 40.90 | 34.26 | 1.05 | 0.04 | 1.51 |
| 2.60 | 40.13 | 33.20 | 1.83 | 0.05 | 1.86 |
