# sideslide - 20261114-185635_sideslide_resumed-selected-half-d3d12-endurance_r19

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.256 s - 327 frames, 76.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.153)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 3069 | 640 | 94 | 131 | 117 | 105 | 158 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1706, BelowThresh 720, NormalForce 3

Body materials: METAL 478, PLASTIC 162

Surfaces: ASPHALT 640

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.836 | 25.597 | 38.433 |
| whole frame, ms | 10.544 (p50) | 32.762 | 47.796 |
| all GE Lua, ms | | 26.546 | 39.517 |
| physics + vehicle Lua, ms | | 0.088 | 0.211 |
| render, ms | | 2.207 | |

- Painter frames over 4 ms: 105; worst flush (project + bake) 38.41 ms, worst composite 0.098 ms.
- Detector: 1.459 us per contact, 8.144 ms total, worst frame 0.34 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.51 | 47.80 | 38.43 | 1.07 | 0.05 | 1.59 |
| 3.13 | 44.04 | 37.19 | 1.23 | 0.05 | 1.48 |
| 1.67 | 42.78 | 36.11 | 0.70 | 0.04 | 1.57 |
| 1.19 | 42.18 | 35.64 | 0.85 | 0.04 | 1.58 |
| 0.18 | 41.96 | 31.11 | 0.88 | 0.06 | 1.81 |
