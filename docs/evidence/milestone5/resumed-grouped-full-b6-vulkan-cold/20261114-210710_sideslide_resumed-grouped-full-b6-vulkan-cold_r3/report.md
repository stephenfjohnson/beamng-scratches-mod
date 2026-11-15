# sideslide - 20261114-210710_sideslide_resumed-grouped-full-b6-vulkan-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.224 s - 300 frames, 60.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2562 | 607 | 88 | 117 | 117 | 100 | 81 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1357, BelowThresh 595, NormalForce 3

Body materials: METAL 448, PLASTIC 159

Surfaces: ASPHALT 607

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.408 | 27.626 | 47.559 |
| whole frame, ms | 12.879 (p50) | 34.819 | 64.272 |
| all GE Lua, ms | | 28.505 | 48.741 |
| physics + vehicle Lua, ms | | 0.112 | 1.547 |
| render, ms | | 1.584 | |

- Painter frames over 4 ms: 95; worst flush (project + bake) 47.535 ms, worst composite 0.093 ms.
- Detector: 1.626 us per contact, 8.058 ms total, worst frame 0.503 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 64.27 | 47.56 | 0.98 | 0.09 | 1.82 |
| 0.32 | 49.14 | 41.41 | 3.33 | 0.05 | 1.51 |
| 0.24 | 43.20 | 35.69 | 0.80 | 0.06 | 1.38 |
| 2.61 | 41.00 | 24.47 | 0.76 | 0.05 | 1.28 |
| 2.72 | 40.66 | 28.11 | 0.94 | 0.05 | 2.95 |
