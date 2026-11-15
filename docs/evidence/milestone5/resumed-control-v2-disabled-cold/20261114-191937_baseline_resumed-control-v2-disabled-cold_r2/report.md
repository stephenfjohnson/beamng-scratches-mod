# baseline - 20261114-191937_baseline_resumed-control-v2-disabled-cold_r2

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.003 s - 362 frames, 90.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4825 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4825

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.007 | 0.025 |
| whole frame, ms | 11.047 (p50) | 12.065 | 15.891 |
| all GE Lua, ms | | 1.084 | 2.274 |
| physics + vehicle Lua, ms | | 0.101 | 0.3 |
| render, ms | | 2.241 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.383 us per contact, 2.989 ms total, worst frame 0.097 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.02 | 15.89 | 0.01 | 0.82 | 0.10 | 5.46 |
| 3.00 | 15.23 | 0.01 | 0.99 | 0.04 | 2.19 |
| 3.69 | 14.31 | 0.01 | 0.82 | 0.03 | 3.46 |
| 1.70 | 14.14 | 0.01 | 0.92 | 0.06 | 1.98 |
| 1.66 | 13.27 | 0.01 | 2.27 | 0.05 | 1.92 |
