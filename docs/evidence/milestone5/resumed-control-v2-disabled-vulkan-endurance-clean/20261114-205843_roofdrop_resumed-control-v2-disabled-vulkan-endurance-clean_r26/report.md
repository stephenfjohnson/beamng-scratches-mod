# roofdrop - 20261114-205843_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.966 s - 389 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1032 | 53 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 574, BelowThresh 405

Body materials: METAL 51, PLASTIC 2

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.042 |
| whole frame, ms | 12.78 (p50) | 14.179 | 21.903 |
| all GE Lua, ms | | 1.212 | 2.818 |
| physics + vehicle Lua, ms | | 0.08 | 0.185 |
| render, ms | | 1.909 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.249 us per contact, 2.956 ms total, worst frame 0.027 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.53 | 21.90 | 0.01 | 0.85 | 0.04 | 1.50 |
| 2.22 | 16.36 | 0.01 | 0.85 | 0.04 | 2.75 |
| 0.30 | 15.85 | 0.01 | 1.01 | 0.05 | 2.11 |
| 3.57 | 15.81 | 0.01 | 1.01 | 0.03 | 1.61 |
| 0.66 | 15.74 | 0.01 | 0.96 | 0.06 | 1.45 |
