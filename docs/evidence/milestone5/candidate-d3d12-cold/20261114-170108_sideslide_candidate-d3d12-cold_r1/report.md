# sideslide - 20261114-170108_sideslide_candidate-d3d12-cold_r1

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.241 s - 141 frames, 27.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.16)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1029 | 323 | 77 | 69 | 134 | 82 | 55 | 0.0% | 0 | 12 |

Rejected contacts: Wheel 536, BelowThresh 168, NormalForce 2

Body materials: METAL 231, PLASTIC 92

Surfaces: ASPHALT 323

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 21.929 | 56.029 | 68.761 |
| whole frame, ms | 32.132 (p50) | 71.565 | 91.909 |
| all GE Lua, ms | | 59.089 | 70.605 |
| physics + vehicle Lua, ms | | 9.423 | 13.643 |
| render, ms | | 3.774 | |

- Painter frames over 4 ms: 70; worst flush (project + bake) 68.694 ms, worst composite 0.191 ms.
- Detector: 3.576 us per contact, 8.469 ms total, worst frame 0.92 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.81 | 91.91 | 58.69 | 1.91 | 0.15 | 3.26 |
| 2.54 | 87.10 | 60.32 | 1.16 | 9.42 | 2.12 |
| 1.23 | 80.89 | 68.76 | 1.44 | 0.69 | 2.95 |
| 2.34 | 77.66 | 57.54 | 33.38 | 0.10 | 2.84 |
| 3.09 | 77.12 | 54.52 | 17.51 | 0.14 | 2.85 |
