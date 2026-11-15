# roofdrop - 20261114-224245_roofdrop_synth-full-d3d12-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.406 s - 559 frames, 86.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1549 | 51 | 51 | 0 | 50 | 16 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 950, BelowThresh 548

Body materials: METAL 50, PLASTIC 1

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.565 | 0.531 | 22.858 |
| whole frame, ms | 11.353 (p50) | 14.222 | 30.186 |
| all GE Lua, ms | | 1.56 | 23.783 |
| physics + vehicle Lua, ms | | 0.068 | 0.176 |
| render, ms | | 2.075 | |

- Painter frames over 4 ms: 25; worst flush (project + bake) 1.119 ms, worst composite 0.067 ms.
- Detector: 1.264 us per contact, 4.559 ms total, worst frame 0.404 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.53 | 30.19 | 22.86 | 17.37 | 0.04 | 1.60 |
| 0.89 | 29.41 | 21.38 | 20.41 | 0.06 | 1.79 |
| 2.22 | 28.93 | 17.24 | 1.42 | 0.04 | 1.73 |
| 1.14 | 28.74 | 17.58 | 1.39 | 0.07 | 1.76 |
| 0.86 | 27.60 | 16.46 | 1.76 | 0.04 | 1.83 |
