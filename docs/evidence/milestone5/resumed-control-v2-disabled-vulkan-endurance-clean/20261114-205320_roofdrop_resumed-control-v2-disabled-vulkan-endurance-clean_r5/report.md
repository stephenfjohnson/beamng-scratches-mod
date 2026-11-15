# roofdrop - 20261114-205320_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 4.936 s - 387 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 945 | 46 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 528, BelowThresh 371

Body materials: METAL 45, PLASTIC 1

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.009 | 0.012 | 0.036 |
| whole frame, ms | 12.809 (p50) | 14.422 | 19.881 |
| all GE Lua, ms | | 1.422 | 2.259 |
| physics + vehicle Lua, ms | | 0.091 | 0.225 |
| render, ms | | 2.44 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.421 us per contact, 3.378 ms total, worst frame 0.06 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.73 | 19.88 | 0.01 | 1.14 | 0.06 | 1.62 |
| 0.92 | 16.93 | 0.02 | 1.24 | 0.08 | 3.00 |
| 0.57 | 15.63 | 0.01 | 1.04 | 0.07 | 2.30 |
| 1.30 | 15.27 | 0.01 | 1.14 | 0.06 | 2.23 |
| 2.55 | 15.12 | 0.01 | 0.87 | 0.04 | 1.26 |
