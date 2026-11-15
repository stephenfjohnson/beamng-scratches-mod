# sideslide - 20261114-201140_sideslide_resumed-fixed2-full-vulkan-cold_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.291 s - 308 frames, 60.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2551 | 533 | 96 | 113 | 128 | 100 | 129 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1354, BelowThresh 661, NormalForce 3

Body materials: METAL 396, PLASTIC 137

Surfaces: ASPHALT 533

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.433 | 20.002 | 70.575 |
| whole frame, ms | 13.833 (p50) | 29.725 | 81.01 |
| all GE Lua, ms | | 21.031 | 71.579 |
| physics + vehicle Lua, ms | | 0.119 | 0.321 |
| render, ms | | 1.951 | |

- Painter frames over 4 ms: 61; worst flush (project + bake) 70.553 ms, worst composite 0.108 ms.
- Detector: 1.747 us per contact, 10.133 ms total, worst frame 0.945 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.24 | 81.01 | 70.58 | 0.98 | 0.05 | 1.63 |
| 0.33 | 71.43 | 57.28 | 2.92 | 0.06 | 1.73 |
| 0.18 | 56.18 | 42.57 | 1.16 | 0.10 | 2.31 |
| 0.45 | 43.39 | 30.17 | 2.00 | 0.06 | 1.40 |
| 0.61 | 40.22 | 31.81 | 0.84 | 0.08 | 1.55 |
