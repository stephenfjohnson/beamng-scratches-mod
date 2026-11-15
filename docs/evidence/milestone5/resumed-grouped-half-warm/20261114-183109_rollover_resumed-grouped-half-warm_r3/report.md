# rollover - 20261114-183109_rollover_resumed-grouped-half-warm_r3

_thrown sideways at 15 m/s, leaning 70 deg into the motion - tumbles over the roof_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 12.002 s - 998 frames, 83.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.995)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3473 | 124 | 101 | 4 | 141 | 64 | 73 | 0.0% | 0 | 0 |

Rejected contacts: BelowThresh 1807, Wheel 827, PartExcluded 715

Body materials: METAL 84, PLASTIC 40

Surfaces: ASPHALT 124

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.704 | 19.087 | 38.602 |
| whole frame, ms | 11.113 (p50) | 26.056 | 48.832 |
| all GE Lua, ms | | 19.867 | 39.547 |
| physics + vehicle Lua, ms | | 0.085 | 0.217 |
| render, ms | | 2.357 | |

- Painter frames over 4 ms: 70; worst flush (project + bake) 38.573 ms, worst composite 0.13 ms.
- Detector: 1.458 us per contact, 9.504 ms total, worst frame 0.357 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.85 | 48.83 | 37.86 | 1.00 | 0.04 | 1.76 |
| 1.32 | 45.82 | 38.60 | 0.68 | 0.04 | 1.50 |
| 10.65 | 45.46 | 33.39 | 0.79 | 0.04 | 1.73 |
| 10.06 | 43.99 | 30.74 | 0.84 | 0.05 | 2.60 |
| 0.35 | 43.91 | 31.86 | 0.92 | 0.05 | 1.73 |
