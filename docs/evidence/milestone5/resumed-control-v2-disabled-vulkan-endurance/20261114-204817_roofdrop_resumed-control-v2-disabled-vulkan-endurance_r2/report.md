# roofdrop - 20261114-204817_roofdrop_resumed-control-v2-disabled-vulkan-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 6.486 s - 503 frames, 77.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1411 | 61 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 795, BelowThresh 555

Body materials: METAL 59, PLASTIC 2

Surfaces: ASPHALT 61

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.053 |
| whole frame, ms | 12.892 (p50) | 14.726 | 17.16 |
| all GE Lua, ms | | 1.195 | 2.602 |
| physics + vehicle Lua, ms | | 0.08 | 0.183 |
| render, ms | | 1.947 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.314 us per contact, 3.657 ms total, worst frame 0.031 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.34 | 17.16 | 0.01 | 0.95 | 0.05 | 3.84 |
| 3.45 | 16.94 | 0.01 | 0.87 | 0.04 | 1.37 |
| 5.54 | 16.47 | 0.01 | 0.98 | 0.05 | 1.85 |
| 6.43 | 16.37 | 0.01 | 1.07 | 0.06 | 1.61 |
| 5.58 | 15.97 | 0.01 | 0.86 | 0.05 | 1.26 |
