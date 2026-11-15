# sideslide - 20261114-185416_sideslide_resumed-selected-half-d3d12-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.089 s - 319 frames, 71.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.161)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3103 | 596 | 88 | 121 | 117 | 99 | 140 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1778, BelowThresh 726, NormalForce 3

Body materials: METAL 442, PLASTIC 154

Surfaces: ASPHALT 596

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.633 | 26.598 | 35.894 |
| whole frame, ms | 10.146 (p50) | 34.07 | 458.295 |
| all GE Lua, ms | | 27.492 | 36.631 |
| physics + vehicle Lua, ms | | 0.088 | 0.182 |
| render, ms | | 2.16 | |

- Painter frames over 4 ms: 87; worst flush (project + bake) 35.868 ms, worst composite 0.109 ms.
- Detector: 1.303 us per contact, 7.461 ms total, worst frame 0.438 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.11 | 458.29 | 1.24 | 9.23 | 0.06 | 1.71 |
| 0.18 | 43.37 | 30.56 | 0.78 | 0.07 | 2.11 |
| 1.95 | 42.17 | 35.89 | 1.08 | 0.04 | 1.38 |
| 1.71 | 41.28 | 35.15 | 0.84 | 0.03 | 1.53 |
| 2.95 | 40.86 | 34.77 | 0.83 | 0.05 | 1.49 |
