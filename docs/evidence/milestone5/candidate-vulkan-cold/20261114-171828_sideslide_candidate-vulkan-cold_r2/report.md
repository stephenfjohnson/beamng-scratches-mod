# sideslide - 20261114-171828_sideslide_candidate-vulkan-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: True after 4.94 s - 394 frames, 68.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.173)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2598 | 620 | 130 | 120 | 140 | 95 | 78 | 0.0% | 0 | 16 |

Rejected contacts: Wheel 1220, BelowThresh 756, NormalForce 2

Body materials: METAL 442, PLASTIC 178

Surfaces: ASPHALT 620

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.219 | 14.493 | 63.969 |
| whole frame, ms | 12.409 (p50) | 29.509 | 82.326 |
| all GE Lua, ms | | 15.644 | 65.347 |
| physics + vehicle Lua, ms | | 0.092 | 0.241 |
| render, ms | | 1.872 | |

- Painter frames over 4 ms: 86; worst flush (project + bake) 63.944 ms, worst composite 0.094 ms.
- Detector: 1.783 us per contact, 10.504 ms total, worst frame 0.691 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 82.33 | 63.97 | 1.29 | 0.10 | 1.42 |
| 0.39 | 72.58 | 61.64 | 1.10 | 0.05 | 1.37 |
| 1.62 | 56.16 | 43.54 | 1.32 | 0.10 | 2.50 |
| 0.79 | 54.78 | 43.10 | 0.85 | 0.05 | 1.41 |
| 3.26 | 52.64 | 40.44 | 0.90 | 0.04 | 1.37 |
