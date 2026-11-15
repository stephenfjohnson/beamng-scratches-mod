# sideslide - 20261114-165922_sideslide_candidate-d3d12-disabled-cold_r3

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

_on its side, sliding along the ground at 14 m/s - one long scrape_

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.199 s - 386 frames, 85.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3182 | 703 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 1720, BelowThresh 757, NormalForce 2

Body materials: METAL 522, PLASTIC 181

Surfaces: ASPHALT 703

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.009 | 0.011 | 0.07 |
| whole frame, ms | 10.782 (p50) | 16.494 | 49.395 |
| all GE Lua, ms | | 3.586 | 4.636 |
| physics + vehicle Lua, ms | | 0.135 | 0.299 |
| render, ms | | 3.107 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.53 us per contact, 6.968 ms total, worst frame 0.11 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.52 | 49.39 | 0.01 | 1.49 | 0.15 | 2.60 |
| 2.53 | 27.69 | 0.01 | 4.60 | 0.12 | 2.38 |
| 1.48 | 23.94 | 0.01 | 4.53 | 0.09 | 2.54 |
| 3.38 | 22.46 | 0.01 | 4.19 | 0.08 | 2.56 |
| 3.18 | 21.91 | 0.01 | 4.13 | 0.10 | 3.01 |
