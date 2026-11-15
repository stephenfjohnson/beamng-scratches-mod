# roofdrop - 20261114-222545_roofdrop_synth-full-vk-endurance_r29

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.327 s - 493 frames, 77.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1382 | 59 | 59 | 0 | 56 | 16 | 27 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 785, BelowThresh 538

Body materials: METAL 57, PLASTIC 2

Surfaces: ASPHALT 59

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.149 | 1.089 | 5.279 |
| whole frame, ms | 12.791 (p50) | 14.731 | 23.594 |
| all GE Lua, ms | | 1.955 | 6.531 |
| physics + vehicle Lua, ms | | 0.073 | 0.179 |
| render, ms | | 1.705 | |

- Painter frames over 4 ms: 2; worst flush (project + bake) 0.985 ms, worst composite 0.103 ms.
- Detector: 1.303 us per contact, 4.716 ms total, worst frame 0.442 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.89 | 23.59 | 3.00 | 5.74 | 0.06 | 1.47 |
| 0.61 | 23.43 | 3.30 | 6.53 | 0.06 | 1.95 |
| 0.59 | 19.09 | 5.28 | 1.51 | 0.04 | 1.36 |
| 0.68 | 19.03 | 0.01 | 1.00 | 0.06 | 1.76 |
| 1.26 | 18.60 | 0.01 | 0.84 | 0.05 | 1.38 |
