# roofdrop - 20261114-180939_roofdrop_resumed-half-b6

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(6)`

Settled: True after 7.652 s - 663 frames, 86.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1931 | 65 | 64 | 0 | 55 | 17 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1080, BelowThresh 786

Body materials: METAL 64, PLASTIC 1

Surfaces: ASPHALT 65

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.686 | 0.011 | 37.239 |
| whole frame, ms | 11.223 (p50) | 12.982 | 48.79 |
| all GE Lua, ms | | 1.304 | 38.245 |
| physics + vehicle Lua, ms | | 0.076 | 0.409 |
| render, ms | | 2.276 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 37.214 ms, worst composite 0.093 ms.
- Detector: 1.306 us per contact, 5.706 ms total, worst frame 0.479 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 48.79 | 37.24 | 0.99 | 0.12 | 2.08 |
| 0.73 | 47.56 | 36.69 | 0.79 | 0.04 | 1.96 |
| 1.56 | 45.38 | 34.38 | 1.02 | 0.07 | 2.10 |
| 2.49 | 43.24 | 31.68 | 1.17 | 0.06 | 1.75 |
| 2.28 | 43.23 | 32.87 | 0.93 | 0.05 | 2.04 |
