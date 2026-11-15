# sideslide - 20261114-185156_sideslide_resumed-selected-half-d3d12-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.267 s - 321 frames, 75.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.191)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2727 | 561 | 101 | 110 | 123 | 94 | 143 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1496, BelowThresh 669, NormalForce 1

Body materials: METAL 401, PLASTIC 160

Surfaces: ASPHALT 561

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.944 | 26.785 | 33.655 |
| whole frame, ms | 10.504 (p50) | 33.529 | 42.985 |
| all GE Lua, ms | | 27.856 | 34.868 |
| physics + vehicle Lua, ms | | 0.097 | 0.224 |
| render, ms | | 2.297 | |

- Painter frames over 4 ms: 97; worst flush (project + bake) 33.627 ms, worst composite 0.105 ms.
- Detector: 1.371 us per contact, 7.133 ms total, worst frame 0.327 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 42.98 | 30.54 | 1.33 | 0.09 | 2.10 |
| 2.67 | 40.98 | 33.66 | 1.02 | 0.04 | 1.76 |
| 0.66 | 40.91 | 33.33 | 2.28 | 0.06 | 1.79 |
| 1.40 | 38.46 | 31.83 | 0.79 | 0.05 | 1.48 |
| 1.19 | 37.57 | 30.59 | 0.88 | 0.04 | 1.66 |
