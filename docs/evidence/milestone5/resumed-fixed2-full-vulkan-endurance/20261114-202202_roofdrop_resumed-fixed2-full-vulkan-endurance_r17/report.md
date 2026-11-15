# roofdrop - 20261114-202202_roofdrop_resumed-fixed2-full-vulkan-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.292 s - 474 frames, 75.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1357 | 54 | 54 | 0 | 58 | 19 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 785, BelowThresh 518

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.387 | 3.64 | 37.635 |
| whole frame, ms | 12.689 (p50) | 15.722 | 50.778 |
| all GE Lua, ms | | 5.059 | 38.694 |
| physics + vehicle Lua, ms | | 0.08 | 0.141 |
| render, ms | | 1.611 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 37.61 ms, worst composite 0.109 ms.
- Detector: 1.438 us per contact, 4.499 ms total, worst frame 0.42 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.14 | 50.78 | 37.27 | 1.14 | 0.14 | 1.86 |
| 5.12 | 50.48 | 37.63 | 0.81 | 0.04 | 1.36 |
| 2.48 | 49.92 | 37.09 | 0.93 | 0.04 | 1.22 |
| 3.62 | 49.61 | 37.07 | 0.71 | 0.04 | 1.24 |
| 0.80 | 49.03 | 36.00 | 0.95 | 0.08 | 1.33 |
