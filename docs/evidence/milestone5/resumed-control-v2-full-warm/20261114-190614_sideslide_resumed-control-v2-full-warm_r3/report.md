# sideslide - 20261114-190614_sideslide_resumed-control-v2-full-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 4.265 s - 157 frames, 38.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.153)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1284 | 322 | 92 | 69 | 180 | 79 | 64 | 0.0% | 0 | 15 |

Rejected contacts: Wheel 705, BelowThresh 257

Body materials: METAL 235, PLASTIC 87

Surfaces: ASPHALT 322

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.686 | 37.846 | 56.903 |
| whole frame, ms | 23.832 (p50) | 48.028 | 66.552 |
| all GE Lua, ms | | 38.671 | 57.86 |
| physics + vehicle Lua, ms | | 4.672 | 7.312 |
| render, ms | | 2.218 | |

- Painter frames over 4 ms: 81; worst flush (project + bake) 56.873 ms, worst composite 0.091 ms.
- Detector: 1.787 us per contact, 5.32 ms total, worst frame 0.369 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.83 | 66.55 | 56.90 | 0.80 | 3.65 | 1.52 |
| 2.83 | 59.70 | 28.03 | 0.98 | 6.85 | 2.22 |
| 2.37 | 57.35 | 27.06 | 0.73 | 7.31 | 1.81 |
| 1.68 | 52.51 | 26.43 | 1.00 | 5.78 | 1.58 |
| 3.53 | 52.04 | 25.17 | 0.99 | 6.10 | 1.60 |
