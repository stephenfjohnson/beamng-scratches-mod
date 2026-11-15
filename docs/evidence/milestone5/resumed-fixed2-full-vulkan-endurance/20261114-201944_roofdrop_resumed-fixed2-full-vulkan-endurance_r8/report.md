# roofdrop - 20261114-201944_roofdrop_resumed-fixed2-full-vulkan-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.321 s - 405 frames, 75.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1000 | 52 | 52 | 0 | 55 | 17 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 600, BelowThresh 348

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.63 | 3.638 | 37.303 |
| whole frame, ms | 12.534 (p50) | 16.134 | 50.442 |
| all GE Lua, ms | | 4.612 | 38.472 |
| physics + vehicle Lua, ms | | 0.077 | 0.188 |
| render, ms | | 1.543 | |

- Painter frames over 4 ms: 20; worst flush (project + bake) 37.282 ms, worst composite 0.064 ms.
- Detector: 1.471 us per contact, 4.873 ms total, worst frame 1.623 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.81 | 50.44 | 37.02 | 0.98 | 0.08 | 1.30 |
| 0.53 | 49.84 | 37.30 | 0.78 | 0.08 | 1.16 |
| 2.48 | 49.33 | 36.06 | 0.93 | 0.05 | 1.55 |
| 3.62 | 48.89 | 36.32 | 0.69 | 0.04 | 1.18 |
| 2.19 | 48.80 | 36.27 | 0.81 | 0.04 | 1.15 |
