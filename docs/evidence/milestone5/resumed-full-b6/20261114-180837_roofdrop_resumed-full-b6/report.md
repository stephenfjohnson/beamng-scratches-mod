# roofdrop - 20261114-180837_roofdrop_resumed-full-b6

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6)`

Settled: True after 7.649 s - 633 frames, 82.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1868 | 64 | 64 | 0 | 61 | 19 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 1074, BelowThresh 730

Body materials: METAL 62, PLASTIC 2

Surfaces: ASPHALT 64

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.216 | 0.012 | 49.636 |
| whole frame, ms | 11.289 (p50) | 14.004 | 59.526 |
| all GE Lua, ms | | 1.416 | 50.88 |
| physics + vehicle Lua, ms | | 0.079 | 1.995 |
| render, ms | | 2.188 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 49.61 ms, worst composite 0.139 ms.
- Detector: 1.349 us per contact, 5.286 ms total, worst frame 0.46 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.16 | 59.53 | 49.64 | 0.83 | 0.04 | 1.95 |
| 1.36 | 51.64 | 39.81 | 0.77 | 0.04 | 1.84 |
| 0.75 | 47.33 | 39.46 | 33.17 | 0.07 | 2.08 |
| 2.28 | 44.77 | 33.30 | 0.76 | 0.04 | 1.83 |
| 0.97 | 44.08 | 33.90 | 21.47 | 0.07 | 2.47 |
