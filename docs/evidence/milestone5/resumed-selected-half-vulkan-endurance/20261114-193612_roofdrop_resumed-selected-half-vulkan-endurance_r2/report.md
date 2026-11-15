# roofdrop - 20261114-193612_roofdrop_resumed-selected-half-vulkan-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.307 s - 489 frames, 77.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1388 | 54 | 54 | 0 | 52 | 14 | 20 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 749, BelowThresh 585

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.061 | 0.583 | 38.782 |
| whole frame, ms | 12.581 (p50) | 14.478 | 51.955 |
| all GE Lua, ms | | 1.503 | 39.976 |
| physics + vehicle Lua, ms | | 0.073 | 0.565 |
| render, ms | | 1.597 | |

- Painter frames over 4 ms: 15; worst flush (project + bake) 38.744 ms, worst composite 0.058 ms.
- Detector: 1.331 us per contact, 4.631 ms total, worst frame 0.729 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.80 | 51.95 | 38.78 | 0.82 | 0.04 | 1.30 |
| 0.53 | 50.99 | 37.82 | 1.05 | 0.08 | 1.36 |
| 2.21 | 49.87 | 36.64 | 0.73 | 0.06 | 1.31 |
| 1.85 | 49.20 | 36.67 | 0.78 | 0.05 | 1.15 |
| 2.74 | 49.16 | 36.38 | 0.75 | 0.08 | 1.24 |
