# sideslide - 20261114-191313_sideslide_resumed-grouped-quarter-d3d12_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.069 s - 325 frames, 79.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.16)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3102 | 668 | 85 | 124 | 108 | 104 | 146 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1726, BelowThresh 705, NormalForce 3

Body materials: METAL 499, PLASTIC 169

Surfaces: ASPHALT 668

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.692 | 28.581 | 40.403 |
| whole frame, ms | 9.701 (p50) | 34.937 | 48.417 |
| all GE Lua, ms | | 29.56 | 41.437 |
| physics + vehicle Lua, ms | | 0.085 | 0.123 |
| render, ms | | 1.944 | |

- Painter frames over 4 ms: 52; worst flush (project + bake) 40.375 ms, worst composite 0.112 ms.
- Detector: 1.429 us per contact, 8.315 ms total, worst frame 0.425 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 48.42 | 36.20 | 1.07 | 0.08 | 1.83 |
| 2.06 | 47.65 | 39.33 | 1.81 | 0.04 | 1.73 |
| 0.29 | 47.60 | 40.40 | 1.98 | 0.04 | 1.99 |
| 1.52 | 43.76 | 37.61 | 1.67 | 0.04 | 1.70 |
| 0.46 | 40.97 | 33.94 | 3.44 | 0.06 | 1.79 |
