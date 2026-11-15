# roofdrop - 20261114-224721_roofdrop_synth-full-d3d12-endurance_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.261 s - 546 frames, 87.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1549 | 59 | 59 | 0 | 60 | 16 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 885, BelowThresh 605

Body materials: METAL 57, PLASTIC 2

Surfaces: ASPHALT 59

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.716 | 1.092 | 27.931 |
| whole frame, ms | 11.259 (p50) | 14.285 | 38.512 |
| all GE Lua, ms | | 1.95 | 28.977 |
| physics + vehicle Lua, ms | | 0.069 | 0.152 |
| render, ms | | 1.997 | |

- Painter frames over 4 ms: 27; worst flush (project + bake) 1.054 ms, worst composite 0.087 ms.
- Detector: 1.357 us per contact, 4.612 ms total, worst frame 0.423 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.54 | 38.51 | 27.93 | 1.22 | 0.09 | 1.69 |
| 0.82 | 34.91 | 23.72 | 1.35 | 0.04 | 1.65 |
| 0.61 | 31.00 | 24.06 | 22.69 | 0.06 | 1.79 |
| 0.60 | 29.56 | 21.90 | 1.72 | 0.06 | 1.24 |
| 1.52 | 28.08 | 16.51 | 1.16 | 0.03 | 1.94 |
