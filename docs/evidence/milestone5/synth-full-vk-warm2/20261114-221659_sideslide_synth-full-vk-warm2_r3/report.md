# sideslide - 20261114-221659_sideslide_synth-full-vk-warm2_r3

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.166 s - 325 frames, 77.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.164)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2706 | 716 | 81 | 128 | 110 | 100 | 132 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1377, BelowThresh 610, NormalForce 3

Body materials: METAL 532, PLASTIC 184

Surfaces: ASPHALT 716

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.352 | 3.975 | 5.848 |
| whole frame, ms | 12.24 (p50) | 18.792 | 25.497 |
| all GE Lua, ms | | 5.03 | 7.022 |
| physics + vehicle Lua, ms | | 0.088 | 0.191 |
| render, ms | | 1.883 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 2.661 ms, worst composite 0.22 ms.
- Detector: 1.643 us per contact, 8.61 ms total, worst frame 0.389 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.43 | 25.50 | 3.14 | 4.68 | 0.06 | 2.63 |
| 0.45 | 21.60 | 2.70 | 4.35 | 0.09 | 2.20 |
| 0.39 | 21.51 | 5.85 | 4.33 | 0.08 | 1.56 |
| 2.21 | 20.97 | 0.60 | 0.82 | 0.04 | 1.34 |
| 3.23 | 20.53 | 3.84 | 2.73 | 0.07 | 2.18 |
