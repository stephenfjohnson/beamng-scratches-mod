# sideslide - 20261114-201716_sideslide_resumed-fixed2-full-vulkan-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.233 s - 245 frames, 58.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.167)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2143 | 466 | 89 | 107 | 141 | 91 | 125 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1112, BelowThresh 563, NormalForce 2

Body materials: METAL 344, PLASTIC 122

Surfaces: ASPHALT 466

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.171 | 18.66 | 36.378 |
| whole frame, ms | 15.753 (p50) | 32.529 | 46.791 |
| all GE Lua, ms | | 19.698 | 37.667 |
| physics + vehicle Lua, ms | | 0.121 | 1.075 |
| render, ms | | 1.83 | |

- Painter frames over 4 ms: 54; worst flush (project + bake) 36.335 ms, worst composite 0.154 ms.
- Detector: 1.626 us per contact, 7.469 ms total, worst frame 0.462 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.79 | 36.38 | 0.92 | 0.06 | 1.35 |
| 3.64 | 45.90 | 31.37 | 0.90 | 0.05 | 1.24 |
| 2.43 | 38.33 | 20.69 | 2.42 | 0.06 | 1.53 |
| 1.73 | 38.07 | 22.17 | 4.96 | 0.07 | 1.52 |
| 3.17 | 36.22 | 17.32 | 6.01 | 0.07 | 1.22 |
