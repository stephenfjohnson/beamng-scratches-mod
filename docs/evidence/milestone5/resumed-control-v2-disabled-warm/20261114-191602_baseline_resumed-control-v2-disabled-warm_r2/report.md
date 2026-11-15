# baseline - 20261114-191602_baseline_resumed-control-v2-disabled-warm_r2

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.006 s - 353 frames, 87.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4694 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4694

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.032 |
| whole frame, ms | 11.338 (p50) | 12.872 | 16.875 |
| all GE Lua, ms | | 1.047 | 2.802 |
| physics + vehicle Lua, ms | | 0.106 | 0.19 |
| render, ms | | 2.455 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.417 us per contact, 3.209 ms total, worst frame 0.036 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.39 | 16.88 | 0.01 | 0.70 | 0.03 | 2.02 |
| 0.69 | 15.61 | 0.01 | 0.92 | 0.11 | 3.79 |
| 0.15 | 14.84 | 0.01 | 0.83 | 0.09 | 2.77 |
| 0.53 | 13.97 | 0.01 | 1.02 | 0.10 | 2.85 |
| 1.13 | 13.74 | 0.01 | 0.77 | 0.06 | 3.29 |
