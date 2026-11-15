# roofdrop - 20261114-194442_roofdrop_resumed-selected-half-vulkan-endurance_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.128 s - 396 frames, 77.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 985 | 50 | 50 | 0 | 51 | 15 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 592, BelowThresh 343

Body materials: METAL 48, PLASTIC 2

Surfaces: ASPHALT 50

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.326 | 0.833 | 36.963 |
| whole frame, ms | 12.509 (p50) | 14.123 | 49.972 |
| all GE Lua, ms | | 1.741 | 37.999 |
| physics + vehicle Lua, ms | | 0.074 | 0.14 |
| render, ms | | 1.73 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 36.944 ms, worst composite 0.048 ms.
- Detector: 1.343 us per contact, 3.796 ms total, worst frame 0.535 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.66 | 49.97 | 36.96 | 0.73 | 0.04 | 1.25 |
| 0.53 | 49.01 | 36.19 | 0.89 | 0.12 | 1.48 |
| 2.20 | 48.31 | 35.56 | 0.74 | 0.06 | 1.42 |
| 1.41 | 48.18 | 35.75 | 0.79 | 0.07 | 1.38 |
| 1.13 | 48.11 | 36.11 | 0.84 | 0.08 | 1.47 |
