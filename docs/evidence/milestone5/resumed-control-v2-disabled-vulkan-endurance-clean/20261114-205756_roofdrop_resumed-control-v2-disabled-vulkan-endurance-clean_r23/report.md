# roofdrop - 20261114-205756_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 6.458 s - 505 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1430 | 55 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 865, BelowThresh 510

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.038 |
| whole frame, ms | 12.813 (p50) | 14.389 | 18.12 |
| all GE Lua, ms | | 1.157 | 3.054 |
| physics + vehicle Lua, ms | | 0.074 | 0.126 |
| render, ms | | 1.825 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.18 us per contact, 3.674 ms total, worst frame 0.025 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.57 | 18.12 | 0.01 | 1.32 | 0.05 | 1.43 |
| 6.18 | 17.17 | 0.01 | 0.80 | 0.04 | 1.54 |
| 3.12 | 16.66 | 0.01 | 0.80 | 0.03 | 2.35 |
| 5.40 | 16.13 | 0.01 | 0.95 | 0.09 | 1.44 |
| 5.69 | 15.90 | 0.04 | 1.12 | 0.05 | 1.74 |
