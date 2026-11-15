# baseline - 20261114-193306_baseline_resumed-control-v2-disabled-vulkan-cold_r1

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.003 s - 326 frames, 81.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4132 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4132

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.029 |
| whole frame, ms | 12.274 (p50) | 13.855 | 18.79 |
| all GE Lua, ms | | 1.085 | 2.362 |
| physics + vehicle Lua, ms | | 0.094 | 0.163 |
| render, ms | | 1.9 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.42 us per contact, 2.748 ms total, worst frame 0.094 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.22 | 18.79 | 0.01 | 0.96 | 0.05 | 1.39 |
| 1.20 | 15.37 | 0.01 | 1.14 | 0.07 | 1.94 |
| 0.02 | 15.05 | 0.01 | 0.94 | 0.11 | 3.35 |
| 1.64 | 14.98 | 0.01 | 0.74 | 0.04 | 2.01 |
| 3.36 | 14.88 | 0.01 | 0.78 | 0.04 | 1.48 |
