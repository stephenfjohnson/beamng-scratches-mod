# sideslide - 20261114-224545_sideslide_synth-full-d3d12-endurance_r28

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.213 s - 251 frames, 60.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.165)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2009 | 439 | 88 | 87 | 152 | 76 | 113 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 869, BelowThresh 700, NormalForce 1

Body materials: METAL 328, PLASTIC 111

Surfaces: ASPHALT 439

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.27 | 18.553 | 30.124 |
| whole frame, ms | 12.046 (p50) | 27.743 | 40.25 |
| all GE Lua, ms | | 19.526 | 31.074 |
| physics + vehicle Lua, ms | | 0.105 | 1.257 |
| render, ms | | 2.166 | |

- Painter frames over 4 ms: 113; worst flush (project + bake) 3.626 ms, worst composite 2.521 ms.
- Detector: 1.473 us per contact, 5.71 ms total, worst frame 0.4 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 40.25 | 30.12 | 1.95 | 0.07 | 1.88 |
| 2.17 | 38.70 | 29.27 | 17.51 | 0.06 | 1.73 |
| 1.74 | 31.89 | 17.35 | 18.38 | 0.05 | 1.68 |
| 0.86 | 30.89 | 15.99 | 17.17 | 0.10 | 1.50 |
| 2.36 | 30.56 | 16.60 | 16.92 | 0.06 | 1.55 |
