# roofdrop - 20261114-202555_roofdrop_resumed-fixed2-full-vulkan-endurance_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.931 s - 371 frames, 75.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 900 | 52 | 52 | 0 | 52 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 520, BelowThresh 328

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.535 | 3.885 | 37.436 |
| whole frame, ms | 12.527 (p50) | 17.55 | 51.625 |
| all GE Lua, ms | | 5.04 | 38.418 |
| physics + vehicle Lua, ms | | 0.076 | 0.168 |
| render, ms | | 1.876 | |

- Painter frames over 4 ms: 18; worst flush (project + bake) 37.406 ms, worst composite 0.097 ms.
- Detector: 1.566 us per contact, 4.188 ms total, worst frame 1.024 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.53 | 51.63 | 35.80 | 0.97 | 0.12 | 1.77 |
| 1.41 | 49.56 | 37.44 | 1.02 | 0.04 | 1.21 |
| 0.81 | 49.25 | 36.19 | 0.80 | 0.04 | 1.41 |
| 1.85 | 49.07 | 36.32 | 0.80 | 0.04 | 1.19 |
| 3.84 | 48.44 | 34.96 | 0.97 | 0.07 | 1.76 |
