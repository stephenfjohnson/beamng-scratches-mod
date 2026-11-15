# baseline - 20261114-191524_baseline_resumed-control-v2-disabled-warm_r1

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.01 s - 355 frames, 88.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4716 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4716

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.043 |
| whole frame, ms | 11.312 (p50) | 12.533 | 15.9 |
| all GE Lua, ms | | 1.005 | 1.481 |
| physics + vehicle Lua, ms | | 0.104 | 0.217 |
| render, ms | | 2.304 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.427 us per contact, 3.259 ms total, worst frame 0.099 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.63 | 15.90 | 0.01 | 0.80 | 0.08 | 1.91 |
| 0.24 | 15.61 | 0.01 | 0.79 | 0.07 | 2.05 |
| 0.02 | 15.41 | 0.01 | 0.74 | 0.11 | 5.38 |
| 3.21 | 14.31 | 0.01 | 0.89 | 0.05 | 1.82 |
| 0.70 | 13.70 | 0.01 | 0.79 | 0.04 | 1.89 |
