# sideslide - 20261114-192803_sideslide_resumed-selected-half-vulkan-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.106 s - 300 frames, 72.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.158)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2994 | 662 | 77 | 112 | 122 | 106 | 139 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1699, BelowThresh 631, NormalForce 2

Body materials: METAL 498, PLASTIC 164

Surfaces: ASPHALT 662

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.128 | 35.844 | 40.285 |
| whole frame, ms | 9.224 (p50) | 44.27 | 52.364 |
| all GE Lua, ms | | 36.88 | 41.251 |
| physics + vehicle Lua, ms | | 0.083 | 0.263 |
| render, ms | | 1.609 | |

- Painter frames over 4 ms: 44; worst flush (project + bake) 40.264 ms, worst composite 0.077 ms.
- Detector: 1.451 us per contact, 8.354 ms total, worst frame 0.484 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.42 | 52.36 | 40.29 | 1.41 | 0.04 | 1.14 |
| 0.57 | 49.76 | 36.64 | 1.84 | 0.08 | 1.42 |
| 0.45 | 49.58 | 38.87 | 1.33 | 0.04 | 1.37 |
| 1.51 | 49.56 | 38.20 | 1.13 | 0.03 | 1.19 |
| 1.30 | 49.29 | 38.38 | 1.19 | 0.04 | 1.15 |
