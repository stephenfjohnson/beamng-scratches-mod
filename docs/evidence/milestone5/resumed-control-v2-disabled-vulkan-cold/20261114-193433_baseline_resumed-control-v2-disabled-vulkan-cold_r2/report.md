# baseline - 20261114-193433_baseline_resumed-control-v2-disabled-vulkan-cold_r2

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.008 s - 326 frames, 81.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4088 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4088

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.009 | 0.027 |
| whole frame, ms | 12.286 (p50) | 14.653 | 18.277 |
| all GE Lua, ms | | 1.344 | 3.552 |
| physics + vehicle Lua, ms | | 0.102 | 0.196 |
| render, ms | | 2.063 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.437 us per contact, 3.101 ms total, worst frame 0.11 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.52 | 18.28 | 0.01 | 0.85 | 0.04 | 2.42 |
| 2.26 | 17.77 | 0.01 | 1.07 | 0.07 | 1.74 |
| 2.16 | 17.33 | 0.01 | 0.99 | 0.05 | 2.47 |
| 2.92 | 16.11 | 0.01 | 0.82 | 0.04 | 1.71 |
| 3.69 | 15.99 | 0.01 | 0.99 | 0.05 | 1.53 |
