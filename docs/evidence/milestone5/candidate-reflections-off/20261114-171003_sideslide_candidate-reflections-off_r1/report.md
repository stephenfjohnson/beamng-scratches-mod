# sideslide - 20261114-171003_sideslide_candidate-reflections-off_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.276 s - 145 frames, 35.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.155)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1096 | 278 | 86 | 54 | 174 | 85 | 56 | 0.0% | 0 | 13 |

Rejected contacts: Wheel 569, BelowThresh 248, NormalForce 1

Body materials: METAL 196, PLASTIC 82

Surfaces: ASPHALT 278

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.279 | 45.317 | 62.784 |
| whole frame, ms | 22.091 (p50) | 55.255 | 76.279 |
| all GE Lua, ms | | 46.445 | 63.66 |
| physics + vehicle Lua, ms | | 5.942 | 8.911 |
| render, ms | | 2.296 | |

- Painter frames over 4 ms: 72; worst flush (project + bake) 62.745 ms, worst composite 0.104 ms.
- Detector: 1.722 us per contact, 4.459 ms total, worst frame 0.555 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 76.28 | 45.32 | 0.79 | 3.29 | 1.75 |
| 2.99 | 70.90 | 62.78 | 1.05 | 0.51 | 2.09 |
| 0.39 | 66.65 | 58.11 | 0.79 | 0.04 | 2.28 |
| 2.32 | 64.42 | 55.56 | 0.95 | 2.54 | 1.41 |
| 2.11 | 61.80 | 47.13 | 12.43 | 0.10 | 1.61 |
