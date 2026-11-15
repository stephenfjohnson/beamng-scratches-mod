# sustained - 20261114-185648_sustained_resumed-selected-half-d3d12-endurance_r21

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.004 s - 2545 frames, 84.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15377 | 7917 | 64 | 554 | 119 | 227 | 264 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5961, BelowThresh 1485, NormalForce 14

Body materials: METAL 7905, PLASTIC 12

Surfaces: ASPHALT 7354, COBBLESTONE 563

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.418 | 26.555 | 36.923 |
| whole frame, ms | 10.554 (p50) | 33.834 | 47.254 |
| all GE Lua, ms | | 27.56 | 37.955 |
| physics + vehicle Lua, ms | | 0.082 | 0.391 |
| render, ms | | 2.396 | |

- Painter frames over 4 ms: 289; worst flush (project + bake) 36.895 ms, worst composite 0.111 ms.
- Detector: 3.233 us per contact, 70.29 ms total, worst frame 0.405 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 20.56 | 47.25 | 36.92 | 0.73 | 0.04 | 1.39 |
| 25.86 | 43.31 | 31.59 | 0.76 | 0.08 | 1.87 |
| 2.01 | 43.12 | 32.74 | 0.82 | 0.07 | 1.93 |
| 18.06 | 42.97 | 32.25 | 0.88 | 0.05 | 1.87 |
| 26.38 | 42.64 | 29.68 | 0.76 | 0.06 | 2.06 |
