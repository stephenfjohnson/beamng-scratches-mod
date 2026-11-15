# roofdrop - 20261114-200126_roofdrop_resumed-fixed-full-vulkan-cold_r1

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.538 s - 428 frames, 77.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1083 | 47 | 47 | 0 | 51 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 676, BelowThresh 360

Body materials: METAL 45, PLASTIC 2

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.359 | 3.342 | 36.743 |
| whole frame, ms | 12.394 (p50) | 15.868 | 48.793 |
| all GE Lua, ms | | 4.356 | 37.751 |
| physics + vehicle Lua, ms | | 0.077 | 0.153 |
| render, ms | | 1.712 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 36.723 ms, worst composite 0.08 ms.
- Detector: 1.477 us per contact, 4.222 ms total, worst frame 0.684 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.13 | 48.79 | 35.28 | 0.81 | 0.06 | 1.18 |
| 1.41 | 48.58 | 36.31 | 0.76 | 0.04 | 1.14 |
| 0.53 | 48.45 | 35.32 | 0.83 | 0.09 | 1.50 |
| 2.92 | 48.33 | 36.74 | 0.97 | 0.08 | 1.26 |
| 2.20 | 47.86 | 35.68 | 0.78 | 0.07 | 1.24 |
