# sustained - 20261114-185735_sustained_resumed-selected-half-d3d12-endurance_r24

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.003 s - 2621 frames, 87.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16667 | 9658 | 30 | 526 | 78 | 144 | 162 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5778, BelowThresh 1210, NormalForce 21

Body materials: METAL 9646, PLASTIC 12

Surfaces: ASPHALT 9380, COBBLESTONE 278

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.566 | 11.82 | 36.621 |
| whole frame, ms | 10.702 (p50) | 20.062 | 47.463 |
| all GE Lua, ms | | 12.756 | 37.701 |
| physics + vehicle Lua, ms | | 0.076 | 0.308 |
| render, ms | | 2.293 | |

- Painter frames over 4 ms: 183; worst flush (project + bake) 36.599 ms, worst composite 0.127 ms.
- Detector: 3.481 us per contact, 76.703 ms total, worst frame 0.389 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 18.90 | 47.46 | 36.62 | 0.78 | 0.08 | 1.67 |
| 0.58 | 43.92 | 31.68 | 0.91 | 0.07 | 2.07 |
| 12.56 | 41.57 | 29.71 | 0.79 | 0.04 | 1.81 |
| 0.27 | 41.47 | 29.69 | 0.79 | 0.05 | 2.04 |
| 27.25 | 41.47 | 30.22 | 1.23 | 0.10 | 1.86 |
