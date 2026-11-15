# sideslide - 20261114-164339_sideslide_original-d3d12-cold_r2

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end`

Settled: True after 4.766 s - 132 frames, 28.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.165)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 919 | 276 | 108 | 59 | 189 | 85 | 59 | 0.0% | 0 | 13 |

Rejected contacts: Wheel 418, BelowThresh 225

Body materials: METAL 204, PLASTIC 72

Surfaces: ASPHALT 276

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 22.052 | 50.06 | 58.783 |
| whole frame, ms | 40.589 (p50) | 61.509 | 122.885 |
| all GE Lua, ms | | 51.196 | 59.73 |
| physics + vehicle Lua, ms | | 8.262 | 11.312 |
| render, ms | | 2.767 | |

- Painter frames over 4 ms: 79; worst flush (project + bake) 58.715 ms, worst composite 0.113 ms.
- Detector: 2.259 us per contact, 5.231 ms total, worst frame 0.838 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.39 | 122.89 | 50.06 | 46.23 | 0.11 | 1.45 |
| 0.31 | 80.84 | 0.01 | 1.32 | 0.06 | 2.35 |
| 0.62 | 73.79 | 55.20 | 0.98 | 4.79 | 2.53 |
| 2.19 | 72.17 | 55.20 | 42.28 | 0.08 | 2.77 |
| 0.41 | 68.17 | 54.21 | 40.50 | 0.07 | 2.63 |
