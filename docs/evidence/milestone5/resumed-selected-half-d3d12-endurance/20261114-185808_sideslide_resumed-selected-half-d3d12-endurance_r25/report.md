# sideslide - 20261114-185808_sideslide_resumed-selected-half-d3d12-endurance_r25

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.214 s - 324 frames, 76.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.155)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3001 | 600 | 79 | 127 | 114 | 109 | 146 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1620, BelowThresh 779, NormalForce 2

Body materials: METAL 435, PLASTIC 165

Surfaces: ASPHALT 600

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.983 | 24.725 | 34.218 |
| whole frame, ms | 10.372 (p50) | 31.949 | 42.463 |
| all GE Lua, ms | | 25.925 | 35.213 |
| physics + vehicle Lua, ms | | 0.096 | 0.155 |
| render, ms | | 2.213 | |

- Painter frames over 4 ms: 99; worst flush (project + bake) 34.175 ms, worst composite 0.155 ms.
- Detector: 1.344 us per contact, 7.56 ms total, worst frame 0.357 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.18 | 42.46 | 31.41 | 0.87 | 0.06 | 1.78 |
| 2.80 | 40.63 | 34.22 | 0.97 | 0.03 | 1.48 |
| 3.32 | 39.92 | 28.59 | 0.99 | 0.05 | 1.49 |
| 1.45 | 39.85 | 32.70 | 0.76 | 0.04 | 1.59 |
| 0.95 | 38.78 | 32.35 | 0.91 | 0.04 | 1.75 |
