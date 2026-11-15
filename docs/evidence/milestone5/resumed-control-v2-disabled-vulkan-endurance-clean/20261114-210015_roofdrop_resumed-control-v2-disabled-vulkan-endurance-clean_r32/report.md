# roofdrop - 20261114-210015_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.375 s - 427 frames, 79.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1158 | 57 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 640, BelowThresh 461

Body materials: METAL 55, PLASTIC 2

Surfaces: ASPHALT 57

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.027 |
| whole frame, ms | 12.585 (p50) | 13.815 | 16.225 |
| all GE Lua, ms | | 1.041 | 1.507 |
| physics + vehicle Lua, ms | | 0.071 | 0.195 |
| render, ms | | 1.545 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.173 us per contact, 3.036 ms total, worst frame 0.024 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.30 | 16.23 | 0.01 | 0.88 | 0.04 | 1.24 |
| 4.85 | 15.52 | 0.01 | 0.87 | 0.03 | 1.62 |
| 1.20 | 15.18 | 0.01 | 1.00 | 0.06 | 2.38 |
| 2.38 | 15.04 | 0.01 | 0.82 | 0.04 | 1.33 |
| 1.24 | 15.02 | 0.01 | 0.75 | 0.04 | 1.99 |
