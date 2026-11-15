# roofdrop - 20261114-222238_roofdrop_synth-full-vk-endurance_r17

_dropped upside down from about 1 m - roof impacts_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 5.322 s - 417 frames, 78.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1043 | 51 | 51 | 0 | 59 | 16 | 26 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 625, BelowThresh 367

Body materials: METAL 49, PLASTIC 2

Surfaces: ASPHALT 51

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.195 | 1.36 | 4.841 |
| whole frame, ms | 12.807 (p50) | 15.302 | 22.109 |
| all GE Lua, ms | | 2.458 | 5.921 |
| physics + vehicle Lua, ms | | 0.071 | 0.186 |
| render, ms | | 1.654 | |

- Painter frames over 4 ms: 3; worst flush (project + bake) 1.168 ms, worst composite 0.056 ms.
- Detector: 1.351 us per contact, 3.981 ms total, worst frame 0.412 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.56 | 22.11 | 0.01 | 0.98 | 0.05 | 2.12 |
| 0.89 | 21.40 | 2.99 | 4.18 | 0.06 | 1.44 |
| 1.48 | 19.58 | 3.36 | 1.92 | 0.07 | 1.78 |
| 2.28 | 19.34 | 0.01 | 5.32 | 0.05 | 1.25 |
| 0.66 | 19.01 | 0.01 | 0.79 | 0.05 | 1.38 |
