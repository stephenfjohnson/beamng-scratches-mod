# sideslide - 20261114-185242_sideslide_resumed-selected-half-d3d12-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.129 s - 321 frames, 77.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.156)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3140 | 697 | 68 | 127 | 91 | 103 | 140 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1718, BelowThresh 718, NormalForce 7

Body materials: METAL 512, PLASTIC 185

Surfaces: ASPHALT 697

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.924 | 25.742 | 35.241 |
| whole frame, ms | 10.469 (p50) | 32.619 | 42.678 |
| all GE Lua, ms | | 26.728 | 36.29 |
| physics + vehicle Lua, ms | | 0.093 | 0.44 |
| render, ms | | 2.217 | |

- Painter frames over 4 ms: 100; worst flush (project + bake) 35.218 ms, worst composite 0.099 ms.
- Detector: 1.436 us per contact, 8.297 ms total, worst frame 0.352 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 42.68 | 31.76 | 0.75 | 0.05 | 1.84 |
| 0.62 | 41.43 | 35.24 | 0.84 | 0.44 | 1.42 |
| 2.04 | 40.32 | 33.94 | 1.08 | 0.05 | 1.71 |
| 2.72 | 38.20 | 32.42 | 0.78 | 0.04 | 1.46 |
| 2.44 | 38.00 | 30.64 | 0.93 | 0.04 | 1.70 |
