# roofdrop - 20261114-171722_roofdrop_candidate-vulkan-cold_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.962 s - 366 frames, 73.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 888 | 54 | 53 | 0 | 57 | 18 | 16 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 525, BelowThresh 309

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.511 | 5.057 | 63.713 |
| whole frame, ms | 12.456 (p50) | 21.983 | 86.415 |
| all GE Lua, ms | | 5.982 | 64.539 |
| physics + vehicle Lua, ms | | 0.092 | 0.847 |
| render, ms | | 1.825 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 63.689 ms, worst composite 0.052 ms.
- Detector: 1.752 us per contact, 4.049 ms total, worst frame 0.76 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 86.42 | 63.71 | 0.86 | 0.10 | 1.68 |
| 0.74 | 67.41 | 50.42 | 0.93 | 0.05 | 1.39 |
| 0.95 | 61.15 | 45.06 | 0.77 | 0.04 | 2.29 |
| 1.57 | 51.52 | 38.85 | 0.94 | 0.06 | 1.34 |
| 1.37 | 50.88 | 36.79 | 0.99 | 0.04 | 1.47 |
