# baseline - 20261114-172005_baseline_candidate-vulkan-cold_r3

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setProjectionBudget(6)`

Settled: False after 4.001 s - 322 frames, 80.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4092 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4092

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.01 |
| whole frame, ms | 12.392 (p50) | 14.491 | 17.258 |
| all GE Lua, ms | | 1.212 | 1.417 |
| physics + vehicle Lua, ms | | 0.127 | 0.522 |
| render, ms | | 2.265 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.623 us per contact, 4.329 ms total, worst frame 0.448 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.03 | 17.26 | 0.01 | 0.85 | 0.15 | 4.44 |
| 1.35 | 15.60 | 0.00 | 0.84 | 0.05 | 1.99 |
| 0.31 | 15.37 | 0.01 | 0.87 | 0.11 | 1.72 |
| 3.28 | 15.30 | 0.01 | 0.77 | 0.04 | 2.27 |
| 3.24 | 15.20 | 0.01 | 1.00 | 0.04 | 2.13 |
