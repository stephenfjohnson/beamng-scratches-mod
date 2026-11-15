# sideslide - 20261114-172102_sideslide_candidate-vulkan-disabled-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.137 s - 339 frames, 81.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.15)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3001 | 746 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1587, BelowThresh 664, NormalForce 4

Body materials: METAL 563, PLASTIC 183

Surfaces: ASPHALT 746

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.014 |
| whole frame, ms | 11.997 (p50) | 14.465 | 82.701 |
| all GE Lua, ms | | 1.46 | 3.396 |
| physics + vehicle Lua, ms | | 0.118 | 0.293 |
| render, ms | | 2.909 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.492 us per contact, 6.233 ms total, worst frame 0.166 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.29 | 82.70 | 0.01 | 3.40 | 0.06 | 1.93 |
| 3.89 | 17.18 | 0.01 | 0.89 | 0.04 | 2.88 |
| 1.31 | 16.70 | 0.01 | 1.38 | 0.09 | 2.49 |
| 1.44 | 16.25 | 0.01 | 1.23 | 0.08 | 2.06 |
| 2.84 | 16.09 | 0.01 | 0.99 | 0.12 | 2.81 |
