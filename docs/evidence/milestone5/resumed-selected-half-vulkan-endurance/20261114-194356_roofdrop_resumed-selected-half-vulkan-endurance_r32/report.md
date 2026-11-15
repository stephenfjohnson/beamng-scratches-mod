# roofdrop - 20261114-194356_roofdrop_resumed-selected-half-vulkan-endurance_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.129 s - 393 frames, 76.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1008 | 54 | 54 | 0 | 45 | 15 | 20 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 594, BelowThresh 360

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.302 | 0.752 | 37.354 |
| whole frame, ms | 12.632 (p50) | 14.914 | 50.407 |
| all GE Lua, ms | | 1.62 | 38.653 |
| physics + vehicle Lua, ms | | 0.072 | 0.133 |
| render, ms | | 1.605 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 37.331 ms, worst composite 0.051 ms.
- Detector: 1.456 us per contact, 3.825 ms total, worst frame 0.49 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.41 | 37.35 | 0.80 | 0.05 | 1.29 |
| 1.14 | 49.85 | 35.12 | 1.06 | 0.06 | 1.39 |
| 0.80 | 49.79 | 36.68 | 0.74 | 0.07 | 1.27 |
| 1.83 | 49.10 | 36.05 | 0.97 | 0.10 | 1.19 |
| 3.66 | 48.92 | 36.84 | 1.21 | 0.09 | 1.14 |
