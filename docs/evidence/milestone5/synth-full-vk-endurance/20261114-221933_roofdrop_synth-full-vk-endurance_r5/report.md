# roofdrop - 20261114-221933_roofdrop_synth-full-vk-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.34 s - 504 frames, 79.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1357 | 55 | 55 | 0 | 56 | 17 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 813, BelowThresh 489

Body materials: METAL 53, PLASTIC 2

Surfaces: ASPHALT 55

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.15 | 0.77 | 5.077 |
| whole frame, ms | 12.644 (p50) | 14.713 | 19.857 |
| all GE Lua, ms | | 1.804 | 6.003 |
| physics + vehicle Lua, ms | | 0.071 | 0.157 |
| render, ms | | 1.608 | |

- Painter frames over 4 ms: 3; worst flush (project + bake) 0.984 ms, worst composite 0.051 ms.
- Detector: 1.291 us per contact, 4.494 ms total, worst frame 0.462 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 19.86 | 2.23 | 5.58 | 0.06 | 1.28 |
| 1.53 | 18.56 | 4.41 | 0.99 | 0.06 | 1.18 |
| 1.89 | 18.55 | 1.21 | 1.01 | 0.03 | 1.36 |
| 0.93 | 18.18 | 0.01 | 0.80 | 0.07 | 1.34 |
| 0.59 | 17.94 | 4.76 | 1.49 | 0.07 | 1.19 |
