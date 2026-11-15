# roofdrop - 20261114-223939_roofdrop_synth-full-d3d12-endurance_r5

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.285 s - 460 frames, 86.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1251 | 54 | 54 | 0 | 53 | 19 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 691, BelowThresh 506

Body materials: METAL 53, PLASTIC 1

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.738 | 5.809 | 21.989 |
| whole frame, ms | 11.276 (p50) | 16.029 | 30.516 |
| all GE Lua, ms | | 6.687 | 22.839 |
| physics + vehicle Lua, ms | | 0.079 | 0.184 |
| render, ms | | 2.39 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 0.803 ms, worst composite 0.077 ms.
- Detector: 1.681 us per contact, 4.705 ms total, worst frame 0.496 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.82 | 30.52 | 19.20 | 1.45 | 0.05 | 1.86 |
| 1.20 | 30.42 | 17.54 | 1.72 | 0.06 | 2.47 |
| 0.54 | 29.63 | 18.35 | 2.14 | 0.18 | 2.25 |
| 1.47 | 29.01 | 17.76 | 1.35 | 0.07 | 1.69 |
| 2.27 | 28.76 | 19.30 | 1.34 | 0.05 | 1.86 |
