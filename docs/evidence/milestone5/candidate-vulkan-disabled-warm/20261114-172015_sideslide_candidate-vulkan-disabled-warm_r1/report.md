# sideslide - 20261114-172015_sideslide_candidate-vulkan-disabled-warm_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.198 s - 357 frames, 84.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2773 | 774 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1297, BelowThresh 699, NormalForce 3

Body materials: METAL 581, PLASTIC 193

Surfaces: ASPHALT 774

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.03 |
| whole frame, ms | 11.763 (p50) | 13.774 | 18.349 |
| all GE Lua, ms | | 1.338 | 3.325 |
| physics + vehicle Lua, ms | | 0.1 | 0.15 |
| render, ms | | 2.312 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.462 us per contact, 5.397 ms total, worst frame 0.091 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.76 | 18.35 | 0.01 | 1.05 | 0.04 | 2.04 |
| 2.11 | 17.62 | 0.01 | 1.15 | 0.07 | 1.94 |
| 2.59 | 17.18 | 0.01 | 1.02 | 0.07 | 1.60 |
| 0.91 | 16.03 | 0.01 | 0.81 | 0.05 | 1.95 |
| 0.23 | 15.52 | 0.01 | 0.93 | 0.09 | 2.29 |
