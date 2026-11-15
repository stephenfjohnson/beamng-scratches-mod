# sideslide - 20261114-190751_sideslide_resumed-selected-half-d3d12-cold_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.111 s - 382 frames, 77.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.137)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3230 | 875 | 73 | 151 | 84 | 113 | 153 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1589, BelowThresh 762, NormalForce 4

Body materials: METAL 652, PLASTIC 223

Surfaces: ASPHALT 875

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.114 | 28.308 | 40.841 |
| whole frame, ms | 10.274 (p50) | 35.259 | 50.521 |
| all GE Lua, ms | | 29.259 | 41.959 |
| physics + vehicle Lua, ms | | 0.089 | 0.22 |
| render, ms | | 2.056 | |

- Painter frames over 4 ms: 120; worst flush (project + bake) 40.816 ms, worst composite 0.084 ms.
- Detector: 1.774 us per contact, 10.717 ms total, worst frame 0.601 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.94 | 50.52 | 40.84 | 0.88 | 0.05 | 1.59 |
| 1.40 | 48.79 | 39.57 | 0.93 | 0.04 | 1.43 |
| 1.84 | 47.28 | 37.29 | 0.87 | 0.04 | 1.55 |
| 0.18 | 45.93 | 31.28 | 1.19 | 0.09 | 3.35 |
| 1.55 | 45.91 | 36.60 | 0.81 | 0.06 | 1.53 |
