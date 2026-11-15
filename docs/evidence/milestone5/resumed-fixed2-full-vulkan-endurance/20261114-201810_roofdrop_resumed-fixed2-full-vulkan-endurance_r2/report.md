# roofdrop - 20261114-201810_roofdrop_resumed-fixed2-full-vulkan-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.719 s - 435 frames, 76.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1220 | 54 | 53 | 0 | 51 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 678, BelowThresh 488

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.303 | 3.49 | 38.572 |
| whole frame, ms | 12.571 (p50) | 16.704 | 51.087 |
| all GE Lua, ms | | 4.498 | 39.558 |
| physics + vehicle Lua, ms | | 0.081 | 0.439 |
| render, ms | | 1.561 | |

- Painter frames over 4 ms: 20; worst flush (project + bake) 38.547 ms, worst composite 0.06 ms.
- Detector: 1.414 us per contact, 4.395 ms total, worst frame 0.788 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 51.09 | 38.57 | 0.88 | 0.11 | 1.29 |
| 5.19 | 49.72 | 36.49 | 0.83 | 0.03 | 1.21 |
| 0.81 | 49.15 | 36.04 | 0.97 | 0.10 | 1.23 |
| 1.14 | 49.15 | 37.07 | 0.75 | 0.04 | 1.25 |
| 1.41 | 48.87 | 35.88 | 0.81 | 0.04 | 1.25 |
