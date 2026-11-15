# sideslide - 20261114-194132_sideslide_resumed-selected-half-vulkan-endurance_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.311 s - 316 frames, 73.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.172)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2250 | 550 | 104 | 117 | 138 | 102 | 157 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1070, BelowThresh 626, NormalForce 4

Body materials: METAL 402, PLASTIC 148

Surfaces: ASPHALT 550

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.019 | 33.77 | 39.799 |
| whole frame, ms | 9.51 (p50) | 42.688 | 51.03 |
| all GE Lua, ms | | 34.743 | 40.593 |
| physics + vehicle Lua, ms | | 0.084 | 0.185 |
| render, ms | | 1.741 | |

- Painter frames over 4 ms: 47; worst flush (project + bake) 39.774 ms, worst composite 0.058 ms.
- Detector: 1.591 us per contact, 7.32 ms total, worst frame 0.322 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.34 | 51.03 | 39.80 | 1.49 | 0.04 | 1.40 |
| 0.52 | 49.06 | 36.72 | 1.44 | 0.05 | 1.49 |
| 1.51 | 48.58 | 37.02 | 1.66 | 0.04 | 1.42 |
| 1.68 | 48.58 | 36.63 | 0.91 | 0.04 | 1.28 |
| 2.14 | 47.79 | 36.00 | 1.55 | 0.04 | 1.20 |
