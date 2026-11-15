# roofdrop - 20261114-205537_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.945 s - 389 frames, 78.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 952 | 46 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 552, BelowThresh 354

Body materials: METAL 44, PLASTIC 2

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.044 |
| whole frame, ms | 12.821 (p50) | 14.66 | 17.052 |
| all GE Lua, ms | | 1.241 | 3.313 |
| physics + vehicle Lua, ms | | 0.086 | 0.187 |
| render, ms | | 1.915 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.268 us per contact, 2.889 ms total, worst frame 0.03 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.46 | 17.05 | 0.01 | 0.85 | 0.05 | 2.02 |
| 0.27 | 16.96 | 0.01 | 1.14 | 0.05 | 1.43 |
| 1.73 | 16.82 | 0.02 | 3.12 | 0.05 | 1.87 |
| 0.44 | 16.57 | 0.01 | 0.90 | 0.06 | 1.60 |
| 1.82 | 16.30 | 0.01 | 1.26 | 0.05 | 1.70 |
