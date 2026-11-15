# baseline - 20261114-193559_baseline_resumed-control-v2-disabled-vulkan-cold_r3

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.007 s - 328 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4248 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4248

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.034 |
| whole frame, ms | 12.255 (p50) | 13.839 | 17.758 |
| all GE Lua, ms | | 1.151 | 1.832 |
| physics + vehicle Lua, ms | | 0.107 | 0.207 |
| render, ms | | 2.053 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.421 us per contact, 2.801 ms total, worst frame 0.112 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.90 | 17.76 | 0.01 | 0.83 | 0.04 | 1.53 |
| 1.24 | 16.76 | 0.01 | 0.83 | 0.04 | 1.81 |
| 0.83 | 16.38 | 0.02 | 1.00 | 0.05 | 2.58 |
| 0.02 | 16.06 | 0.01 | 0.96 | 0.12 | 4.00 |
| 2.78 | 15.91 | 0.01 | 1.55 | 0.05 | 1.65 |
