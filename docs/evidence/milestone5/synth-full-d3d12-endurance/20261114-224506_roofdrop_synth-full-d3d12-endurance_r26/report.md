# roofdrop - 20261114-224506_roofdrop_synth-full-d3d12-endurance_r26

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.997 s - 436 frames, 86.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1197 | 46 | 46 | 0 | 50 | 14 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 681, BelowThresh 470

Body materials: METAL 44, PLASTIC 2

Surfaces: ASPHALT 46

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.749 | 5.852 | 22.499 |
| whole frame, ms | 11.264 (p50) | 14.573 | 30.607 |
| all GE Lua, ms | | 6.624 | 23.336 |
| physics + vehicle Lua, ms | | 0.076 | 0.276 |
| render, ms | | 2.261 | |

- Painter frames over 4 ms: 23; worst flush (project + bake) 1.1 ms, worst composite 0.09 ms.
- Detector: 1.341 us per contact, 3.772 ms total, worst frame 0.392 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.90 | 30.61 | 22.50 | 21.80 | 0.08 | 1.87 |
| 2.26 | 30.20 | 19.01 | 1.34 | 0.03 | 1.90 |
| 0.89 | 28.80 | 20.60 | 19.28 | 0.07 | 2.22 |
| 1.52 | 28.53 | 17.40 | 1.75 | 0.05 | 1.77 |
| 1.53 | 27.66 | 19.87 | 18.25 | 0.05 | 2.08 |
