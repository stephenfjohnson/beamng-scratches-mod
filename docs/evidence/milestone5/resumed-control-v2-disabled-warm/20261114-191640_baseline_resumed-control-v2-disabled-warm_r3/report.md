# baseline - 20261114-191640_baseline_resumed-control-v2-disabled-warm_r3

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.006 s - 353 frames, 87.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4705 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4705

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.032 |
| whole frame, ms | 11.329 (p50) | 12.763 | 15.595 |
| all GE Lua, ms | | 1.033 | 1.283 |
| physics + vehicle Lua, ms | | 0.106 | 0.225 |
| render, ms | | 2.48 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.389 us per contact, 3.101 ms total, worst frame 0.035 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.42 | 15.60 | 0.01 | 0.80 | 0.08 | 2.18 |
| 0.05 | 14.75 | 0.01 | 1.05 | 0.16 | 2.20 |
| 0.69 | 14.62 | 0.01 | 0.84 | 0.08 | 2.27 |
| 1.82 | 14.09 | 0.01 | 0.87 | 0.06 | 3.46 |
| 1.25 | 13.75 | 0.01 | 0.80 | 0.05 | 2.17 |
