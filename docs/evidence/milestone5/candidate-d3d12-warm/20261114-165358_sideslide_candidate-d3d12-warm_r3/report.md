# sideslide - 20261114-165358_sideslide_candidate-d3d12-warm_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 4.728 s - 119 frames, 24.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 775 | 256 | 114 | 43 | 225 | 77 | 60 | 0.0% | 0 | 13 |

Rejected contacts: Wheel 358, BelowThresh 161

Body materials: METAL 189, PLASTIC 67

Surfaces: ASPHALT 256

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 26.152 | 54.985 | 61.555 |
| whole frame, ms | 50.68 (p50) | 69.524 | 79.79 |
| all GE Lua, ms | | 56.187 | 62.736 |
| physics + vehicle Lua, ms | | 12.06 | 14.049 |
| render, ms | | 3.32 | |

- Painter frames over 4 ms: 77; worst flush (project + bake) 61.515 ms, worst composite 0.237 ms.
- Detector: 2.865 us per contact, 5.515 ms total, worst frame 0.857 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.74 | 79.79 | 60.26 | 43.00 | 0.12 | 2.90 |
| 3.16 | 77.56 | 59.92 | 34.33 | 0.12 | 2.81 |
| 2.58 | 77.49 | 55.88 | 29.83 | 0.11 | 3.18 |
| 2.31 | 75.34 | 56.23 | 34.55 | 0.07 | 3.39 |
| 2.04 | 75.17 | 55.21 | 34.16 | 0.08 | 2.69 |
