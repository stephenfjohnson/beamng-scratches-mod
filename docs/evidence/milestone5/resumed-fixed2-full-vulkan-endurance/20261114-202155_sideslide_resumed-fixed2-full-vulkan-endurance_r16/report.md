# sideslide - 20261114-202155_sideslide_resumed-fixed2-full-vulkan-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.095 s - 255 frames, 62.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.14)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2542 | 546 | 71 | 111 | 120 | 95 | 120 | 0.0% | 0 | 0 |

Rejected contacts: Wheel 1372, BelowThresh 620, NormalForce 4

Body materials: METAL 409, PLASTIC 137

Surfaces: ASPHALT 546

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.034 | 20.056 | 36.614 |
| whole frame, ms | 13.565 (p50) | 31.582 | 49.949 |
| all GE Lua, ms | | 20.948 | 37.737 |
| physics + vehicle Lua, ms | | 0.102 | 0.491 |
| render, ms | | 1.8 | |

- Painter frames over 4 ms: 43; worst flush (project + bake) 36.586 ms, worst composite 0.112 ms.
- Detector: 1.606 us per contact, 7.33 ms total, worst frame 0.336 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 49.95 | 36.61 | 1.19 | 0.08 | 1.88 |
| 3.05 | 36.88 | 26.32 | 0.81 | 0.05 | 1.20 |
| 0.29 | 36.87 | 21.76 | 2.87 | 0.06 | 1.80 |
| 2.36 | 35.73 | 19.61 | 3.60 | 0.13 | 1.35 |
| 1.65 | 35.65 | 21.46 | 3.42 | 0.06 | 1.19 |
