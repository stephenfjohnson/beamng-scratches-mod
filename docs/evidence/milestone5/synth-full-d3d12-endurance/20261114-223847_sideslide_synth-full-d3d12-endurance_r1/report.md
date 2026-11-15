# sideslide - 20261114-223847_sideslide_synth-full-d3d12-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.551 s - 239 frames, 54.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.173)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 1796 | 342 | 128 | 73 | 195 | 66 | 118 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 911, BelowThresh 543

Body materials: METAL 252, PLASTIC 90

Surfaces: ASPHALT 342

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 8.468 | 19.392 | 30.037 |
| whole frame, ms | 15.276 (p50) | 30.93 | 39.172 |
| all GE Lua, ms | | 20.404 | 30.922 |
| physics + vehicle Lua, ms | | 0.121 | 2.266 |
| render, ms | | 2.499 | |

- Painter frames over 4 ms: 118; worst flush (project + bake) 2.62 ms, worst composite 0.102 ms.
- Detector: 1.451 us per contact, 5.666 ms total, worst frame 0.375 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 39.17 | 28.16 | 1.36 | 0.06 | 1.70 |
| 0.37 | 36.01 | 30.04 | 2.57 | 0.04 | 1.38 |
| 1.21 | 36.00 | 17.83 | 25.66 | 0.07 | 2.88 |
| 1.85 | 35.40 | 17.73 | 19.64 | 0.06 | 2.20 |
| 0.39 | 34.45 | 20.51 | 30.92 | 0.05 | 1.56 |
