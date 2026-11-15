# sideslide - 20261114-171947_sideslide_candidate-vulkan-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.225 s - 325 frames, 59.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.176)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2521 | 622 | 99 | 128 | 113 | 87 | 77 | 0.0% | 0 | 16 |

Rejected contacts: Wheel 1340, BelowThresh 557, NormalForce 2

Body materials: METAL 463, PLASTIC 159

Surfaces: ASPHALT 622

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.763 | 30.829 | 53.324 |
| whole frame, ms | 12.935 (p50) | 46.61 | 575.041 |
| all GE Lua, ms | | 31.572 | 54.489 |
| physics + vehicle Lua, ms | | 0.118 | 1.083 |
| render, ms | | 2.172 | |

- Painter frames over 4 ms: 87; worst flush (project + bake) 53.285 ms, worst composite 0.094 ms.
- Detector: 1.983 us per contact, 10.716 ms total, worst frame 0.957 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.07 | 575.04 | 5.07 | 6.33 | 0.12 | 1.69 |
| 0.39 | 64.29 | 53.32 | 1.26 | 0.07 | 1.63 |
| 0.18 | 59.40 | 47.30 | 0.95 | 0.08 | 2.55 |
| 1.83 | 54.05 | 42.78 | 1.05 | 0.06 | 1.26 |
| 1.42 | 53.11 | 41.00 | 0.92 | 0.05 | 1.20 |
