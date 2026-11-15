# sideslide - 20261114-192509_sideslide_resumed-selected-half-vulkan-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.115 s - 370 frames, 75.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.142)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3241 | 812 | 74 | 152 | 88 | 102 | 160 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1706, BelowThresh 716, NormalForce 7

Body materials: METAL 616, PLASTIC 196

Surfaces: ASPHALT 812

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.445 | 34.52 | 40.205 |
| whole frame, ms | 8.566 (p50) | 45.273 | 51.926 |
| all GE Lua, ms | | 35.66 | 41.048 |
| physics + vehicle Lua, ms | | 0.083 | 0.155 |
| render, ms | | 1.727 | |

- Painter frames over 4 ms: 51; worst flush (project + bake) 40.182 ms, worst composite 0.248 ms.
- Detector: 1.539 us per contact, 10.238 ms total, worst frame 1.021 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.33 | 51.93 | 40.20 | 1.57 | 0.04 | 1.40 |
| 1.42 | 49.69 | 37.61 | 0.80 | 0.04 | 1.28 |
| 1.63 | 49.56 | 38.49 | 0.90 | 0.03 | 1.24 |
| 0.91 | 48.99 | 36.79 | 0.98 | 0.04 | 1.23 |
| 0.44 | 48.96 | 37.03 | 1.71 | 0.07 | 1.34 |
