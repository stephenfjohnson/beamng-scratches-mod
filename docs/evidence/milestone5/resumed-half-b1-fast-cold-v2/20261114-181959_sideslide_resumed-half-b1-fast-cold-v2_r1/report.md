# sideslide - 20261114-181959_sideslide_resumed-half-b1-fast-cold-v2_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: True after 4.133 s - 559 frames, 84.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.149)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 6227 | 940 | 71 | 156 | 86 | 74 | 474 | 0.0% | 0 | 47 |

Rejected contacts: Wheel 3595, BelowThresh 1686, NormalForce 6

Body materials: METAL 711, PLASTIC 229

Surfaces: ASPHALT 940

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.596 | 28.572 | 34.454 |
| whole frame, ms | 9.729 (p50) | 37.27 | 46.895 |
| all GE Lua, ms | | 29.799 | 35.238 |
| physics + vehicle Lua, ms | | 0.086 | 0.148 |
| render, ms | | 2.378 | |

- Painter frames over 4 ms: 65; worst flush (project + bake) 34.422 ms, worst composite 0.203 ms.
- Detector: 1.206 us per contact, 13.561 ms total, worst frame 0.624 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.90 | 33.68 | 0.89 | 0.10 | 3.42 |
| 4.83 | 44.14 | 34.45 | 1.66 | 0.03 | 1.80 |
| 3.35 | 42.38 | 32.57 | 0.73 | 0.04 | 1.47 |
| 5.60 | 42.35 | 32.12 | 2.11 | 0.04 | 1.74 |
| 3.89 | 41.99 | 30.92 | 2.09 | 0.05 | 1.64 |
