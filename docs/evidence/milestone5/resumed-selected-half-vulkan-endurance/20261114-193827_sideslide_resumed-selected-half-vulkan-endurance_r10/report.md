# sideslide - 20261114-193827_sideslide_resumed-selected-half-vulkan-endurance_r10

_on its side, sliding along the ground at 14 m/s - one long scrape_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: True after 4.632 s - 344 frames, 73.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -0.163)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 2729 | 625 | 91 | 125 | 113 | 100 | 153 | 0.0% | 0 | 2 |

Rejected contacts: Wheel 1256, BelowThresh 847, NormalForce 1

Body materials: METAL 461, PLASTIC 164

Surfaces: ASPHALT 625

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 4.295 | 34.49 | 41.491 |
| whole frame, ms | 10.599 (p50) | 43.421 | 51.726 |
| all GE Lua, ms | | 35.38 | 42.397 |
| physics + vehicle Lua, ms | | 0.089 | 0.242 |
| render, ms | | 1.834 | |

- Painter frames over 4 ms: 44; worst flush (project + bake) 41.471 ms, worst composite 0.074 ms.
- Detector: 1.739 us per contact, 9.451 ms total, worst frame 0.483 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.62 | 51.73 | 40.40 | 1.82 | 0.06 | 1.44 |
| 0.84 | 51.05 | 38.97 | 1.46 | 0.08 | 1.29 |
| 0.72 | 50.30 | 41.49 | 1.43 | 0.04 | 1.41 |
| 2.52 | 50.28 | 39.32 | 1.48 | 0.05 | 1.24 |
| 1.82 | 49.36 | 36.09 | 2.14 | 0.09 | 1.39 |
