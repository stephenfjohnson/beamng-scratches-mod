# sideslide - 20261114-193740_sideslide_resumed-selected-half-vulkan-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.265 s - 315 frames, 73.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2486 | 611 | 80 | 119 | 118 | 103 | 145 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1227, BelowThresh 646, NormalForce 2

Body materials: METAL 427, PLASTIC 184

Surfaces: ASPHALT 611

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.889 | 34.604 | 40.78 |
| whole frame, ms | 9.728 (p50) | 42.14 | 51.858 |
| all GE Lua, ms | | 35.516 | 41.998 |
| physics + vehicle Lua, ms | | 0.089 | 0.266 |
| render, ms | | 1.622 | |

- Painter frames over 4 ms: 45; worst flush (project + bake) 40.758 ms, worst composite 0.092 ms.
- Detector: 1.634 us per contact, 8.561 ms total, worst frame 1.104 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.44 | 51.86 | 40.61 | 1.27 | 0.05 | 1.40 |
| 2.63 | 51.82 | 40.78 | 1.45 | 0.06 | 1.27 |
| 0.33 | 50.61 | 39.24 | 1.63 | 0.04 | 1.32 |
| 2.15 | 48.46 | 36.84 | 1.46 | 0.04 | 1.24 |
| 0.18 | 48.45 | 35.59 | 0.73 | 0.08 | 1.39 |
