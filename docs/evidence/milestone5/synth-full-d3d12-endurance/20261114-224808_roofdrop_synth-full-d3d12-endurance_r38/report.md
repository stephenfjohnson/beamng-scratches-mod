# roofdrop - 20261114-224808_roofdrop_synth-full-d3d12-endurance_r38

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.297 s - 463 frames, 87.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1227 | 54 | 54 | 0 | 52 | 14 | 21 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 675, BelowThresh 498

Body materials: METAL 52, PLASTIC 2

Surfaces: ASPHALT 54

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.733 | 0.623 | 28.106 |
| whole frame, ms | 11.184 (p50) | 14.335 | 38.304 |
| all GE Lua, ms | | 1.532 | 29.0 |
| physics + vehicle Lua, ms | | 0.072 | 0.125 |
| render, ms | | 2.114 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 1.165 ms, worst composite 0.104 ms.
- Detector: 1.388 us per contact, 4.078 ms total, worst frame 0.401 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 38.30 | 28.11 | 1.75 | 0.04 | 1.63 |
| 0.90 | 32.56 | 23.40 | 21.13 | 0.08 | 2.00 |
| 1.91 | 30.59 | 19.32 | 1.27 | 0.03 | 1.93 |
| 0.61 | 29.60 | 22.05 | 29.00 | 0.06 | 1.81 |
| 1.52 | 29.43 | 18.03 | 1.33 | 0.03 | 1.57 |
