# sideslide - 20261114-224716_sideslide_synth-full-d3d12-endurance_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.087 s - 244 frames, 60.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.159)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2583 | 436 | 73 | 86 | 130 | 79 | 108 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1486, BelowThresh 661

Body materials: METAL 323, PLASTIC 113

Surfaces: ASPHALT 436

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 7.022 | 18.211 | 26.36 |
| whole frame, ms | 11.516 (p50) | 29.113 | 33.926 |
| all GE Lua, ms | | 19.26 | 27.283 |
| physics + vehicle Lua, ms | | 0.103 | 1.576 |
| render, ms | | 2.06 | |

- Painter frames over 4 ms: 108; worst flush (project + bake) 2.646 ms, worst composite 0.1 ms.
- Detector: 1.244 us per contact, 6.094 ms total, worst frame 0.424 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.22 | 33.93 | 26.36 | 19.47 | 0.08 | 1.83 |
| 0.50 | 31.48 | 16.57 | 21.41 | 0.06 | 1.52 |
| 2.22 | 30.96 | 16.50 | 19.78 | 0.08 | 1.89 |
| 2.66 | 30.58 | 16.55 | 17.98 | 0.10 | 2.26 |
| 2.03 | 30.11 | 16.32 | 18.42 | 0.06 | 1.64 |
