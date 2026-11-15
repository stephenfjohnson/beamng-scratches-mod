# roofdrop - 20261114-202116_roofdrop_resumed-fixed2-full-vulkan-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.131 s - 388 frames, 75.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1032 | 55 | 55 | 0 | 58 | 14 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 578, BelowThresh 399

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.36 | 3.38 | 36.819 |
| whole frame, ms | 12.609 (p50) | 17.018 | 50.262 |
| all GE Lua, ms | | 4.517 | 37.799 |
| physics + vehicle Lua, ms | | 0.081 | 0.177 |
| render, ms | | 1.665 | |

- Painter frames over 4 ms: 17; worst flush (project + bake) 36.797 ms, worst composite 0.082 ms.
- Detector: 1.475 us per contact, 3.618 ms total, worst frame 0.404 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.14 | 50.26 | 36.80 | 0.72 | 0.05 | 1.55 |
| 0.53 | 49.47 | 35.95 | 0.87 | 0.08 | 1.48 |
| 3.64 | 49.46 | 36.22 | 0.88 | 0.04 | 1.46 |
| 0.81 | 49.09 | 36.79 | 0.86 | 0.05 | 1.55 |
| 2.49 | 48.77 | 36.46 | 1.03 | 0.04 | 1.13 |
