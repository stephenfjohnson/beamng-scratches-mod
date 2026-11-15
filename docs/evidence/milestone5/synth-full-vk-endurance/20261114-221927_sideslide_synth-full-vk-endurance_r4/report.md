# sideslide - 20261114-221927_sideslide_synth-full-vk-endurance_r4

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.278 s - 328 frames, 76.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.189)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2407 | 608 | 103 | 116 | 120 | 101 | 127 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1199, BelowThresh 597, NormalForce 3

Body materials: METAL 444, PLASTIC 164

Surfaces: ASPHALT 608

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.354 | 4.187 | 8.113 |
| whole frame, ms | 12.366 (p50) | 19.371 | 26.025 |
| all GE Lua, ms | | 5.691 | 9.348 |
| physics + vehicle Lua, ms | | 0.1 | 0.174 |
| render, ms | | 2.033 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 2.319 ms, worst composite 0.107 ms.
- Detector: 1.661 us per contact, 8.636 ms total, worst frame 0.381 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.10 | 26.03 | 6.25 | 2.75 | 0.12 | 1.56 |
| 3.11 | 25.45 | 4.12 | 7.20 | 0.09 | 2.20 |
| 1.20 | 23.56 | 3.48 | 6.36 | 0.05 | 2.15 |
| 0.26 | 22.98 | 2.99 | 1.53 | 0.05 | 1.47 |
| 2.34 | 22.85 | 0.50 | 4.29 | 0.07 | 1.23 |
