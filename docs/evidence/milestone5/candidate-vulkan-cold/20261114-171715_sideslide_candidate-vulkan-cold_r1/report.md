# sideslide - 20261114-171715_sideslide_candidate-vulkan-cold_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.206 s - 301 frames, 62.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2303 | 664 | 74 | 125 | 109 | 87 | 74 | 0.0% | 0 | 16 |

Rejected contacts: Wheel 1149, BelowThresh 489, NormalForce 1

Body materials: METAL 473, PLASTIC 191

Surfaces: ASPHALT 664

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.827 | 19.99 | 60.381 |
| whole frame, ms | 14.406 (p50) | 38.403 | 71.28 |
| all GE Lua, ms | | 21.092 | 61.205 |
| physics + vehicle Lua, ms | | 0.113 | 1.408 |
| render, ms | | 2.006 | |

- Painter frames over 4 ms: 87; worst flush (project + bake) 60.358 ms, worst composite 0.134 ms.
- Detector: 2.196 us per contact, 11.066 ms total, worst frame 1.169 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.39 | 71.28 | 60.38 | 0.75 | 0.04 | 1.73 |
| 0.19 | 70.82 | 58.35 | 1.07 | 0.08 | 1.71 |
| 0.60 | 57.54 | 45.23 | 1.02 | 0.05 | 1.55 |
| 0.81 | 54.00 | 40.90 | 1.26 | 0.09 | 1.29 |
| 1.01 | 53.52 | 42.07 | 0.81 | 0.04 | 1.16 |
