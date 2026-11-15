# roofdrop - 20261114-224159_roofdrop_synth-full-d3d12-endurance_r14

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.049 s - 441 frames, 86.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1212 | 48 | 48 | 0 | 56 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 705, BelowThresh 459

Body materials: METAL 47, PLASTIC 1

Surfaces: ASPHALT 48

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.83 | 6.204 | 24.372 |
| whole frame, ms | 11.28 (p50) | 15.929 | 32.434 |
| all GE Lua, ms | | 7.421 | 25.553 |
| physics + vehicle Lua, ms | | 0.078 | 0.202 |
| render, ms | | 2.211 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 0.984 ms, worst composite 0.094 ms.
- Detector: 1.286 us per contact, 3.872 ms total, worst frame 0.413 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.54 | 32.43 | 24.37 | 20.38 | 0.08 | 2.07 |
| 1.47 | 31.31 | 19.73 | 1.49 | 0.05 | 2.83 |
| 1.53 | 26.89 | 19.35 | 1.93 | 0.04 | 2.03 |
| 1.21 | 26.85 | 19.94 | 17.31 | 0.05 | 1.76 |
| 1.20 | 26.65 | 16.51 | 1.64 | 0.04 | 1.77 |
