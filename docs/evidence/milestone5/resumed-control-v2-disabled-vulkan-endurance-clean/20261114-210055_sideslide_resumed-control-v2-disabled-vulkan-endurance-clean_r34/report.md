# sideslide - 20261114-210055_sideslide_resumed-control-v2-disabled-vulkan-endurance-clean_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.571 s - 380 frames, 82.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.187)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2370 | 652 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1017, BelowThresh 701

Body materials: METAL 459, PLASTIC 193

Surfaces: ASPHALT 652

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.007 | 0.009 | 0.015 |
| whole frame, ms | 12.107 (p50) | 13.217 | 15.267 |
| all GE Lua, ms | | 1.199 | 1.743 |
| physics + vehicle Lua, ms | | 0.081 | 0.282 |
| render, ms | | 1.785 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.056 us per contact, 4.011 ms total, worst frame 0.041 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.89 | 15.27 | 0.01 | 0.87 | 0.04 | 1.65 |
| 4.14 | 15.11 | 0.01 | 0.87 | 0.04 | 1.73 |
| 0.13 | 14.56 | 0.01 | 1.00 | 0.07 | 1.46 |
| 1.15 | 14.20 | 0.01 | 0.99 | 0.05 | 1.53 |
| 1.26 | 14.16 | 0.01 | 0.94 | 0.04 | 1.53 |
