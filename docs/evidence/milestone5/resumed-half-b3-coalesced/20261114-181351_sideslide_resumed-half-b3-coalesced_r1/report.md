# sideslide - 20261114-181351_sideslide_resumed-half-b3-coalesced_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setCoverageCoalescing(true)`

Settled: True after 4.182 s - 322 frames, 77.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2453 | 642 | 85 | 132 | 110 | 76 | 155 | 0.0% | 0 | 18 |

Rejected contacts: Wheel 1176, BelowThresh 631, NormalForce 4

Body materials: METAL 480, PLASTIC 162

Surfaces: ASPHALT 642

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.234 | 37.459 | 52.989 |
| whole frame, ms | 10.53 (p50) | 47.497 | 63.408 |
| all GE Lua, ms | | 38.558 | 53.884 |
| physics + vehicle Lua, ms | | 0.092 | 0.29 |
| render, ms | | 2.012 | |

- Painter frames over 4 ms: 124; worst flush (project + bake) 52.953 ms, worst composite 0.137 ms.
- Detector: 1.621 us per contact, 8.324 ms total, worst frame 0.376 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.38 | 63.41 | 52.99 | 0.76 | 0.04 | 1.70 |
| 1.21 | 56.39 | 45.74 | 0.88 | 0.03 | 1.73 |
| 3.68 | 54.96 | 45.21 | 0.79 | 0.04 | 1.92 |
| 3.88 | 54.80 | 44.90 | 0.89 | 0.04 | 2.25 |
| 2.04 | 54.46 | 44.75 | 0.96 | 0.06 | 1.87 |
