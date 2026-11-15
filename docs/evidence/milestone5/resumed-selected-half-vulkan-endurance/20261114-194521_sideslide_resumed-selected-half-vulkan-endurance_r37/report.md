# sideslide - 20261114-194521_sideslide_resumed-selected-half-vulkan-endurance_r37

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.526 s - 336 frames, 74.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2656 | 560 | 110 | 122 | 132 | 101 | 154 | 0.0% | 0 | 0 |

Rejected contacts: Wheel 1322, BelowThresh 774

Body materials: METAL 419, PLASTIC 141

Surfaces: ASPHALT 560

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.63 | 35.054 | 40.919 |
| whole frame, ms | 10.575 (p50) | 44.143 | 53.933 |
| all GE Lua, ms | | 36.049 | 42.261 |
| physics + vehicle Lua, ms | | 0.078 | 0.379 |
| render, ms | | 1.622 | |

- Painter frames over 4 ms: 44; worst flush (project + bake) 40.893 ms, worst composite 0.152 ms.
- Detector: 1.377 us per contact, 7.251 ms total, worst frame 0.417 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 53.93 | 40.92 | 0.91 | 0.06 | 1.52 |
| 2.54 | 50.91 | 39.88 | 1.32 | 0.05 | 1.28 |
| 2.35 | 49.55 | 37.17 | 1.42 | 0.04 | 1.26 |
| 2.64 | 49.53 | 36.88 | 1.55 | 0.05 | 1.35 |
| 2.13 | 49.23 | 37.36 | 1.14 | 0.04 | 1.20 |
