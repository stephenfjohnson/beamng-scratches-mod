# sideslide - 20261114-222757_sideslide_synth-full-vk-endurance_r37

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.082 s - 315 frames, 76.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.141)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2950 | 762 | 74 | 137 | 105 | 111 | 135 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1538, BelowThresh 645, NormalForce 5

Body materials: METAL 578, PLASTIC 184

Surfaces: ASPHALT 762

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.395 | 3.924 | 9.524 |
| whole frame, ms | 12.6 (p50) | 18.665 | 21.239 |
| all GE Lua, ms | | 5.052 | 10.587 |
| physics + vehicle Lua, ms | | 0.088 | 0.189 |
| render, ms | | 1.92 | |

- Painter frames over 4 ms: 16; worst flush (project + bake) 2.046 ms, worst composite 0.082 ms.
- Detector: 1.598 us per contact, 8.867 ms total, worst frame 0.56 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.99 | 21.24 | 4.97 | 3.51 | 0.05 | 2.03 |
| 1.20 | 21.19 | 5.17 | 3.77 | 0.05 | 1.56 |
| 2.53 | 21.01 | 1.17 | 3.63 | 0.06 | 1.69 |
| 2.86 | 20.78 | 2.89 | 1.28 | 0.04 | 1.41 |
| 1.93 | 20.77 | 2.47 | 6.14 | 0.05 | 1.23 |
