# sustained - 20261114-193841_sustained_resumed-selected-half-vulkan-endurance_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.008 s - 2305 frames, 76.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14352 | 7492 | 70 | 590 | 138 | 232 | 267 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5339, BelowThresh 1484, NormalForce 37

Body materials: METAL 7472, PLASTIC 20

Surfaces: ASPHALT 6568, COBBLESTONE 924

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.915 | 32.401 | 37.127 |
| whole frame, ms | 11.492 (p50) | 39.838 | 49.765 |
| all GE Lua, ms | | 33.527 | 38.229 |
| physics + vehicle Lua, ms | | 0.088 | 0.815 |
| render, ms | | 1.876 | |

- Painter frames over 4 ms: 220; worst flush (project + bake) 37.106 ms, worst composite 0.068 ms.
- Detector: 3.444 us per contact, 70.592 ms total, worst frame 0.324 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.88 | 49.76 | 35.70 | 0.70 | 0.05 | 1.44 |
| 21.69 | 48.94 | 36.91 | 0.84 | 0.05 | 1.41 |
| 26.39 | 48.88 | 36.30 | 0.88 | 0.09 | 1.14 |
| 19.30 | 48.74 | 32.03 | 0.79 | 0.06 | 1.32 |
| 27.68 | 48.54 | 36.02 | 1.06 | 0.07 | 1.20 |
