# roofdrop - 20261114-205623_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 6.168 s - 484 frames, 78.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1365 | 57 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 784, BelowThresh 524

Body materials: METAL 55, PLASTIC 2

Surfaces: ASPHALT 57

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.037 |
| whole frame, ms | 12.775 (p50) | 13.933 | 18.2 |
| all GE Lua, ms | | 1.117 | 1.667 |
| physics + vehicle Lua, ms | | 0.078 | 0.139 |
| render, ms | | 1.741 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.161 us per contact, 3.458 ms total, worst frame 0.022 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.73 | 18.20 | 0.01 | 0.88 | 0.04 | 1.46 |
| 5.92 | 16.61 | 0.01 | 0.86 | 0.05 | 1.34 |
| 5.06 | 16.13 | 0.01 | 1.19 | 0.06 | 3.22 |
| 5.72 | 15.93 | 0.01 | 0.81 | 0.05 | 2.23 |
| 0.05 | 15.48 | 0.04 | 0.78 | 0.04 | 3.49 |
