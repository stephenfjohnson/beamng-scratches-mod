# sideslide - 20261114-190028_sideslide_resumed-selected-half-d3d12-endurance_r34

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.184 s - 321 frames, 75.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.172)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2934 | 549 | 100 | 115 | 121 | 92 | 145 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1661, BelowThresh 721, NormalForce 3

Body materials: METAL 399, PLASTIC 150

Surfaces: ASPHALT 549

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.629 | 23.876 | 37.279 |
| whole frame, ms | 10.796 (p50) | 32.043 | 46.844 |
| all GE Lua, ms | | 25.118 | 38.294 |
| physics + vehicle Lua, ms | | 0.099 | 0.185 |
| render, ms | | 2.531 | |

- Painter frames over 4 ms: 93; worst flush (project + bake) 37.25 ms, worst composite 0.158 ms.
- Detector: 1.324 us per contact, 7.466 ms total, worst frame 0.483 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 46.84 | 36.28 | 0.81 | 0.05 | 1.87 |
| 1.42 | 43.74 | 37.28 | 0.82 | 0.04 | 1.43 |
| 2.01 | 40.19 | 34.16 | 0.71 | 0.03 | 1.51 |
| 1.36 | 39.08 | 32.69 | 0.80 | 0.05 | 1.48 |
| 1.15 | 39.02 | 31.42 | 0.81 | 0.04 | 1.90 |
