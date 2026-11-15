# roofdrop - 20261114-205121_roofdrop_resumed-control-v2-disabled-vulkan-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.309 s - 418 frames, 78.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1103 | 52 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 624, BelowThresh 427

Body materials: METAL 51, PLASTIC 1

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.047 |
| whole frame, ms | 12.82 (p50) | 13.953 | 15.983 |
| all GE Lua, ms | | 1.108 | 3.029 |
| physics + vehicle Lua, ms | | 0.074 | 0.15 |
| render, ms | | 1.743 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.179 us per contact, 3.018 ms total, worst frame 0.075 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.60 | 15.98 | 0.01 | 1.02 | 0.07 | 1.34 |
| 1.90 | 15.87 | 0.01 | 0.94 | 0.05 | 2.34 |
| 0.35 | 15.62 | 0.01 | 0.78 | 0.04 | 1.60 |
| 2.73 | 15.57 | 0.01 | 0.98 | 0.05 | 1.54 |
| 0.16 | 15.52 | 0.01 | 0.85 | 0.05 | 1.57 |
