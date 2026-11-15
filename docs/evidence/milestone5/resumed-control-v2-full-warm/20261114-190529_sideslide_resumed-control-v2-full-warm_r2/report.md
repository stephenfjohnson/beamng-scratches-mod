# sideslide - 20261114-190529_sideslide_resumed-control-v2-full-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 4.311 s - 147 frames, 36.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1197 | 297 | 110 | 57 | 186 | 87 | 59 | 0.0% | 0 | 15 |

Rejected contacts: Wheel 635, BelowThresh 265

Body materials: METAL 223, PLASTIC 74

Surfaces: ASPHALT 297

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 16.705 | 41.016 | 54.563 |
| whole frame, ms | 22.863 (p50) | 51.095 | 63.046 |
| all GE Lua, ms | | 42.011 | 55.409 |
| physics + vehicle Lua, ms | | 6.031 | 9.423 |
| render, ms | | 2.42 | |

- Painter frames over 4 ms: 76; worst flush (project + bake) 54.499 ms, worst composite 0.115 ms.
- Detector: 1.628 us per contact, 4.84 ms total, worst frame 0.348 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 63.05 | 54.56 | 0.91 | 2.26 | 1.54 |
| 3.51 | 59.63 | 51.06 | 0.71 | 1.23 | 1.74 |
| 0.82 | 58.33 | 44.55 | 0.98 | 4.47 | 2.46 |
| 0.18 | 53.42 | 40.97 | 0.77 | 0.05 | 2.42 |
| 1.32 | 52.46 | 43.65 | 38.52 | 0.08 | 1.79 |
