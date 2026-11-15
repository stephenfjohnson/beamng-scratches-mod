# rollover - 20261114-183016_rollover_resumed-grouped-half-warm_r2

_thrown sideways at 15 m/s, leaning 70 deg into the motion - tumbles over the roof_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 12.011 s - 986 frames, 81.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.999)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 5278 | 162 | 89 | 20 | 145 | 68 | 87 | 0.0% | 0 | 0 |

Rejected contacts: BelowThresh 3157, PartExcluded 1184, Wheel 775

Body materials: METAL 116, PLASTIC 46

Surfaces: ASPHALT 162

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.0 | 19.294 | 255.161 |
| whole frame, ms | 11.321 (p50) | 28.632 | 266.48 |
| all GE Lua, ms | | 20.354 | 256.405 |
| physics + vehicle Lua, ms | | 0.082 | 0.206 |
| render, ms | | 2.133 | |

- Painter frames over 4 ms: 78; worst flush (project + bake) 255.128 ms, worst composite 0.071 ms.
- Detector: 1.307 us per contact, 11.428 ms total, worst frame 0.403 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.27 | 266.48 | 255.16 | 0.76 | 0.05 | 1.80 |
| 1.63 | 48.39 | 36.61 | 0.71 | 0.08 | 1.77 |
| 11.76 | 45.39 | 33.20 | 0.72 | 0.06 | 1.79 |
| 0.25 | 43.56 | 31.20 | 0.86 | 0.11 | 1.95 |
| 11.28 | 43.49 | 32.24 | 0.83 | 0.05 | 1.87 |
