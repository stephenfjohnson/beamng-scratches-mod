# roofdrop - 20261114-224114_roofdrop_synth-full-d3d12-endurance_r11

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.05 s - 439 frames, 86.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1080 | 47 | 47 | 0 | 57 | 17 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 626, BelowThresh 407

Body materials: METAL 45, PLASTIC 2

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.804 | 5.752 | 24.689 |
| whole frame, ms | 11.246 (p50) | 16.849 | 34.78 |
| all GE Lua, ms | | 6.593 | 25.596 |
| physics + vehicle Lua, ms | | 0.072 | 0.196 |
| render, ms | | 2.051 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 1.799 ms, worst composite 0.086 ms.
- Detector: 1.356 us per contact, 3.528 ms total, worst frame 0.425 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 34.78 | 24.69 | 1.92 | 0.04 | 1.84 |
| 1.52 | 29.03 | 16.96 | 1.15 | 0.03 | 1.75 |
| 1.20 | 28.26 | 17.10 | 1.33 | 0.04 | 1.66 |
| 0.62 | 28.16 | 18.88 | 19.69 | 0.06 | 1.78 |
| 1.91 | 27.95 | 17.17 | 1.20 | 0.07 | 1.63 |
