# sideslide - 20261114-221026_sideslide_synth-full-vk-cold_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.294 s - 387 frames, 79.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.165)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2899 | 682 | 102 | 137 | 118 | 108 | 139 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1456, BelowThresh 759, NormalForce 2

Body materials: METAL 509, PLASTIC 173

Surfaces: ASPHALT 682

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.251 | 3.587 | 14.599 |
| whole frame, ms | 11.951 (p50) | 19.005 | 25.803 |
| all GE Lua, ms | | 4.744 | 15.497 |
| physics + vehicle Lua, ms | | 0.09 | 0.395 |
| render, ms | | 1.919 | |

- Painter frames over 4 ms: 12; worst flush (project + bake) 2.702 ms, worst composite 0.108 ms.
- Detector: 1.652 us per contact, 9.783 ms total, worst frame 0.778 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.32 | 25.80 | 14.60 | 2.82 | 0.08 | 1.44 |
| 1.07 | 25.15 | 2.67 | 1.58 | 0.04 | 1.35 |
| 0.33 | 24.96 | 12.26 | 15.50 | 0.05 | 1.55 |
| 2.34 | 24.45 | 2.59 | 6.08 | 0.05 | 1.93 |
| 1.12 | 24.45 | 3.02 | 1.23 | 0.06 | 1.32 |
