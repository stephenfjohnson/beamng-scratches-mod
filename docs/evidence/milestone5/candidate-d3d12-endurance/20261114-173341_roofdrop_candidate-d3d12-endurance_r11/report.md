# roofdrop - 20261114-173341_roofdrop_candidate-d3d12-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: True after 5.308 s - 453 frames, 83.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1127 | 50 | 50 | 0 | 53 | 17 | 16 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 682, BelowThresh 395

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.534 | 8.224 | 37.365 |
| whole frame, ms | 11.11 (p50) | 17.202 | 47.981 |
| all GE Lua, ms | | 9.268 | 38.154 |
| physics + vehicle Lua, ms | | 0.079 | 0.184 |
| render, ms | | 2.302 | |

- Painter frames over 4 ms: 28; worst flush (project + bake) 35.076 ms, worst composite 0.127 ms.
- Detector: 1.307 us per contact, 3.775 ms total, worst frame 0.46 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.95 | 47.98 | 37.13 | 30.92 | 0.06 | 2.42 |
| 1.56 | 46.57 | 35.11 | 0.87 | 0.04 | 1.97 |
| 0.74 | 44.89 | 37.36 | 33.26 | 0.05 | 1.97 |
| 1.57 | 44.74 | 36.46 | 36.12 | 0.07 | 1.84 |
| 0.53 | 44.63 | 32.58 | 0.84 | 0.04 | 2.08 |
