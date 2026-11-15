# roofdrop - 20261114-182008_roofdrop_resumed-half-b1-fast-cold-v2_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: True after 5.293 s - 463 frames, 87.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1245 | 52 | 52 | 0 | 51 | 21 | 47 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 712, BelowThresh 481

Body materials: METAL 51, PLASTIC 1

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.169 | 3.187 | 32.397 |
| whole frame, ms | 11.043 (p50) | 13.858 | 41.96 |
| all GE Lua, ms | | 3.98 | 33.597 |
| physics + vehicle Lua, ms | | 0.072 | 0.149 |
| render, ms | | 2.133 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 32.371 ms, worst composite 0.067 ms.
- Detector: 1.545 us per contact, 4.54 ms total, worst frame 0.714 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.48 | 41.96 | 30.24 | 0.95 | 0.05 | 2.18 |
| 0.53 | 41.57 | 32.40 | 1.48 | 0.12 | 2.44 |
| 0.80 | 41.31 | 30.25 | 1.06 | 0.05 | 1.74 |
| 1.18 | 40.75 | 32.37 | 0.89 | 0.07 | 1.46 |
| 1.39 | 40.53 | 28.41 | 0.93 | 0.08 | 1.97 |
