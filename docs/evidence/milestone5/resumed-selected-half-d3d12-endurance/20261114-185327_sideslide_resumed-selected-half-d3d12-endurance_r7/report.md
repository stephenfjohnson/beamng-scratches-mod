# sideslide - 20261114-185327_sideslide_resumed-selected-half-d3d12-endurance_r7

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 6.528 s - 532 frames, 81.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.152)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 4538 | 575 | 113 | 122 | 123 | 106 | 151 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 2040, BelowThresh 1923

Body materials: METAL 432, PLASTIC 143

Surfaces: ASPHALT 575

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.11 | 20.732 | 36.806 |
| whole frame, ms | 10.648 (p50) | 29.065 | 43.151 |
| all GE Lua, ms | | 21.858 | 37.807 |
| physics + vehicle Lua, ms | | 0.09 | 0.309 |
| render, ms | | 2.211 | |

- Painter frames over 4 ms: 101; worst flush (project + bake) 36.782 ms, worst composite 0.145 ms.
- Detector: 1.208 us per contact, 10.609 ms total, worst frame 0.362 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.97 | 43.15 | 36.81 | 0.93 | 0.05 | 1.62 |
| 2.51 | 42.80 | 31.92 | 1.59 | 0.09 | 2.53 |
| 1.41 | 42.61 | 36.04 | 0.99 | 0.04 | 1.64 |
| 0.18 | 41.97 | 31.13 | 0.76 | 0.05 | 1.84 |
| 0.60 | 41.38 | 34.45 | 0.98 | 0.06 | 1.87 |
