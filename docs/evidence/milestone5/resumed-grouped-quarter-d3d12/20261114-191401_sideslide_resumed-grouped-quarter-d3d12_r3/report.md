# sideslide - 20261114-191401_sideslide_resumed-grouped-quarter-d3d12_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.17 s - 336 frames, 79.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.155)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3075 | 752 | 73 | 132 | 97 | 100 | 147 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1593, BelowThresh 721, NormalForce 9

Body materials: METAL 552, PLASTIC 200

Surfaces: ASPHALT 752

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.108 | 25.681 | 35.233 |
| whole frame, ms | 10.171 (p50) | 32.542 | 46.125 |
| all GE Lua, ms | | 26.695 | 36.49 |
| physics + vehicle Lua, ms | | 0.096 | 0.198 |
| render, ms | | 2.313 | |

- Painter frames over 4 ms: 48; worst flush (project + bake) 35.197 ms, worst composite 0.097 ms.
- Detector: 1.789 us per contact, 10.382 ms total, worst frame 0.519 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.13 | 35.23 | 0.98 | 0.06 | 2.29 |
| 1.87 | 40.82 | 30.46 | 0.88 | 0.05 | 1.90 |
| 1.93 | 38.45 | 30.84 | 0.92 | 0.09 | 1.62 |
| 3.11 | 38.18 | 29.36 | 1.00 | 0.05 | 1.87 |
| 0.33 | 37.28 | 30.05 | 2.52 | 0.05 | 2.07 |
