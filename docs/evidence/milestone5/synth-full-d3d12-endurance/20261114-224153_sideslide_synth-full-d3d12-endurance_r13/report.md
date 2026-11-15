# sideslide - 20261114-224153_sideslide_synth-full-d3d12-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.266 s - 230 frames, 55.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.17)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2113 | 378 | 100 | 86 | 159 | 74 | 118 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1154, BelowThresh 578, NormalForce 3

Body materials: METAL 277, PLASTIC 101

Surfaces: ASPHALT 378

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 8.35 | 19.774 | 25.584 |
| whole frame, ms | 13.942 (p50) | 30.646 | 35.701 |
| all GE Lua, ms | | 20.911 | 26.68 |
| physics + vehicle Lua, ms | | 0.543 | 1.593 |
| render, ms | | 2.523 | |

- Painter frames over 4 ms: 118; worst flush (project + bake) 3.177 ms, worst composite 0.144 ms.
- Detector: 1.372 us per contact, 6.111 ms total, worst frame 0.426 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 35.70 | 25.58 | 2.26 | 0.17 | 2.18 |
| 0.55 | 34.57 | 17.92 | 18.73 | 0.12 | 1.89 |
| 2.11 | 33.92 | 21.90 | 3.95 | 0.91 | 2.75 |
| 1.55 | 33.48 | 22.01 | 4.58 | 1.09 | 2.68 |
| 2.17 | 33.05 | 19.56 | 23.41 | 0.11 | 2.42 |
