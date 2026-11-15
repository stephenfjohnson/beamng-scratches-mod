# baseline - 20261114-192105_baseline_resumed-control-v2-disabled-cold_r3

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.005 s - 361 frames, 89.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4796 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4796

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.007 | 0.026 |
| whole frame, ms | 11.175 (p50) | 12.149 | 15.391 |
| all GE Lua, ms | | 0.993 | 1.255 |
| physics + vehicle Lua, ms | | 0.093 | 0.154 |
| render, ms | | 2.246 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.406 us per contact, 3.02 ms total, worst frame 0.079 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.34 | 15.39 | 0.01 | 0.71 | 0.07 | 2.02 |
| 0.02 | 14.67 | 0.01 | 1.00 | 0.14 | 6.02 |
| 1.96 | 14.66 | 0.01 | 0.87 | 0.05 | 2.25 |
| 1.65 | 14.33 | 0.01 | 0.74 | 0.03 | 3.28 |
| 1.62 | 13.51 | 0.01 | 0.80 | 0.05 | 2.72 |
