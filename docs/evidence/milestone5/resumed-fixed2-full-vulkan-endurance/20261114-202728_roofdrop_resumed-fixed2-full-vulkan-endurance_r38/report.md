# roofdrop - 20261114-202728_roofdrop_resumed-fixed2-full-vulkan-endurance_r38

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.344 s - 394 frames, 63.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 994 | 56 | 56 | 0 | 60 | 20 | 29 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 620, BelowThresh 318

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.815 | 4.381 | 37.131 |
| whole frame, ms | 12.359 (p50) | 20.592 | 965.07 |
| all GE Lua, ms | | 5.687 | 38.084 |
| physics + vehicle Lua, ms | | 0.091 | 0.203 |
| render, ms | | 1.826 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 37.106 ms, worst composite 0.072 ms.
- Detector: 1.601 us per contact, 3.913 ms total, worst frame 0.419 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.19 | 965.07 | 14.03 | 0.95 | 0.05 | 1.33 |
| 4.90 | 50.13 | 36.06 | 0.72 | 0.04 | 1.39 |
| 0.53 | 49.89 | 37.13 | 0.85 | 0.09 | 1.24 |
| 0.80 | 49.61 | 37.00 | 0.78 | 0.06 | 1.38 |
| 2.95 | 49.53 | 36.08 | 0.91 | 0.06 | 1.30 |
