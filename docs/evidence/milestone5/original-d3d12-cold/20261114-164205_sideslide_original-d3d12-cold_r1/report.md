# sideslide - 20261114-164205_sideslide_original-d3d12-cold_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 4.687 s - 172 frames, 31.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1132 | 347 | 89 | 77 | 158 | 92 | 65 | 0.0% | 0 | 14 |

Rejected contacts: Wheel 526, BelowThresh 259

Body materials: METAL 253, PLASTIC 94

Surfaces: ASPHALT 347

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 18.939 | 49.989 | 59.075 |
| whole frame, ms | 26.201 (p50) | 65.75 | 91.606 |
| all GE Lua, ms | | 51.026 | 60.515 |
| physics + vehicle Lua, ms | | 8.306 | 14.418 |
| render, ms | | 2.828 | |

- Painter frames over 4 ms: 85; worst flush (project + bake) 59.023 ms, worst composite 0.098 ms.
- Detector: 2.693 us per contact, 7.287 ms total, worst frame 0.578 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.24 | 91.61 | 53.67 | 1.44 | 1.72 | 2.34 |
| 2.56 | 72.40 | 55.18 | 38.10 | 0.08 | 2.22 |
| 3.26 | 72.07 | 54.34 | 43.52 | 0.09 | 1.98 |
| 1.46 | 71.59 | 59.07 | 1.20 | 3.71 | 1.74 |
| 0.81 | 70.76 | 38.00 | 1.34 | 0.16 | 2.49 |
