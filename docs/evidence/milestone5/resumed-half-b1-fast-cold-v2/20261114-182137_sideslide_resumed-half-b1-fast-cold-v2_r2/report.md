# sideslide - 20261114-182137_sideslide_resumed-half-b1-fast-cold-v2_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: True after 4.096 s - 564 frames, 86.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.139)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 6508 | 995 | 73 | 162 | 81 | 75 | 479 | 0.0% | 0 | 47 |

Rejected contacts: Wheel 3849, BelowThresh 1659, NormalForce 5

Body materials: METAL 747, PLASTIC 248

Surfaces: ASPHALT 995

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.585 | 29.921 | 36.837 |
| whole frame, ms | 9.399 (p50) | 38.867 | 46.255 |
| all GE Lua, ms | | 30.804 | 38.306 |
| physics + vehicle Lua, ms | | 0.079 | 0.114 |
| render, ms | | 2.128 | |

- Painter frames over 4 ms: 58; worst flush (project + bake) 36.81 ms, worst composite 0.129 ms.
- Detector: 1.166 us per contact, 14.008 ms total, worst frame 0.681 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.26 | 36.84 | 1.04 | 0.10 | 1.82 |
| 5.25 | 42.67 | 33.01 | 1.69 | 0.04 | 1.66 |
| 1.82 | 42.56 | 31.98 | 1.74 | 0.05 | 2.13 |
| 3.63 | 42.24 | 31.76 | 1.77 | 0.04 | 1.60 |
| 5.71 | 41.81 | 32.15 | 2.00 | 0.03 | 1.68 |
