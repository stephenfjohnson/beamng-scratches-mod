# sideslide - 20261114-200254_sideslide_resumed-fixed-full-vulkan-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.393 s - 341 frames, 66.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.177)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2306 | 577 | 108 | 133 | 120 | 108 | 141 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1128, BelowThresh 596, NormalForce 5

Body materials: METAL 421, PLASTIC 156

Surfaces: ASPHALT 577

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.575 | 23.907 | 40.221 |
| whole frame, ms | 12.252 (p50) | 33.62 | 51.416 |
| all GE Lua, ms | | 24.984 | 42.16 |
| physics + vehicle Lua, ms | | 0.089 | 0.333 |
| render, ms | | 1.561 | |

- Painter frames over 4 ms: 59; worst flush (project + bake) 40.203 ms, worst composite 0.132 ms.
- Detector: 1.729 us per contact, 8.519 ms total, worst frame 0.59 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 51.42 | 39.94 | 0.75 | 0.06 | 1.47 |
| 1.97 | 47.70 | 40.22 | 0.87 | 0.03 | 1.32 |
| 2.80 | 45.27 | 39.15 | 0.76 | 0.03 | 1.47 |
| 2.45 | 45.22 | 34.14 | 0.80 | 0.04 | 1.25 |
| 4.06 | 44.97 | 34.08 | 0.81 | 0.03 | 1.28 |
