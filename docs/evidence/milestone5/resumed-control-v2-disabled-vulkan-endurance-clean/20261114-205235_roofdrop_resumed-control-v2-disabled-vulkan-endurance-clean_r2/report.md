# roofdrop - 20261114-205235_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.129 s - 405 frames, 78.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1024 | 51 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 592, BelowThresh 381

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.032 |
| whole frame, ms | 12.746 (p50) | 13.936 | 15.852 |
| all GE Lua, ms | | 1.118 | 2.396 |
| physics + vehicle Lua, ms | | 0.072 | 0.15 |
| render, ms | | 1.657 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.254 us per contact, 2.864 ms total, worst frame 0.029 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.93 | 15.85 | 0.01 | 0.93 | 0.07 | 2.44 |
| 1.60 | 15.62 | 0.01 | 0.86 | 0.04 | 1.43 |
| 4.35 | 15.06 | 0.01 | 0.90 | 0.04 | 2.34 |
| 1.53 | 15.05 | 0.01 | 0.78 | 0.06 | 1.77 |
| 4.33 | 14.87 | 0.01 | 0.76 | 0.04 | 2.32 |
