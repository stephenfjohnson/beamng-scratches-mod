# sideslide - 20261114-185854_sideslide_resumed-selected-half-d3d12-endurance_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.073 s - 312 frames, 76.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.159)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3011 | 663 | 72 | 128 | 95 | 98 | 143 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1688, BelowThresh 654, NormalForce 6

Body materials: METAL 489, PLASTIC 174

Surfaces: ASPHALT 663

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.809 | 27.067 | 36.61 |
| whole frame, ms | 10.551 (p50) | 33.094 | 44.706 |
| all GE Lua, ms | | 27.92 | 37.947 |
| physics + vehicle Lua, ms | | 0.092 | 0.165 |
| render, ms | | 2.244 | |

- Painter frames over 4 ms: 91; worst flush (project + bake) 36.586 ms, worst composite 0.128 ms.
- Detector: 1.483 us per contact, 7.946 ms total, worst frame 0.38 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.68 | 44.71 | 36.61 | 0.86 | 0.05 | 1.50 |
| 2.11 | 41.56 | 34.47 | 2.00 | 0.05 | 1.64 |
| 1.43 | 40.52 | 29.87 | 1.55 | 0.06 | 2.63 |
| 0.18 | 39.66 | 28.86 | 0.81 | 0.07 | 1.95 |
| 4.07 | 38.87 | 27.32 | 0.81 | 0.04 | 2.37 |
