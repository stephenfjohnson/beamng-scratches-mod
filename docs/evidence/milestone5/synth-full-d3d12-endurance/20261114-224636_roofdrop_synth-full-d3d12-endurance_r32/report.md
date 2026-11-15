# roofdrop - 20261114-224636_roofdrop_synth-full-d3d12-endurance_r32

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.943 s - 430 frames, 86.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1070 | 49 | 49 | 0 | 49 | 16 | 24 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 628, BelowThresh 393

Body materials: METAL 47, PLASTIC 2

Surfaces: ASPHALT 49

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.791 | 6.153 | 24.304 |
| whole frame, ms | 11.172 (p50) | 16.503 | 34.52 |
| all GE Lua, ms | | 7.152 | 25.303 |
| physics + vehicle Lua, ms | | 0.079 | 0.164 |
| render, ms | | 2.355 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.897 ms, worst composite 0.092 ms.
- Detector: 1.541 us per contact, 4.05 ms total, worst frame 0.491 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.92 | 34.52 | 24.30 | 21.02 | 0.06 | 1.59 |
| 0.62 | 32.37 | 21.82 | 22.12 | 0.07 | 1.69 |
| 0.89 | 31.70 | 23.89 | 2.72 | 0.06 | 1.64 |
| 0.59 | 31.00 | 22.83 | 3.05 | 0.06 | 1.68 |
| 0.90 | 30.33 | 19.97 | 25.17 | 0.07 | 2.15 |
