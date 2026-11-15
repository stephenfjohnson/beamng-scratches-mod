# sideslide - 20261114-171052_sideslide_candidate-reflections-off_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 7.794 s - 399 frames, 51.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.152)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3898 | 265 | 103 | 42 | 205 | 90 | 64 | 0.0% | 0 | 12 |

Rejected contacts: BelowThresh 1888, Wheel 1743, NormalForce 2

Body materials: METAL 190, PLASTIC 75

Surfaces: ASPHALT 265

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.562 | 44.347 | 58.81 |
| whole frame, ms | 11.605 (p50) | 57.625 | 80.485 |
| all GE Lua, ms | | 46.241 | 60.191 |
| physics + vehicle Lua, ms | | 2.433 | 11.978 |
| render, ms | | 3.261 | |

- Painter frames over 4 ms: 87; worst flush (project + bake) 58.773 ms, worst composite 0.141 ms.
- Detector: 1.405 us per contact, 10.934 ms total, worst frame 0.727 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.65 | 80.49 | 55.85 | 42.84 | 0.07 | 3.45 |
| 3.20 | 78.65 | 58.22 | 32.76 | 0.07 | 2.36 |
| 2.92 | 77.93 | 58.81 | 26.34 | 0.12 | 2.60 |
| 2.45 | 71.09 | 50.80 | 13.86 | 0.08 | 1.97 |
| 3.42 | 69.26 | 48.42 | 10.50 | 2.58 | 2.68 |
