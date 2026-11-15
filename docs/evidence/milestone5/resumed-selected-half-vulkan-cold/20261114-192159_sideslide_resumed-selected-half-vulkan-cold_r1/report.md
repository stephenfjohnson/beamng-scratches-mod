# sideslide - 20261114-192159_sideslide_resumed-selected-half-vulkan-cold_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.234 s - 378 frames, 74.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2579 | 734 | 85 | 133 | 104 | 104 | 157 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1171, BelowThresh 668, NormalForce 6

Body materials: METAL 550, PLASTIC 184

Surfaces: ASPHALT 734

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.617 | 34.983 | 40.175 |
| whole frame, ms | 8.869 (p50) | 45.134 | 51.065 |
| all GE Lua, ms | | 35.75 | 41.156 |
| physics + vehicle Lua, ms | | 0.091 | 0.642 |
| render, ms | | 1.858 | |

- Painter frames over 4 ms: 55; worst flush (project + bake) 40.137 ms, worst composite 0.067 ms.
- Detector: 1.797 us per contact, 10.794 ms total, worst frame 0.645 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.71 | 51.06 | 38.94 | 0.86 | 0.03 | 1.45 |
| 1.44 | 49.74 | 37.79 | 0.94 | 0.04 | 1.38 |
| 0.48 | 49.05 | 37.38 | 1.71 | 0.08 | 1.40 |
| 0.64 | 48.28 | 37.00 | 0.88 | 0.07 | 1.30 |
| 2.38 | 47.86 | 38.96 | 1.83 | 0.07 | 1.33 |
