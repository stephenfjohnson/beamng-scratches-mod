# sideslide - 20261114-192718_sideslide_resumed-selected-half-vulkan-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.129 s - 298 frames, 66.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.149)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2862 | 635 | 74 | 132 | 104 | 113 | 148 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1519, BelowThresh 706, NormalForce 2

Body materials: METAL 481, PLASTIC 154

Surfaces: ASPHALT 635

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.504 | 35.532 | 42.704 |
| whole frame, ms | 11.077 (p50) | 43.763 | 441.568 |
| all GE Lua, ms | | 36.471 | 43.55 |
| physics + vehicle Lua, ms | | 0.099 | 0.518 |
| render, ms | | 1.86 | |

- Painter frames over 4 ms: 43; worst flush (project + bake) 42.679 ms, worst composite 0.102 ms.
- Detector: 1.547 us per contact, 8.215 ms total, worst frame 0.463 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.10 | 441.57 | 12.93 | 1.25 | 0.04 | 1.26 |
| 2.13 | 54.76 | 42.70 | 1.41 | 0.05 | 1.44 |
| 2.25 | 52.73 | 40.61 | 1.22 | 0.04 | 1.16 |
| 2.34 | 50.58 | 38.15 | 1.37 | 0.05 | 1.19 |
| 0.19 | 50.46 | 38.92 | 1.34 | 0.10 | 1.79 |
