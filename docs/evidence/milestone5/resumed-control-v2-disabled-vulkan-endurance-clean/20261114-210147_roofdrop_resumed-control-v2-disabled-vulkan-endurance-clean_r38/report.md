# roofdrop - 20261114-210147_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r38

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 6.548 s - 516 frames, 78.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1468 | 60 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 871, BelowThresh 537

Body materials: METAL 59, PLASTIC 1

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.034 |
| whole frame, ms | 12.718 (p50) | 13.89 | 16.121 |
| all GE Lua, ms | | 1.103 | 1.492 |
| physics + vehicle Lua, ms | | 0.071 | 0.162 |
| render, ms | | 1.726 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.13 us per contact, 3.769 ms total, worst frame 0.024 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.95 | 16.12 | 0.01 | 1.36 | 0.12 | 2.65 |
| 1.39 | 15.98 | 0.01 | 0.81 | 0.04 | 1.48 |
| 0.86 | 15.67 | 0.01 | 0.76 | 0.04 | 2.35 |
| 2.15 | 15.66 | 0.01 | 0.84 | 0.04 | 1.91 |
| 4.44 | 15.02 | 0.01 | 1.13 | 0.06 | 1.66 |
