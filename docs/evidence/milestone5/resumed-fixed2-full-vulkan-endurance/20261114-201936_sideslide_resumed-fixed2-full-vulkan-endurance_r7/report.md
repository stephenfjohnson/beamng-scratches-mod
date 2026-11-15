# sideslide - 20261114-201936_sideslide_resumed-fixed2-full-vulkan-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.572 s - 374 frames, 66.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.173)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2733 | 440 | 130 | 99 | 165 | 99 | 135 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1226, BelowThresh 1066, NormalForce 1

Body materials: METAL 325, PLASTIC 115

Surfaces: ASPHALT 440

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.196 | 19.495 | 37.395 |
| whole frame, ms | 12.478 (p50) | 30.382 | 49.803 |
| all GE Lua, ms | | 20.587 | 38.612 |
| physics + vehicle Lua, ms | | 0.095 | 1.433 |
| render, ms | | 1.635 | |

- Painter frames over 4 ms: 52; worst flush (project + bake) 37.369 ms, worst composite 0.066 ms.
- Detector: 1.313 us per contact, 7.534 ms total, worst frame 0.417 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 49.80 | 37.39 | 0.74 | 0.05 | 1.36 |
| 3.53 | 46.34 | 34.67 | 0.83 | 0.04 | 1.19 |
| 3.83 | 45.96 | 33.08 | 0.86 | 0.06 | 1.21 |
| 3.71 | 45.19 | 33.35 | 0.66 | 0.03 | 1.44 |
| 1.75 | 37.79 | 24.64 | 2.58 | 0.12 | 1.42 |
