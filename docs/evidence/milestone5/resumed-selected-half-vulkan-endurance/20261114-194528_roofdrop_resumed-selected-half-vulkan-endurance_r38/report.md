# roofdrop - 20261114-194528_roofdrop_resumed-selected-half-vulkan-endurance_r38

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.141 s - 395 frames, 76.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1033 | 47 | 47 | 0 | 54 | 17 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 617, BelowThresh 369

Body materials: METAL 45, PLASTIC 2

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.459 | 0.798 | 37.721 |
| whole frame, ms | 12.518 (p50) | 15.312 | 50.525 |
| all GE Lua, ms | | 1.777 | 38.825 |
| physics + vehicle Lua, ms | | 0.073 | 0.535 |
| render, ms | | 1.799 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 37.699 ms, worst composite 0.057 ms.
- Detector: 1.3 us per contact, 3.564 ms total, worst frame 0.413 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.14 | 50.53 | 37.72 | 0.80 | 0.05 | 1.31 |
| 0.53 | 50.31 | 36.34 | 0.76 | 0.07 | 1.26 |
| 0.80 | 49.25 | 35.59 | 0.79 | 0.06 | 1.35 |
| 2.21 | 49.09 | 35.94 | 0.95 | 0.04 | 1.20 |
| 1.84 | 48.79 | 35.58 | 0.76 | 0.04 | 1.29 |
