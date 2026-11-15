# roofdrop - 20261114-201148_roofdrop_resumed-fixed2-full-vulkan-cold_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.136 s - 377 frames, 73.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 950 | 55 | 55 | 0 | 55 | 19 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 563, BelowThresh 332

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.744 | 4.722 | 36.948 |
| whole frame, ms | 12.402 (p50) | 21.563 | 50.103 |
| all GE Lua, ms | | 5.697 | 37.956 |
| physics + vehicle Lua, ms | | 0.086 | 0.851 |
| render, ms | | 1.944 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 36.93 ms, worst composite 0.076 ms.
- Detector: 1.843 us per contact, 4.365 ms total, worst frame 0.757 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.83 | 50.10 | 35.69 | 0.91 | 0.04 | 1.37 |
| 0.54 | 49.27 | 35.97 | 1.22 | 0.14 | 1.91 |
| 1.85 | 48.82 | 32.96 | 0.93 | 0.09 | 1.22 |
| 1.40 | 48.60 | 36.95 | 0.85 | 0.07 | 1.31 |
| 0.81 | 48.43 | 36.26 | 0.76 | 0.04 | 1.49 |
