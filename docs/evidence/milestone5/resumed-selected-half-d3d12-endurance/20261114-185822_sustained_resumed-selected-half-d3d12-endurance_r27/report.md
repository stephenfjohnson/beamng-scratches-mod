# sustained - 20261114-185822_sustained_resumed-selected-half-d3d12-endurance_r27

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.001 s - 2609 frames, 87.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17246 | 9145 | 52 | 557 | 101 | 151 | 180 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6768, BelowThresh 1289, NormalForce 44

Body materials: METAL 9114, PLASTIC 31

Surfaces: ASPHALT 9028, COBBLESTONE 117

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.589 | 16.166 | 35.468 |
| whole frame, ms | 10.69 (p50) | 24.423 | 45.015 |
| all GE Lua, ms | | 17.335 | 37.307 |
| physics + vehicle Lua, ms | | 0.081 | 0.357 |
| render, ms | | 2.397 | |

- Painter frames over 4 ms: 189; worst flush (project + bake) 35.426 ms, worst composite 0.137 ms.
- Detector: 3.285 us per contact, 75.724 ms total, worst frame 0.402 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.70 | 45.01 | 30.91 | 1.03 | 0.05 | 1.70 |
| 0.40 | 42.79 | 35.47 | 0.81 | 0.05 | 1.82 |
| 15.28 | 42.23 | 31.04 | 0.88 | 0.07 | 1.83 |
| 0.27 | 42.20 | 30.00 | 1.17 | 0.05 | 1.97 |
| 15.42 | 41.61 | 28.94 | 0.85 | 0.06 | 2.09 |
