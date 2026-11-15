# sideslide - 20261114-192333_sideslide_resumed-selected-half-vulkan-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.204 s - 368 frames, 74.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2815 | 704 | 99 | 138 | 94 | 104 | 153 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1439, BelowThresh 670, NormalForce 2

Body materials: METAL 514, PLASTIC 190

Surfaces: ASPHALT 704

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.484 | 33.968 | 52.502 |
| whole frame, ms | 9.4 (p50) | 43.633 | 59.619 |
| all GE Lua, ms | | 34.975 | 53.412 |
| physics + vehicle Lua, ms | | 0.094 | 0.183 |
| render, ms | | 1.871 | |

- Painter frames over 4 ms: 52; worst flush (project + bake) 52.475 ms, worst composite 0.124 ms.
- Detector: 1.658 us per contact, 9.769 ms total, worst frame 0.537 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.32 | 59.62 | 52.50 | 5.51 | 0.06 | 1.39 |
| 0.18 | 55.99 | 42.83 | 1.11 | 0.07 | 2.12 |
| 0.45 | 50.90 | 38.80 | 1.69 | 0.05 | 1.37 |
| 2.55 | 48.10 | 35.52 | 1.36 | 0.06 | 1.22 |
| 1.18 | 47.04 | 36.41 | 0.95 | 0.04 | 1.25 |
