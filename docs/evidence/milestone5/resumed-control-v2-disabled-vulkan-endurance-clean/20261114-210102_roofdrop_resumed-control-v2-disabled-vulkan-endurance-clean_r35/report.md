# roofdrop - 20261114-210102_roofdrop_resumed-control-v2-disabled-vulkan-endurance-clean_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: True after 5.314 s - 419 frames, 78.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1114 | 49 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 650, BelowThresh 415

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.043 |
| whole frame, ms | 12.684 (p50) | 15.353 | 19.065 |
| all GE Lua, ms | | 1.249 | 4.291 |
| physics + vehicle Lua, ms | | 0.077 | 0.168 |
| render, ms | | 2.134 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.295 us per contact, 3.278 ms total, worst frame 0.027 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.82 | 19.06 | 0.01 | 4.29 | 0.11 | 2.41 |
| 2.33 | 17.89 | 0.01 | 0.90 | 0.06 | 1.65 |
| 4.66 | 17.26 | 0.01 | 0.80 | 0.04 | 1.98 |
| 0.38 | 17.20 | 0.01 | 1.10 | 0.05 | 1.54 |
| 1.83 | 16.84 | 0.01 | 0.99 | 0.06 | 1.85 |
