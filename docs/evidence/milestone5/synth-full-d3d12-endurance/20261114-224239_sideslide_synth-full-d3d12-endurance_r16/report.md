# sideslide - 20261114-224239_sideslide_synth-full-d3d12-endurance_r16

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.169 s - 240 frames, 58.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.156)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2446 | 484 | 76 | 100 | 138 | 75 | 113 | 0.0% | 0 | 6 |

Rejected contacts: Wheel 1360, BelowThresh 601, NormalForce 1

Body materials: METAL 359, PLASTIC 125

Surfaces: ASPHALT 484

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.625 | 18.119 | 25.199 |
| whole frame, ms | 12.14 (p50) | 28.556 | 34.931 |
| all GE Lua, ms | | 19.2 | 26.431 |
| physics + vehicle Lua, ms | | 0.103 | 1.397 |
| render, ms | | 2.091 | |

- Painter frames over 4 ms: 113; worst flush (project + bake) 2.68 ms, worst composite 0.185 ms.
- Detector: 1.308 us per contact, 6.164 ms total, worst frame 0.602 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.91 | 34.93 | 17.27 | 17.03 | 0.10 | 1.49 |
| 0.19 | 34.80 | 25.20 | 2.33 | 0.09 | 1.76 |
| 3.22 | 32.72 | 16.99 | 17.49 | 0.06 | 1.95 |
| 0.95 | 31.66 | 19.51 | 19.71 | 0.09 | 1.80 |
| 1.51 | 31.48 | 16.08 | 17.34 | 0.05 | 1.72 |
