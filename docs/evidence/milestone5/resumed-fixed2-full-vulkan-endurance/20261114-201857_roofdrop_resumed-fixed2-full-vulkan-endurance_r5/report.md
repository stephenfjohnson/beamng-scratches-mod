# roofdrop - 20261114-201857_roofdrop_resumed-fixed2-full-vulkan-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.115 s - 386 frames, 75.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1004 | 56 | 56 | 0 | 56 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 560, BelowThresh 388

Body materials: METAL 55, PLASTIC 1

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.567 | 3.751 | 37.053 |
| whole frame, ms | 12.44 (p50) | 18.675 | 50.58 |
| all GE Lua, ms | | 4.814 | 38.615 |
| physics + vehicle Lua, ms | | 0.088 | 0.257 |
| render, ms | | 1.709 | |

- Painter frames over 4 ms: 19; worst flush (project + bake) 37.029 ms, worst composite 0.07 ms.
- Detector: 1.672 us per contact, 3.79 ms total, worst frame 0.323 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.58 | 36.62 | 0.76 | 0.08 | 1.23 |
| 2.48 | 49.46 | 35.61 | 1.25 | 0.05 | 1.18 |
| 2.00 | 49.43 | 37.05 | 1.04 | 0.09 | 1.22 |
| 1.41 | 49.41 | 36.17 | 0.91 | 0.09 | 1.67 |
| 3.64 | 49.35 | 36.52 | 1.06 | 0.05 | 1.12 |
