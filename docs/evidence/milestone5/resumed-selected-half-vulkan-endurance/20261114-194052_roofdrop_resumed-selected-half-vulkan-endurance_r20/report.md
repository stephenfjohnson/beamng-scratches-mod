# roofdrop - 20261114-194052_roofdrop_resumed-selected-half-vulkan-endurance_r20

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.008 s - 383 frames, 76.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1020 | 54 | 54 | 0 | 59 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 580, BelowThresh 386

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.532 | 0.917 | 37.481 |
| whole frame, ms | 12.56 (p50) | 14.887 | 50.222 |
| all GE Lua, ms | | 1.852 | 39.662 |
| physics + vehicle Lua, ms | | 0.068 | 0.186 |
| render, ms | | 1.501 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 37.458 ms, worst composite 0.088 ms.
- Detector: 1.33 us per contact, 3.66 ms total, worst frame 0.537 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 50.22 | 36.60 | 1.09 | 0.07 | 1.29 |
| 2.47 | 50.15 | 37.48 | 0.82 | 0.04 | 1.17 |
| 2.20 | 49.56 | 37.23 | 0.75 | 0.07 | 1.11 |
| 1.41 | 49.37 | 37.40 | 0.79 | 0.04 | 1.32 |
| 3.75 | 49.24 | 35.02 | 0.86 | 0.03 | 1.40 |
