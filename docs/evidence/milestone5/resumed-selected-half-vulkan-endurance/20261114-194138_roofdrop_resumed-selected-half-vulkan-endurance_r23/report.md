# roofdrop - 20261114-194138_roofdrop_resumed-selected-half-vulkan-endurance_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.151 s - 397 frames, 76.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1068 | 53 | 53 | 0 | 56 | 15 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 603, BelowThresh 412

Body materials: METAL 52, PLASTIC 1

Surfaces: ASPHALT 53

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.311 | 0.908 | 37.165 |
| whole frame, ms | 12.502 (p50) | 14.753 | 49.496 |
| all GE Lua, ms | | 1.929 | 38.547 |
| physics + vehicle Lua, ms | | 0.078 | 0.139 |
| render, ms | | 1.87 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 37.142 ms, worst composite 0.057 ms.
- Detector: 1.38 us per contact, 3.951 ms total, worst frame 0.506 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.52 | 49.50 | 36.23 | 0.99 | 0.07 | 1.66 |
| 1.85 | 48.86 | 36.34 | 0.76 | 0.05 | 1.28 |
| 2.21 | 48.63 | 37.17 | 0.81 | 0.07 | 1.38 |
| 0.80 | 48.43 | 35.56 | 0.88 | 0.05 | 1.58 |
| 1.12 | 48.32 | 35.22 | 0.98 | 0.10 | 1.45 |
