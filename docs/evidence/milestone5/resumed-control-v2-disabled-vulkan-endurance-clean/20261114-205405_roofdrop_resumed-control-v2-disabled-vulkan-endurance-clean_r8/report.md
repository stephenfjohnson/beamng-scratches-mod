# roofdrop - 20261114-205405_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.116 s - 402 frames, 78.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1046 | 51 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 570, BelowThresh 425

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.014 |
| whole frame, ms | 12.759 (p50) | 13.889 | 16.54 |
| all GE Lua, ms | | 1.065 | 3.155 |
| physics + vehicle Lua, ms | | 0.068 | 0.224 |
| render, ms | | 1.815 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.23 us per contact, 2.887 ms total, worst frame 0.023 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.46 | 16.54 | 0.01 | 0.81 | 0.07 | 2.43 |
| 0.42 | 16.38 | 0.01 | 0.90 | 0.06 | 2.25 |
| 0.47 | 16.19 | 0.01 | 0.89 | 0.04 | 2.50 |
| 3.84 | 15.32 | 0.01 | 0.77 | 0.03 | 2.40 |
| 1.25 | 15.25 | 0.01 | 0.89 | 0.05 | 1.87 |
