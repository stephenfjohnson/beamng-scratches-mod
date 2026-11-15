# sustained - 20261114-190130_sustained_resumed-selected-half-d3d12-endurance_r39

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.005 s - 2561 frames, 84.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15243 | 7433 | 52 | 566 | 99 | 191 | 219 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6318, BelowThresh 1465, NormalForce 27

Body materials: METAL 7409, PLASTIC 24

Surfaces: ASPHALT 6655, COBBLESTONE 778

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.117 | 23.491 | 367.245 |
| whole frame, ms | 10.674 (p50) | 30.281 | 378.369 |
| all GE Lua, ms | | 24.534 | 368.732 |
| physics + vehicle Lua, ms | | 0.084 | 0.228 |
| render, ms | | 2.342 | |

- Painter frames over 4 ms: 244; worst flush (project + bake) 367.21 ms, worst composite 0.284 ms.
- Detector: 3.07 us per contact, 66.279 ms total, worst frame 0.342 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 18.97 | 378.37 | 367.25 | 0.94 | 0.05 | 1.83 |
| 0.44 | 46.77 | 39.85 | 0.85 | 0.05 | 1.69 |
| 21.07 | 43.55 | 31.35 | 1.10 | 0.07 | 1.93 |
| 0.27 | 42.09 | 30.39 | 0.82 | 0.05 | 2.08 |
| 21.88 | 41.95 | 30.05 | 0.80 | 0.04 | 1.73 |
