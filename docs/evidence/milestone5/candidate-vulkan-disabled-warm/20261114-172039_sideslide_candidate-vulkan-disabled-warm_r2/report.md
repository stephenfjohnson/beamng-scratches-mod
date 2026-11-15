# sideslide - 20261114-172039_sideslide_candidate-vulkan-disabled-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.129 s - 348 frames, 84.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.15)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3169 | 769 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1666, BelowThresh 731, NormalForce 3

Body materials: METAL 579, PLASTIC 190

Surfaces: ASPHALT 769

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.012 | 0.022 |
| whole frame, ms | 11.746 (p50) | 13.886 | 28.71 |
| all GE Lua, ms | | 1.403 | 4.396 |
| physics + vehicle Lua, ms | | 0.116 | 0.286 |
| render, ms | | 2.655 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.43 us per contact, 6.229 ms total, worst frame 0.151 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.06 | 28.71 | 0.01 | 1.25 | 0.06 | 2.58 |
| 3.71 | 25.04 | 0.01 | 2.68 | 0.08 | 2.90 |
| 3.91 | 24.20 | 0.01 | 1.02 | 0.05 | 2.81 |
| 3.70 | 17.59 | 0.01 | 1.18 | 0.04 | 1.66 |
| 1.82 | 15.87 | 0.01 | 0.91 | 0.06 | 1.41 |
