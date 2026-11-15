# roofdrop - 20261114-164505_roofdrop_original-d3d12-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 4.957 s - 401 frames, 78.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1020 | 52 | 52 | 0 | 55 | 18 | 17 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 625, BelowThresh 343

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.651 | 13.851 | 49.179 |
| whole frame, ms | 10.746 (p50) | 26.368 | 82.654 |
| all GE Lua, ms | | 15.209 | 50.578 |
| physics + vehicle Lua, ms | | 0.121 | 0.887 |
| render, ms | | 3.064 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 36.265 ms, worst composite 0.121 ms.
- Detector: 2.165 us per contact, 5.487 ms total, worst frame 1.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.08 | 82.65 | 0.01 | 3.14 | 0.05 | 1.84 |
| 0.54 | 60.75 | 49.18 | 23.76 | 0.18 | 3.01 |
| 0.96 | 54.83 | 43.93 | 43.60 | 0.09 | 2.56 |
| 0.95 | 54.78 | 42.41 | 14.70 | 0.10 | 3.61 |
| 1.37 | 53.58 | 43.06 | 16.31 | 0.08 | 3.00 |
