# sideslide - 20261114-194303_sideslide_resumed-selected-half-vulkan-endurance_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.238 s - 312 frames, 73.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.189)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2705 | 603 | 98 | 118 | 127 | 101 | 156 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1497, BelowThresh 602, NormalForce 3

Body materials: METAL 435, PLASTIC 168

Surfaces: ASPHALT 603

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.894 | 35.17 | 38.464 |
| whole frame, ms | 9.99 (p50) | 42.831 | 50.066 |
| all GE Lua, ms | | 36.149 | 39.338 |
| physics + vehicle Lua, ms | | 0.075 | 0.102 |
| render, ms | | 1.552 | |

- Painter frames over 4 ms: 43; worst flush (project + bake) 38.443 ms, worst composite 0.663 ms.
- Detector: 1.39 us per contact, 7.588 ms total, worst frame 0.501 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.75 | 50.07 | 37.40 | 1.22 | 0.05 | 1.22 |
| 0.85 | 49.75 | 37.79 | 1.20 | 0.09 | 1.96 |
| 2.16 | 49.29 | 36.73 | 1.52 | 0.04 | 1.19 |
| 0.48 | 48.81 | 37.51 | 1.73 | 0.06 | 1.48 |
| 2.96 | 48.40 | 36.85 | 1.22 | 0.04 | 1.44 |
