# sideslide - 20261114-193913_sideslide_resumed-selected-half-vulkan-endurance_r13

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.147 s - 309 frames, 73.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.171)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2783 | 657 | 86 | 117 | 116 | 99 | 143 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1517, BelowThresh 604, NormalForce 5

Body materials: METAL 485, PLASTIC 172

Surfaces: ASPHALT 657

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.933 | 35.401 | 38.948 |
| whole frame, ms | 9.465 (p50) | 44.699 | 50.414 |
| all GE Lua, ms | | 36.195 | 39.638 |
| physics + vehicle Lua, ms | | 0.079 | 0.221 |
| render, ms | | 1.606 | |

- Painter frames over 4 ms: 42; worst flush (project + bake) 38.925 ms, worst composite 0.085 ms.
- Detector: 1.538 us per contact, 8.163 ms total, worst frame 0.526 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.32 | 50.41 | 38.53 | 1.74 | 0.05 | 1.41 |
| 0.45 | 50.21 | 38.25 | 1.24 | 0.05 | 1.44 |
| 1.79 | 49.45 | 35.50 | 1.48 | 0.05 | 1.48 |
| 0.18 | 49.17 | 36.45 | 0.80 | 0.08 | 1.36 |
| 0.87 | 49.04 | 35.63 | 1.39 | 0.07 | 1.37 |
