# sideslide - 20261114-223704_sideslide_synth-full-d3d12-warm_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.115 s - 235 frames, 57.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.157)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2557 | 460 | 77 | 92 | 136 | 90 | 114 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1474, BelowThresh 620, NormalForce 3

Body materials: METAL 341, PLASTIC 119

Surfaces: ASPHALT 460

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.716 | 18.96 | 24.198 |
| whole frame, ms | 12.828 (p50) | 29.433 | 34.855 |
| all GE Lua, ms | | 19.943 | 25.252 |
| physics + vehicle Lua, ms | | 0.104 | 1.684 |
| render, ms | | 2.216 | |

- Painter frames over 4 ms: 114; worst flush (project + bake) 2.551 ms, worst composite 0.12 ms.
- Detector: 1.328 us per contact, 6.637 ms total, worst frame 0.52 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 34.86 | 24.20 | 1.53 | 0.05 | 2.00 |
| 0.90 | 32.16 | 16.79 | 19.99 | 0.12 | 2.10 |
| 1.09 | 32.01 | 19.76 | 20.40 | 0.11 | 2.71 |
| 3.01 | 31.55 | 18.23 | 17.61 | 0.06 | 1.77 |
| 0.58 | 31.36 | 16.04 | 17.37 | 0.10 | 1.54 |
