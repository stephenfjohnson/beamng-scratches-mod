# baseline - 20261114-171844_baseline_candidate-vulkan-cold_r2

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.01 s - 319 frames, 79.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4080 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4080

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.014 |
| whole frame, ms | 12.638 (p50) | 14.817 | 17.792 |
| all GE Lua, ms | | 1.338 | 3.736 |
| physics + vehicle Lua, ms | | 0.138 | 0.198 |
| render, ms | | 2.537 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.698 us per contact, 4.916 ms total, worst frame 0.592 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.44 | 17.79 | 0.01 | 1.12 | 0.19 | 2.36 |
| 0.27 | 17.33 | 0.01 | 3.74 | 0.12 | 2.47 |
| 1.77 | 16.52 | 0.01 | 1.19 | 0.09 | 2.37 |
| 0.56 | 16.44 | 0.01 | 1.01 | 0.11 | 2.48 |
| 3.26 | 16.42 | 0.01 | 1.21 | 0.06 | 1.66 |
