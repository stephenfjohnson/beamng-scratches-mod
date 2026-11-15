# roofdrop - 20261114-222803_roofdrop_synth-full-vk-endurance_r38

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 6.494 s - 508 frames, 78.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1393 | 58 | 58 | 0 | 52 | 16 | 23 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 847, BelowThresh 488

Body materials: METAL 57, PLASTIC 1

Surfaces: ASPHALT 58

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.164 | 0.786 | 9.147 |
| whole frame, ms | 12.814 (p50) | 14.846 | 26.003 |
| all GE Lua, ms | | 1.561 | 10.075 |
| physics + vehicle Lua, ms | | 0.072 | 0.148 |
| render, ms | | 1.734 | |

- Painter frames over 4 ms: 5; worst flush (project + bake) 0.975 ms, worst composite 0.075 ms.
- Detector: 1.293 us per contact, 4.67 ms total, worst frame 0.463 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.61 | 26.00 | 6.68 | 5.95 | 0.05 | 1.66 |
| 0.54 | 21.38 | 9.15 | 1.67 | 0.15 | 1.53 |
| 1.25 | 18.96 | 0.01 | 0.87 | 0.06 | 1.51 |
| 0.94 | 18.63 | 0.01 | 0.85 | 0.04 | 1.47 |
| 0.60 | 18.18 | 4.99 | 1.56 | 0.15 | 1.33 |
