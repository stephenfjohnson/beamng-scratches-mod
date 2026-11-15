# roofdrop - 20261114-202642_roofdrop_resumed-fixed2-full-vulkan-endurance_r35

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 5.426 s - 406 frames, 74.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1127 | 52 | 52 | 0 | 54 | 19 | 25 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 642, BelowThresh 433

Body materials: METAL 50, PLASTIC 2

Surfaces: ASPHALT 52

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.652 | 5.318 | 36.669 |
| whole frame, ms | 12.628 (p50) | 17.927 | 49.677 |
| all GE Lua, ms | | 6.322 | 37.636 |
| physics + vehicle Lua, ms | | 0.084 | 0.305 |
| render, ms | | 2.22 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 36.642 ms, worst composite 0.073 ms.
- Detector: 1.602 us per contact, 4.179 ms total, worst frame 0.457 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.32 | 49.68 | 36.67 | 0.95 | 0.05 | 1.50 |
| 2.21 | 49.17 | 35.80 | 0.76 | 0.07 | 1.52 |
| 2.48 | 48.45 | 34.35 | 0.83 | 0.07 | 1.47 |
| 1.13 | 48.42 | 35.47 | 0.88 | 0.08 | 1.53 |
| 0.80 | 48.01 | 35.73 | 0.87 | 0.10 | 2.11 |
