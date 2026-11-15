# sideslide - 20261114-193059_sideslide_resumed-control-v2-full-vulkan_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: True after 4.123 s - 276 frames, 66.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2597 | 576 | 85 | 114 | 113 | 78 | 73 | 0.0% | 0 | 15 |

Rejected contacts: Wheel 1449, BelowThresh 571, NormalForce 1

Body materials: METAL 433, PLASTIC 143

Surfaces: ASPHALT 576

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.785 | 26.435 | 42.887 |
| whole frame, ms | 12.915 (p50) | 34.667 | 55.381 |
| all GE Lua, ms | | 27.227 | 43.768 |
| physics + vehicle Lua, ms | | 0.121 | 0.899 |
| render, ms | | 1.667 | |

- Painter frames over 4 ms: 80; worst flush (project + bake) 42.868 ms, worst composite 0.074 ms.
- Detector: 1.592 us per contact, 8.167 ms total, worst frame 0.506 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.04 | 55.38 | 42.89 | 0.88 | 0.07 | 1.21 |
| 0.39 | 54.06 | 42.24 | 0.75 | 0.04 | 1.33 |
| 1.63 | 53.65 | 41.49 | 0.79 | 0.05 | 1.33 |
| 1.02 | 53.18 | 41.62 | 0.83 | 0.04 | 1.30 |
| 0.60 | 51.58 | 38.26 | 0.93 | 0.05 | 1.62 |
