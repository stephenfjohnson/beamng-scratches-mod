# sideslide - 20261114-185721_sideslide_resumed-selected-half-d3d12-endurance_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.106 s - 322 frames, 76.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.158)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3268 | 726 | 72 | 127 | 91 | 94 | 135 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1845, BelowThresh 693, NormalForce 4

Body materials: METAL 547, PLASTIC 179

Surfaces: ASPHALT 726

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.695 | 24.234 | 35.282 |
| whole frame, ms | 10.483 (p50) | 32.165 | 42.336 |
| all GE Lua, ms | | 25.707 | 36.205 |
| physics + vehicle Lua, ms | | 0.09 | 0.158 |
| render, ms | | 2.266 | |

- Painter frames over 4 ms: 96; worst flush (project + bake) 35.251 ms, worst composite 0.077 ms.
- Detector: 1.449 us per contact, 8.522 ms total, worst frame 0.391 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 42.34 | 29.74 | 0.94 | 0.08 | 2.17 |
| 2.41 | 41.08 | 35.28 | 1.00 | 0.05 | 1.54 |
| 1.90 | 38.90 | 32.44 | 0.95 | 0.04 | 1.47 |
| 2.57 | 38.81 | 32.94 | 0.87 | 0.05 | 1.48 |
| 1.40 | 38.17 | 31.55 | 1.05 | 0.04 | 1.43 |
