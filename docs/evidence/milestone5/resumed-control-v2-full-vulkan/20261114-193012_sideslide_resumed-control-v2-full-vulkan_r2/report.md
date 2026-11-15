# sideslide - 20261114-193012_sideslide_resumed-control-v2-full-vulkan_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 4.152 s - 252 frames, 61.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.151)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2322 | 585 | 94 | 116 | 129 | 82 | 77 | 0.0% | 0 | 16 |

Rejected contacts: Wheel 1228, BelowThresh 507, NormalForce 2

Body materials: METAL 444, PLASTIC 141

Surfaces: ASPHALT 585

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.273 | 24.297 | 51.469 |
| whole frame, ms | 13.624 (p50) | 38.246 | 61.397 |
| all GE Lua, ms | | 25.427 | 52.499 |
| physics + vehicle Lua, ms | | 0.137 | 1.625 |
| render, ms | | 1.979 | |

- Painter frames over 4 ms: 81; worst flush (project + bake) 51.429 ms, worst composite 0.104 ms.
- Detector: 1.677 us per contact, 7.943 ms total, worst frame 0.581 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.39 | 61.40 | 51.47 | 0.93 | 0.06 | 1.98 |
| 0.19 | 59.02 | 46.50 | 1.00 | 0.07 | 1.71 |
| 2.49 | 53.63 | 43.85 | 0.79 | 0.05 | 1.29 |
| 2.90 | 50.83 | 37.04 | 0.76 | 0.04 | 1.44 |
| 2.28 | 48.14 | 38.43 | 0.67 | 0.03 | 1.34 |
