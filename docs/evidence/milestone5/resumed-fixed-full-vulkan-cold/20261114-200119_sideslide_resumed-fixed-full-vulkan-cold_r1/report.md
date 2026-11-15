# sideslide - 20261114-200119_sideslide_resumed-fixed-full-vulkan-cold_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.661 s - 367 frames, 67.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2803 | 663 | 90 | 132 | 110 | 108 | 140 | 0.0% | 0 | 3 |

Rejected contacts: Wheel 1260, BelowThresh 878, NormalForce 2

Body materials: METAL 499, PLASTIC 164

Surfaces: ASPHALT 663

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.133 | 25.783 | 40.329 |
| whole frame, ms | 12.268 (p50) | 32.738 | 51.436 |
| all GE Lua, ms | | 26.545 | 41.4 |
| physics + vehicle Lua, ms | | 0.091 | 0.357 |
| render, ms | | 1.595 | |

- Painter frames over 4 ms: 62; worst flush (project + bake) 40.313 ms, worst composite 0.186 ms.
- Detector: 1.624 us per contact, 9.138 ms total, worst frame 0.742 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 51.44 | 40.33 | 0.73 | 0.06 | 1.52 |
| 3.58 | 44.46 | 33.66 | 0.94 | 0.04 | 1.54 |
| 3.21 | 43.45 | 33.42 | 0.67 | 0.05 | 1.17 |
| 3.15 | 42.92 | 28.44 | 0.72 | 0.04 | 1.14 |
| 3.26 | 42.81 | 36.11 | 0.79 | 0.03 | 1.20 |
