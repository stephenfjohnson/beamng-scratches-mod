# sideslide - 20261114-223349_sideslide_synth-full-d3d12-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.13 s - 307 frames, 62.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.141)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2877 | 637 | 80 | 133 | 108 | 109 | 131 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1554, BelowThresh 683, NormalForce 3

Body materials: METAL 481, PLASTIC 156

Surfaces: ASPHALT 637

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 6.93 | 20.099 | 28.375 |
| whole frame, ms | 11.367 (p50) | 29.183 | 38.301 |
| all GE Lua, ms | | 21.12 | 29.479 |
| physics + vehicle Lua, ms | | 0.091 | 0.995 |
| render, ms | | 2.278 | |

- Painter frames over 4 ms: 131; worst flush (project + bake) 2.648 ms, worst composite 0.15 ms.
- Detector: 1.57 us per contact, 8.87 ms total, worst frame 0.778 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 38.30 | 28.37 | 2.08 | 0.10 | 1.70 |
| 2.14 | 38.04 | 20.43 | 17.70 | 0.09 | 2.09 |
| 0.31 | 34.59 | 28.34 | 3.48 | 0.05 | 1.33 |
| 1.43 | 33.53 | 16.39 | 18.56 | 0.08 | 1.46 |
| 2.27 | 33.24 | 16.25 | 19.81 | 0.08 | 2.11 |
