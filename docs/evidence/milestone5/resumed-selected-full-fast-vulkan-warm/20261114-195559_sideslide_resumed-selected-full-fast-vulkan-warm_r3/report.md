# sideslide - 20261114-195559_sideslide_resumed-selected-full-fast-vulkan-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.353 s - 271 frames, 62.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.174)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2108 | 446 | 105 | 101 | 141 | 96 | 132 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1073, BelowThresh 587, NormalForce 2

Body materials: METAL 326, PLASTIC 120

Surfaces: ASPHALT 446

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.149 | 19.521 | 35.635 |
| whole frame, ms | 14.099 (p50) | 33.3 | 47.638 |
| all GE Lua, ms | | 20.487 | 36.559 |
| physics + vehicle Lua, ms | | 0.101 | 0.572 |
| render, ms | | 1.631 | |

- Painter frames over 4 ms: 41; worst flush (project + bake) 35.612 ms, worst composite 0.119 ms.
- Detector: 1.427 us per contact, 6.288 ms total, worst frame 0.343 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 47.64 | 35.63 | 0.72 | 0.06 | 1.45 |
| 1.46 | 37.72 | 24.99 | 1.98 | 0.04 | 1.39 |
| 3.37 | 36.93 | 31.12 | 0.80 | 0.06 | 1.22 |
| 3.43 | 36.84 | 31.36 | 0.64 | 0.03 | 1.32 |
| 0.23 | 36.03 | 30.01 | 0.86 | 0.06 | 1.60 |
