# sideslide - 20261114-190930_sideslide_resumed-selected-half-d3d12-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.109 s - 357 frames, 73.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.157)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3268 | 842 | 71 | 138 | 80 | 94 | 147 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1750, BelowThresh 673, NormalForce 3

Body materials: METAL 618, PLASTIC 224

Surfaces: ASPHALT 842

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.997 | 23.054 | 38.29 |
| whole frame, ms | 10.813 (p50) | 31.299 | 47.627 |
| all GE Lua, ms | | 24.233 | 39.227 |
| physics + vehicle Lua, ms | | 0.112 | 0.211 |
| render, ms | | 2.961 | |

- Painter frames over 4 ms: 118; worst flush (project + bake) 38.266 ms, worst composite 0.2 ms.
- Detector: 1.991 us per contact, 11.62 ms total, worst frame 0.577 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 47.63 | 35.06 | 1.10 | 0.06 | 2.74 |
| 1.91 | 47.53 | 38.19 | 0.88 | 0.05 | 1.45 |
| 1.67 | 46.07 | 35.26 | 1.13 | 0.09 | 1.85 |
| 2.02 | 45.51 | 38.29 | 0.80 | 0.04 | 1.43 |
| 0.59 | 40.63 | 32.76 | 1.13 | 0.05 | 1.59 |
