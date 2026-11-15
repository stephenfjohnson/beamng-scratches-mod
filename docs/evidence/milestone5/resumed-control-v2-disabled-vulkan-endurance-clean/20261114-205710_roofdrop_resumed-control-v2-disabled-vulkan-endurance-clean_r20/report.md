# roofdrop - 20261114-205710_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.681 s - 445 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1204 | 60 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 674, BelowThresh 470

Body materials: METAL 58, PLASTIC 2

Surfaces: ASPHALT 60

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.026 |
| whole frame, ms | 12.812 (p50) | 14.111 | 16.444 |
| all GE Lua, ms | | 1.151 | 2.939 |
| physics + vehicle Lua, ms | | 0.074 | 0.183 |
| render, ms | | 1.819 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.248 us per contact, 3.342 ms total, worst frame 0.026 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.48 | 16.44 | 0.01 | 1.12 | 0.06 | 1.35 |
| 1.99 | 15.47 | 0.01 | 0.74 | 0.04 | 1.73 |
| 0.69 | 15.37 | 0.01 | 1.05 | 0.05 | 1.59 |
| 1.67 | 15.32 | 0.01 | 0.79 | 0.04 | 1.54 |
| 3.31 | 15.16 | 0.01 | 0.96 | 0.05 | 1.54 |
