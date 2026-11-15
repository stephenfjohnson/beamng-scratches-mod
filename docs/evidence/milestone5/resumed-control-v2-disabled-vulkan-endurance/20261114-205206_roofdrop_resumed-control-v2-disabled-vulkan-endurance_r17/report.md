# roofdrop - 20261114-205206_roofdrop_resumed-control-v2-disabled-vulkan-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.129 s - 402 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1072 | 51 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 621, BelowThresh 400

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.034 |
| whole frame, ms | 12.779 (p50) | 14.004 | 17.617 |
| all GE Lua, ms | | 1.178 | 1.733 |
| physics + vehicle Lua, ms | | 0.077 | 0.363 |
| render, ms | | 1.912 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.237 us per contact, 3.087 ms total, worst frame 0.068 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.65 | 17.62 | 0.01 | 0.93 | 0.06 | 2.22 |
| 0.57 | 16.94 | 0.01 | 1.52 | 0.18 | 2.87 |
| 0.56 | 16.26 | 0.01 | 1.08 | 0.11 | 2.62 |
| 3.10 | 15.31 | 0.01 | 0.89 | 0.04 | 1.49 |
| 0.88 | 15.15 | 0.01 | 1.00 | 0.07 | 2.06 |
