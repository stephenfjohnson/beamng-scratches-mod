# roofdrop - 20261114-181400_roofdrop_resumed-half-b3-coalesced_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setCoverageCoalescing(true)`

Settled: True after 7.677 s - 664 frames, 86.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1916 | 60 | 60 | 0 | 59 | 17 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1085, BelowThresh 771

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.68 | 0.039 | 38.464 |
| whole frame, ms | 11.318 (p50) | 13.082 | 49.961 |
| all GE Lua, ms | | 1.826 | 39.515 |
| physics + vehicle Lua, ms | | 0.073 | 0.195 |
| render, ms | | 2.286 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 38.397 ms, worst composite 0.146 ms.
- Detector: 1.317 us per contact, 5.513 ms total, worst frame 0.345 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.73 | 49.96 | 38.46 | 1.32 | 0.06 | 1.89 |
| 1.97 | 43.73 | 33.33 | 0.97 | 0.04 | 1.84 |
| 2.42 | 43.59 | 31.87 | 0.98 | 0.05 | 1.88 |
| 2.63 | 42.94 | 32.70 | 1.21 | 0.05 | 1.86 |
| 1.56 | 42.10 | 30.93 | 1.18 | 0.05 | 2.36 |
