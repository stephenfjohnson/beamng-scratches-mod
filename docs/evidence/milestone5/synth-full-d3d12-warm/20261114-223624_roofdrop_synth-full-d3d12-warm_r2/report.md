# roofdrop - 20261114-223624_roofdrop_synth-full-d3d12-warm_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.529 s - 479 frames, 86.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1226 | 54 | 54 | 0 | 60 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 743, BelowThresh 429

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.808 | 5.507 | 25.99 |
| whole frame, ms | 11.23 (p50) | 16.427 | 34.106 |
| all GE Lua, ms | | 6.395 | 26.845 |
| physics + vehicle Lua, ms | | 0.074 | 0.253 |
| render, ms | | 2.122 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 0.97 ms, worst composite 0.059 ms.
- Detector: 1.425 us per contact, 4.387 ms total, worst frame 0.479 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 34.11 | 24.74 | 1.53 | 0.11 | 1.55 |
| 0.55 | 32.76 | 25.99 | 25.78 | 0.12 | 1.60 |
| 0.91 | 30.03 | 22.31 | 21.00 | 0.07 | 2.17 |
| 1.46 | 29.47 | 17.24 | 1.33 | 0.04 | 1.82 |
| 2.25 | 29.23 | 18.08 | 1.35 | 0.03 | 1.77 |
