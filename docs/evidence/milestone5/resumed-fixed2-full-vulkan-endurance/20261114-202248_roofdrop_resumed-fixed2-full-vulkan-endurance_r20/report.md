# roofdrop - 20261114-202248_roofdrop_resumed-fixed2-full-vulkan-endurance_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.939 s - 367 frames, 68.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 957 | 50 | 50 | 0 | 52 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 555, BelowThresh 352

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.806 | 4.582 | 509.667 |
| whole frame, ms | 12.603 (p50) | 19.143 | 517.856 |
| all GE Lua, ms | | 6.036 | 510.801 |
| physics + vehicle Lua, ms | | 0.104 | 0.726 |
| render, ms | | 2.191 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 509.624 ms, worst composite 0.196 ms.
- Detector: 1.621 us per contact, 3.947 ms total, worst frame 0.585 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.58 | 517.86 | 509.67 | 1.14 | 0.12 | 1.65 |
| 1.85 | 49.53 | 36.20 | 0.85 | 0.05 | 1.30 |
| 2.21 | 49.23 | 35.65 | 0.82 | 0.05 | 1.26 |
| 1.42 | 49.02 | 35.96 | 0.76 | 0.04 | 1.43 |
| 2.48 | 48.88 | 35.57 | 0.81 | 0.05 | 1.09 |
