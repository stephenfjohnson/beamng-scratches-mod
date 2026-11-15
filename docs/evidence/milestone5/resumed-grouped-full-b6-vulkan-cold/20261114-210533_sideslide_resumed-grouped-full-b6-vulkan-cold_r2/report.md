# sideslide - 20261114-210533_sideslide_resumed-grouped-full-b6-vulkan-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.585 s - 340 frames, 63.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.153)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2583 | 617 | 100 | 128 | 117 | 119 | 87 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1187, BelowThresh 776, NormalForce 3

Body materials: METAL 462, PLASTIC 155

Surfaces: ASPHALT 617

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 5.333 | 27.815 | 39.744 |
| whole frame, ms | 12.273 (p50) | 34.457 | 52.771 |
| all GE Lua, ms | | 28.701 | 40.899 |
| physics + vehicle Lua, ms | | 0.135 | 1.179 |
| render, ms | | 1.656 | |

- Painter frames over 4 ms: 105; worst flush (project + bake) 39.727 ms, worst composite 0.076 ms.
- Detector: 1.782 us per contact, 9.502 ms total, worst frame 0.651 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 52.77 | 39.74 | 0.75 | 0.07 | 1.87 |
| 2.02 | 49.89 | 39.40 | 0.72 | 0.06 | 1.19 |
| 1.96 | 45.94 | 30.13 | 0.75 | 0.04 | 1.40 |
| 3.80 | 45.35 | 34.20 | 0.87 | 0.05 | 1.23 |
| 1.65 | 45.17 | 28.71 | 0.79 | 0.03 | 1.28 |
