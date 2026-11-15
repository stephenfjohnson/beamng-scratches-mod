# roofdrop - 20261114-205928_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 6.53 s - 515 frames, 78.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1463 | 59 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 855, BelowThresh 549

Body materials: METAL 57, PLASTIC 2

Surfaces: ASPHALT 59

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.029 |
| whole frame, ms | 12.715 (p50) | 13.869 | 17.902 |
| all GE Lua, ms | | 1.089 | 2.146 |
| physics + vehicle Lua, ms | | 0.073 | 0.244 |
| render, ms | | 1.69 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.172 us per contact, 3.873 ms total, worst frame 0.029 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.13 | 17.90 | 0.01 | 1.32 | 0.07 | 5.39 |
| 2.68 | 16.50 | 0.01 | 0.93 | 0.04 | 3.09 |
| 0.52 | 16.37 | 0.01 | 0.91 | 0.04 | 1.43 |
| 2.08 | 16.06 | 0.01 | 0.74 | 0.04 | 2.35 |
| 0.53 | 15.80 | 0.01 | 0.94 | 0.11 | 1.43 |
