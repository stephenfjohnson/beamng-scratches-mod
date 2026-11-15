# baseline - 20261114-191808_baseline_resumed-control-v2-disabled-cold_r1

_upright, coasting at 15 m/s - should leave no marks_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 4.011 s - 359 frames, 89.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: False (lowest up-vector z 1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4782 | 0 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: Wheel 4782

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.005 | 0.007 | 0.04 |
| whole frame, ms | 11.108 (p50) | 13.698 | 19.794 |
| all GE Lua, ms | | 1.253 | 3.387 |
| physics + vehicle Lua, ms | | 0.105 | 0.165 |
| render, ms | | 2.57 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 0.463 us per contact, 3.483 ms total, worst frame 0.078 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.02 | 19.79 | 0.00 | 0.77 | 0.13 | 6.38 |
| 1.98 | 18.16 | 0.00 | 2.58 | 0.07 | 3.59 |
| 1.93 | 17.65 | 0.00 | 0.97 | 0.08 | 2.23 |
| 3.27 | 16.35 | 0.01 | 0.71 | 0.04 | 2.40 |
| 1.53 | 15.85 | 0.00 | 1.05 | 0.06 | 3.24 |
