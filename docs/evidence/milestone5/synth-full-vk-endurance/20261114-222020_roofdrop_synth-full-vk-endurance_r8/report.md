# roofdrop - 20261114-222020_roofdrop_synth-full-vk-endurance_r8

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.3 s - 422 frames, 78.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1160 | 56 | 56 | 0 | 57 | 16 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 628, BelowThresh 476

Body materials: METAL 54, PLASTIC 2

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.202 | 1.112 | 6.085 |
| whole frame, ms | 12.767 (p50) | 15.314 | 24.555 |
| all GE Lua, ms | | 2.357 | 6.933 |
| physics + vehicle Lua, ms | | 0.07 | 0.167 |
| render, ms | | 1.644 | |

- Painter frames over 4 ms: 5; worst flush (project + bake) 1.025 ms, worst composite 0.053 ms.
- Detector: 1.321 us per contact, 3.88 ms total, worst frame 0.339 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.89 | 24.55 | 5.59 | 4.78 | 0.06 | 1.76 |
| 0.90 | 21.47 | 3.50 | 6.44 | 0.07 | 1.51 |
| 0.65 | 19.11 | 0.01 | 0.80 | 0.05 | 1.48 |
| 1.26 | 18.59 | 0.01 | 0.72 | 0.04 | 1.39 |
| 1.22 | 18.56 | 4.54 | 3.71 | 0.09 | 1.42 |
