# sideslide - 20261114-201004_sideslide_resumed-fixed2-full-vulkan-cold_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.152 s - 300 frames, 61.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2507 | 619 | 85 | 123 | 113 | 108 | 129 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1239, BelowThresh 647, NormalForce 2

Body materials: METAL 463, PLASTIC 156

Surfaces: ASPHALT 619

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.404 | 22.361 | 34.11 |
| whole frame, ms | 13.228 (p50) | 33.349 | 46.938 |
| all GE Lua, ms | | 23.286 | 35.065 |
| physics + vehicle Lua, ms | | 0.113 | 0.168 |
| render, ms | | 2.127 | |

- Painter frames over 4 ms: 67; worst flush (project + bake) 34.09 ms, worst composite 0.119 ms.
- Detector: 1.894 us per contact, 9.447 ms total, worst frame 0.665 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.94 | 32.65 | 0.94 | 0.06 | 2.28 |
| 3.65 | 45.18 | 34.11 | 0.80 | 0.04 | 1.15 |
| 2.91 | 38.11 | 27.14 | 0.73 | 0.04 | 1.22 |
| 1.94 | 38.11 | 30.17 | 1.08 | 0.04 | 1.54 |
| 0.33 | 37.38 | 25.25 | 2.10 | 0.05 | 1.51 |
