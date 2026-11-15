# sideslide - 20261114-191106_sideslide_resumed-selected-half-d3d12-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.161 s - 383 frames, 77.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.151)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3452 | 881 | 78 | 158 | 93 | 109 | 168 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1856, BelowThresh 708, NormalForce 7

Body materials: METAL 666, PLASTIC 215

Surfaces: ASPHALT 881

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.244 | 29.569 | 44.052 |
| whole frame, ms | 10.122 (p50) | 35.517 | 52.191 |
| all GE Lua, ms | | 30.283 | 44.91 |
| physics + vehicle Lua, ms | | 0.085 | 0.181 |
| render, ms | | 1.939 | |

- Painter frames over 4 ms: 127; worst flush (project + bake) 44.023 ms, worst composite 0.126 ms.
- Detector: 1.569 us per contact, 10.959 ms total, worst frame 0.629 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.51 | 52.19 | 44.05 | 0.90 | 0.05 | 1.43 |
| 0.18 | 46.12 | 32.86 | 1.29 | 0.06 | 3.12 |
| 1.98 | 45.76 | 37.14 | 0.72 | 0.04 | 1.37 |
| 0.57 | 45.40 | 38.77 | 1.13 | 0.06 | 1.63 |
| 1.66 | 45.08 | 37.25 | 0.91 | 0.03 | 1.61 |
