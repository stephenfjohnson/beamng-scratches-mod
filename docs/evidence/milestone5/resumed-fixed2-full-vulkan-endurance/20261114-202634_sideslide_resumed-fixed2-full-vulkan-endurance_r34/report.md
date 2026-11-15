# sideslide - 20261114-202634_sideslide_resumed-fixed2-full-vulkan-endurance_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.909 s - 396 frames, 66.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.169)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3291 | 428 | 105 | 97 | 161 | 95 | 127 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1487, BelowThresh 1372, NormalForce 4

Body materials: METAL 316, PLASTIC 112

Surfaces: ASPHALT 428

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.893 | 18.758 | 34.977 |
| whole frame, ms | 12.773 (p50) | 29.674 | 46.949 |
| all GE Lua, ms | | 19.787 | 35.892 |
| physics + vehicle Lua, ms | | 0.109 | 0.767 |
| render, ms | | 2.066 | |

- Painter frames over 4 ms: 55; worst flush (project + bake) 34.942 ms, worst composite 0.093 ms.
- Detector: 1.497 us per contact, 10.99 ms total, worst frame 2.068 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.95 | 34.98 | 0.93 | 0.06 | 1.46 |
| 4.15 | 46.28 | 34.05 | 0.92 | 0.06 | 1.43 |
| 0.23 | 38.75 | 31.87 | 0.80 | 0.77 | 1.39 |
| 1.98 | 38.06 | 22.65 | 3.53 | 0.08 | 1.92 |
| 1.03 | 33.87 | 21.69 | 2.19 | 0.05 | 1.36 |
