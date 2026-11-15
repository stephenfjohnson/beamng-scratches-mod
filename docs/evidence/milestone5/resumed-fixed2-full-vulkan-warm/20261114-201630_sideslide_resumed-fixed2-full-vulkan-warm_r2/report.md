# sideslide - 20261114-201630_sideslide_resumed-fixed2-full-vulkan-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.217 s - 255 frames, 60.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2326 | 431 | 108 | 95 | 145 | 89 | 121 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1319, BelowThresh 574, NormalForce 2

Body materials: METAL 325, PLASTIC 106

Surfaces: ASPHALT 431

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.412 | 20.098 | 34.837 |
| whole frame, ms | 13.862 (p50) | 31.455 | 46.757 |
| all GE Lua, ms | | 21.542 | 35.683 |
| physics + vehicle Lua, ms | | 0.114 | 1.02 |
| render, ms | | 2.091 | |

- Painter frames over 4 ms: 59; worst flush (project + bake) 34.802 ms, worst composite 0.08 ms.
- Detector: 1.436 us per contact, 8.012 ms total, worst frame 0.511 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.76 | 32.99 | 1.07 | 0.10 | 2.25 |
| 3.67 | 46.31 | 34.84 | 0.90 | 0.05 | 1.27 |
| 0.37 | 42.03 | 24.81 | 3.19 | 0.06 | 2.51 |
| 0.24 | 40.19 | 30.60 | 0.99 | 0.08 | 1.83 |
| 0.67 | 37.65 | 23.49 | 2.63 | 0.62 | 1.71 |
