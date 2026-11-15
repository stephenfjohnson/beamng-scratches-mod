# roofdrop - 20261114-173439_roofdrop_candidate-d3d12-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.099 s - 440 frames, 83.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1069 | 47 | 47 | 0 | 51 | 16 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 642, BelowThresh 380

Body materials: METAL 45, PLASTIC 2

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.483 | 10.961 | 39.024 |
| whole frame, ms | 11.112 (p50) | 18.001 | 46.444 |
| all GE Lua, ms | | 11.797 | 39.908 |
| physics + vehicle Lua, ms | | 0.08 | 0.328 |
| render, ms | | 2.321 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 32.512 ms, worst composite 0.076 ms.
- Detector: 1.275 us per contact, 3.632 ms total, worst frame 0.484 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.72 | 46.44 | 31.73 | 0.87 | 0.05 | 2.59 |
| 0.75 | 45.60 | 39.02 | 36.68 | 0.05 | 1.60 |
| 0.73 | 45.10 | 35.91 | 32.85 | 0.06 | 2.40 |
| 1.55 | 43.51 | 32.56 | 0.93 | 0.06 | 1.64 |
| 2.26 | 43.27 | 30.44 | 0.90 | 0.05 | 2.11 |
