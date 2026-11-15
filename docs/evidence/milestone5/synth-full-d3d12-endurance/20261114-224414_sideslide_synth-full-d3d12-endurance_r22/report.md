# sideslide - 20261114-224414_sideslide_synth-full-d3d12-endurance_r22

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.161 s - 263 frames, 62.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.155)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2713 | 527 | 71 | 99 | 118 | 86 | 112 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1510, BelowThresh 671, NormalForce 5

Body materials: METAL 390, PLASTIC 137

Surfaces: ASPHALT 527

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 6.581 | 18.041 | 22.087 |
| whole frame, ms | 11.205 (p50) | 27.809 | 30.943 |
| all GE Lua, ms | | 19.0 | 23.274 |
| physics + vehicle Lua, ms | | 0.103 | 2.856 |
| render, ms | | 2.049 | |

- Painter frames over 4 ms: 112; worst flush (project + bake) 2.477 ms, worst composite 0.105 ms.
- Detector: 1.386 us per contact, 6.641 ms total, worst frame 0.34 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.56 | 30.94 | 15.97 | 17.88 | 0.06 | 1.46 |
| 1.94 | 30.51 | 15.47 | 17.87 | 0.06 | 1.47 |
| 0.53 | 30.41 | 16.17 | 17.04 | 0.06 | 1.63 |
| 2.80 | 30.26 | 16.38 | 16.74 | 0.08 | 2.14 |
| 0.74 | 30.21 | 15.67 | 16.61 | 0.06 | 1.50 |
