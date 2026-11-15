# sideslide - 20261114-221325_sideslide_synth-full-vk-warm_r2

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.11 s - 298 frames, 72.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.142)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2884 | 630 | 75 | 125 | 112 | 113 | 130 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1550, BelowThresh 703, NormalForce 1

Body materials: METAL 469, PLASTIC 161

Surfaces: ASPHALT 630

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.623 | 4.311 | 16.283 |
| whole frame, ms | 13.389 (p50) | 21.138 | 30.399 |
| all GE Lua, ms | | 5.83 | 17.211 |
| physics + vehicle Lua, ms | | 0.103 | 0.165 |
| render, ms | | 1.891 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 3.108 ms, worst composite 0.099 ms.
- Detector: 1.547 us per contact, 10.036 ms total, worst frame 1.479 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.34 | 30.40 | 16.28 | 3.72 | 0.05 | 1.70 |
| 2.29 | 24.85 | 5.27 | 5.29 | 0.07 | 1.39 |
| 0.20 | 24.48 | 14.74 | 2.07 | 0.06 | 1.41 |
| 0.27 | 23.80 | 3.62 | 2.63 | 0.09 | 2.29 |
| 2.27 | 23.46 | 2.93 | 3.91 | 0.07 | 1.36 |
