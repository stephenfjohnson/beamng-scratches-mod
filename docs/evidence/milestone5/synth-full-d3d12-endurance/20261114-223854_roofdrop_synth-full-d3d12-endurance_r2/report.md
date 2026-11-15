# roofdrop - 20261114-223854_roofdrop_synth-full-d3d12-endurance_r2

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.126 s - 443 frames, 86.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1203 | 47 | 47 | 0 | 53 | 15 | 22 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 657, BelowThresh 499

Body materials: METAL 45, PLASTIC 2

Surfaces: ASPHALT 47

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.763 | 0.731 | 21.123 |
| whole frame, ms | 11.247 (p50) | 15.212 | 31.692 |
| all GE Lua, ms | | 2.945 | 22.014 |
| physics + vehicle Lua, ms | | 0.08 | 0.206 |
| render, ms | | 2.359 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 0.689 ms, worst composite 0.101 ms.
- Detector: 1.416 us per contact, 3.847 ms total, worst frame 0.398 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 31.69 | 20.90 | 1.73 | 0.07 | 1.93 |
| 0.82 | 30.27 | 19.46 | 1.52 | 0.05 | 1.73 |
| 1.52 | 29.51 | 17.69 | 1.41 | 0.04 | 2.37 |
| 0.54 | 28.88 | 18.55 | 1.72 | 0.14 | 2.28 |
| 2.50 | 28.78 | 17.22 | 1.49 | 0.04 | 1.59 |
