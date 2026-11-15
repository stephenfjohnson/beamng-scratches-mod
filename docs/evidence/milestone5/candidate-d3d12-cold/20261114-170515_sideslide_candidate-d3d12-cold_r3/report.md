# sideslide - 20261114-170515_sideslide_candidate-d3d12-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.216 s - 142 frames, 26.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 974 | 320 | 105 | 61 | 160 | 78 | 61 | 0.0% | 0 | 14 |

Rejected contacts: Wheel 510, BelowThresh 142, NormalForce 2

Body materials: METAL 232, PLASTIC 88

Surfaces: ASPHALT 320

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 22.569 | 54.994 | 60.843 |
| whole frame, ms | 34.207 (p50) | 69.397 | 82.409 |
| all GE Lua, ms | | 57.081 | 62.476 |
| physics + vehicle Lua, ms | | 4.306 | 12.623 |
| render, ms | | 3.576 | |

- Painter frames over 4 ms: 77; worst flush (project + bake) 60.784 ms, worst composite 0.267 ms.
- Detector: 4.196 us per contact, 11.828 ms total, worst frame 1.971 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.01 | 82.41 | 54.99 | 1.83 | 0.84 | 2.89 |
| 1.43 | 76.35 | 60.84 | 1.25 | 4.31 | 2.62 |
| 3.43 | 75.75 | 56.44 | 35.63 | 0.16 | 2.67 |
| 0.83 | 73.27 | 53.44 | 57.75 | 0.11 | 3.32 |
| 0.42 | 72.71 | 59.33 | 57.08 | 0.10 | 2.37 |
