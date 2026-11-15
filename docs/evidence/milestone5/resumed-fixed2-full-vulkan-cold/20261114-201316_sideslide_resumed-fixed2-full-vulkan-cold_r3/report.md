# sideslide - 20261114-201316_sideslide_resumed-fixed2-full-vulkan-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.595 s - 322 frames, 60.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.172)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2297 | 535 | 98 | 116 | 127 | 103 | 129 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1001, BelowThresh 760, NormalForce 1

Body materials: METAL 365, PLASTIC 170

Surfaces: ASPHALT 535

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.164 | 18.418 | 47.551 |
| whole frame, ms | 13.977 (p50) | 31.74 | 61.72 |
| all GE Lua, ms | | 19.665 | 48.84 |
| physics + vehicle Lua, ms | | 0.126 | 0.245 |
| render, ms | | 2.205 | |

- Painter frames over 4 ms: 73; worst flush (project + bake) 47.525 ms, worst composite 0.133 ms.
- Detector: 2.589 us per contact, 11.623 ms total, worst frame 0.792 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.26 | 61.72 | 47.55 | 4.77 | 0.08 | 1.41 |
| 0.19 | 59.35 | 46.01 | 0.98 | 0.09 | 1.38 |
| 3.58 | 43.88 | 32.23 | 1.17 | 0.07 | 2.02 |
| 0.32 | 40.54 | 26.65 | 8.21 | 0.06 | 1.65 |
| 3.67 | 39.98 | 31.41 | 1.07 | 0.06 | 1.96 |
