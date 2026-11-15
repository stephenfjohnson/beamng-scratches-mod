# roofdrop - 20261114-182146_roofdrop_resumed-half-b1-fast-cold-v2_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(2); scratches_paint.setLayerBudget(12); scratches_paint.setCoverageCoalescing(true)`

Settled: True after 4.713 s - 417 frames, 88.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1102 | 48 | 48 | 0 | 52 | 18 | 47 | 0.0% | 0 | 1 |

Rejected contacts: PartExcluded 657, BelowThresh 397

Body materials: METAL 46, PLASTIC 2

Surfaces: ASPHALT 48

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.229 | 3.069 | 33.706 |
| whole frame, ms | 10.835 (p50) | 13.468 | 43.593 |
| all GE Lua, ms | | 3.958 | 34.606 |
| physics + vehicle Lua, ms | | 0.074 | 0.181 |
| render, ms | | 2.029 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 33.676 ms, worst composite 0.086 ms.
- Detector: 1.36 us per contact, 3.724 ms total, worst frame 0.512 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.81 | 43.59 | 31.24 | 1.07 | 0.10 | 1.96 |
| 0.52 | 41.01 | 30.67 | 1.03 | 0.09 | 1.64 |
| 3.75 | 41.01 | 29.17 | 0.80 | 0.03 | 1.68 |
| 2.48 | 40.72 | 29.77 | 0.76 | 0.04 | 1.58 |
| 1.84 | 40.59 | 29.30 | 0.77 | 0.07 | 1.55 |
