# sideslide - 20261114-202722_sideslide_resumed-fixed2-full-vulkan-endurance_r37

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.288 s - 254 frames, 59.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2344 | 437 | 89 | 100 | 127 | 98 | 118 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1283, BelowThresh 623, NormalForce 1

Body materials: METAL 309, PLASTIC 128

Surfaces: ASPHALT 437

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.464 | 19.059 | 34.745 |
| whole frame, ms | 14.332 (p50) | 31.5 | 48.046 |
| all GE Lua, ms | | 20.505 | 35.666 |
| physics + vehicle Lua, ms | | 0.103 | 0.195 |
| render, ms | | 1.921 | |

- Painter frames over 4 ms: 61; worst flush (project + bake) 34.713 ms, worst composite 0.173 ms.
- Detector: 1.542 us per contact, 6.984 ms total, worst frame 0.413 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 48.05 | 34.75 | 1.01 | 0.07 | 1.41 |
| 3.71 | 45.82 | 32.80 | 1.07 | 0.06 | 1.64 |
| 0.34 | 35.58 | 18.26 | 4.51 | 0.06 | 2.29 |
| 0.64 | 35.14 | 18.23 | 3.68 | 0.09 | 1.64 |
| 2.19 | 35.09 | 17.64 | 1.49 | 0.06 | 1.69 |
