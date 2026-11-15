# roofdrop - 20261114-224420_roofdrop_synth-full-d3d12-endurance_r23

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.373 s - 468 frames, 86.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1314 | 54 | 54 | 0 | 58 | 18 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 670, BelowThresh 590

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.787 | 5.589 | 25.571 |
| whole frame, ms | 11.242 (p50) | 14.204 | 36.079 |
| all GE Lua, ms | | 6.369 | 26.456 |
| physics + vehicle Lua, ms | | 0.074 | 0.191 |
| render, ms | | 2.057 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.088 ms, worst composite 0.07 ms.
- Detector: 1.331 us per contact, 4.012 ms total, worst frame 0.382 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 36.08 | 25.57 | 4.23 | 0.08 | 1.72 |
| 0.54 | 32.86 | 22.17 | 1.46 | 0.12 | 1.59 |
| 0.88 | 32.26 | 19.85 | 1.90 | 0.04 | 2.65 |
| 0.61 | 29.15 | 21.53 | 26.46 | 0.10 | 1.79 |
| 2.54 | 28.47 | 16.64 | 1.21 | 0.04 | 1.62 |
