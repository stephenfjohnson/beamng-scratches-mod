# roofdrop - 20261114-164346_roofdrop_original-d3d12-cold_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_dropped upside down from about 1 m - roof impacts_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 5.131 s - 435 frames, 73.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1051 | 52 | 52 | 0 | 51 | 16 | 15 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 647, BelowThresh 352

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.854 | 6.976 | 652.998 |
| whole frame, ms | 10.787 (p50) | 24.816 | 663.866 |
| all GE Lua, ms | | 7.983 | 654.543 |
| physics + vehicle Lua, ms | | 0.094 | 0.348 |
| render, ms | | 2.829 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 652.946 ms, worst composite 0.125 ms.
- Detector: 1.954 us per contact, 4.923 ms total, worst frame 0.565 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.85 | 663.87 | 653.00 | 1.46 | 0.12 | 2.51 |
| 0.95 | 55.47 | 39.91 | 18.36 | 0.07 | 2.51 |
| 2.28 | 52.48 | 40.01 | 33.89 | 0.07 | 1.95 |
| 1.54 | 48.55 | 36.85 | 0.97 | 0.06 | 1.69 |
| 1.56 | 47.02 | 38.40 | 37.90 | 0.07 | 1.75 |
