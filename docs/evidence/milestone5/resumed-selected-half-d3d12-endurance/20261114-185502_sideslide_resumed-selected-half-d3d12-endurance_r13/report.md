# sideslide - 20261114-185502_sideslide_resumed-selected-half-d3d12-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.159 s - 315 frames, 75.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.155)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3033 | 696 | 70 | 125 | 86 | 92 | 135 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1658, BelowThresh 677, NormalForce 2

Body materials: METAL 515, PLASTIC 181

Surfaces: ASPHALT 696

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.328 | 23.959 | 32.756 |
| whole frame, ms | 10.678 (p50) | 32.164 | 41.292 |
| all GE Lua, ms | | 25.172 | 33.784 |
| physics + vehicle Lua, ms | | 0.099 | 0.2 |
| render, ms | | 2.376 | |

- Painter frames over 4 ms: 79; worst flush (project + bake) 32.706 ms, worst composite 0.126 ms.
- Detector: 1.595 us per contact, 8.489 ms total, worst frame 0.321 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 41.29 | 29.92 | 0.91 | 0.11 | 1.95 |
| 1.66 | 40.98 | 32.76 | 1.03 | 0.05 | 2.00 |
| 3.18 | 39.72 | 30.48 | 0.72 | 0.04 | 1.88 |
| 0.24 | 38.62 | 31.97 | 0.90 | 0.05 | 1.48 |
| 2.88 | 37.19 | 29.63 | 0.93 | 0.05 | 1.81 |
