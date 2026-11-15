# sustained - 20261114-190041_sustained_resumed-selected-half-d3d12-endurance_r36

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2546 frames, 84.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16030 | 8391 | 75 | 599 | 121 | 233 | 274 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5987, BelowThresh 1604, NormalForce 48

Body materials: METAL 8374, PLASTIC 17

Surfaces: ASPHALT 7827, COBBLESTONE 564

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.514 | 27.557 | 34.528 |
| whole frame, ms | 10.594 (p50) | 34.56 | 43.791 |
| all GE Lua, ms | | 28.434 | 35.363 |
| physics + vehicle Lua, ms | | 0.081 | 0.383 |
| render, ms | | 2.183 | |

- Painter frames over 4 ms: 266; worst flush (project + bake) 34.503 ms, worst composite 0.135 ms.
- Detector: 2.994 us per contact, 67.662 ms total, worst frame 0.333 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.95 | 43.79 | 32.78 | 1.00 | 0.05 | 1.78 |
| 3.28 | 43.10 | 32.19 | 0.80 | 0.04 | 1.90 |
| 26.41 | 42.64 | 31.23 | 0.80 | 0.05 | 1.40 |
| 1.17 | 42.38 | 31.51 | 0.90 | 0.06 | 1.82 |
| 28.47 | 42.21 | 30.77 | 0.78 | 0.05 | 1.71 |
