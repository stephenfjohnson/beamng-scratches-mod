# roofdrop - 20261114-222458_roofdrop_synth-full-vk-endurance_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.445 s - 500 frames, 77.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1382 | 56 | 56 | 0 | 60 | 17 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 837, BelowThresh 489

Body materials: METAL 55, PLASTIC 1

Surfaces: ASPHALT 56

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.168 | 0.909 | 5.408 |
| whole frame, ms | 12.931 (p50) | 15.496 | 21.086 |
| all GE Lua, ms | | 1.864 | 6.934 |
| physics + vehicle Lua, ms | | 0.082 | 0.242 |
| render, ms | | 1.805 | |

- Painter frames over 4 ms: 2; worst flush (project + bake) 1.155 ms, worst composite 0.077 ms.
- Detector: 1.446 us per contact, 4.821 ms total, worst frame 0.379 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.88 | 21.09 | 3.17 | 4.76 | 0.05 | 1.69 |
| 2.59 | 19.98 | 0.01 | 0.93 | 0.04 | 1.64 |
| 1.49 | 19.98 | 3.24 | 1.65 | 0.05 | 1.48 |
| 0.66 | 19.95 | 0.01 | 0.75 | 0.05 | 1.73 |
| 1.26 | 18.38 | 0.01 | 0.77 | 0.06 | 1.37 |
