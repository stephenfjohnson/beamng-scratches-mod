# sideslide - 20261114-224802_sideslide_synth-full-d3d12-endurance_r37

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: True after 4.651 s - 287 frames, 62.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.174)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2255 | 407 | 94 | 88 | 156 | 88 | 118 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1021, BelowThresh 827

Body materials: METAL 281, PLASTIC 126

Surfaces: ASPHALT 407

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 6.611 | 18.565 | 30.113 |
| whole frame, ms | 11.221 (p50) | 29.079 | 39.243 |
| all GE Lua, ms | | 19.739 | 31.103 |
| physics + vehicle Lua, ms | | 0.102 | 2.325 |
| render, ms | | 2.088 | |

- Painter frames over 4 ms: 118; worst flush (project + bake) 2.667 ms, worst composite 0.1 ms.
- Detector: 1.393 us per contact, 6.083 ms total, worst frame 0.4 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 39.24 | 30.11 | 2.01 | 0.07 | 1.79 |
| 0.21 | 37.19 | 29.27 | 31.10 | 0.07 | 1.86 |
| 2.96 | 32.46 | 17.43 | 18.11 | 0.06 | 1.84 |
| 0.27 | 31.08 | 24.27 | 20.48 | 0.07 | 1.43 |
| 2.61 | 31.02 | 16.99 | 17.47 | 0.06 | 1.44 |
