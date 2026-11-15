# sideslide - 20261114-193606_sideslide_resumed-selected-half-vulkan-endurance_r1

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.153 s - 304 frames, 73.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.155)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2828 | 703 | 71 | 124 | 112 | 97 | 142 | 0.0% | 0 | 1 |

Rejected contacts: Wheel 1506, BelowThresh 614, NormalForce 5

Body materials: METAL 517, PLASTIC 186

Surfaces: ASPHALT 703

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.943 | 34.933 | 44.43 |
| whole frame, ms | 10.264 (p50) | 43.042 | 55.085 |
| all GE Lua, ms | | 36.134 | 45.296 |
| physics + vehicle Lua, ms | | 0.091 | 0.377 |
| render, ms | | 1.912 | |

- Painter frames over 4 ms: 46; worst flush (project + bake) 44.392 ms, worst composite 0.208 ms.
- Detector: 1.777 us per contact, 9.835 ms total, worst frame 0.644 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.19 | 55.09 | 42.98 | 0.75 | 0.05 | 1.29 |
| 0.35 | 52.22 | 44.43 | 1.32 | 0.04 | 1.63 |
| 1.50 | 49.56 | 37.72 | 1.44 | 0.04 | 1.31 |
| 2.24 | 48.97 | 38.07 | 2.05 | 0.07 | 1.41 |
| 1.08 | 48.71 | 37.27 | 1.76 | 0.04 | 1.27 |
