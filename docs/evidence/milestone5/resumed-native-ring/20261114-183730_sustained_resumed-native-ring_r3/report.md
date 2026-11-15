# sustained - 20261114-183730_sustained_resumed-native-ring_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2572 frames, 84.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14833 | 7275 | 71 | 558 | 119 | 219 | 259 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5672, BelowThresh 1869, NormalForce 17

Body materials: METAL 7252, PLASTIC 23

Surfaces: ASPHALT 6634, COBBLESTONE 641

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.407 | 26.615 | 426.583 |
| whole frame, ms | 10.57 (p50) | 33.569 | 437.506 |
| all GE Lua, ms | | 27.495 | 427.779 |
| physics + vehicle Lua, ms | | 0.076 | 0.487 |
| render, ms | | 2.174 | |

- Painter frames over 4 ms: 238; worst flush (project + bake) 426.56 ms, worst composite 0.541 ms.
- Detector: 3.0 us per contact, 63.126 ms total, worst frame 0.38 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 18.38 | 437.51 | 426.58 | 0.76 | 0.05 | 1.74 |
| 13.56 | 46.02 | 33.98 | 0.84 | 0.08 | 1.73 |
| 16.54 | 44.20 | 32.92 | 0.85 | 0.05 | 1.74 |
| 2.57 | 42.78 | 32.60 | 0.74 | 0.04 | 1.78 |
| 12.71 | 42.70 | 32.13 | 0.79 | 0.05 | 1.81 |
