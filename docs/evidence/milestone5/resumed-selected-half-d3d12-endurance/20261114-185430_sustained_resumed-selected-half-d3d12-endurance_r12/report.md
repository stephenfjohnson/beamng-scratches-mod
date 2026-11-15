# sustained - 20261114-185430_sustained_resumed-selected-half-d3d12-endurance_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.002 s - 2639 frames, 88.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14723 | 7641 | 63 | 550 | 112 | 215 | 241 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6111, BelowThresh 945, NormalForce 26

Body materials: METAL 7626, PLASTIC 15

Surfaces: ASPHALT 7316, COBBLESTONE 325

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.15 | 25.596 | 31.988 |
| whole frame, ms | 10.291 (p50) | 33.027 | 42.115 |
| all GE Lua, ms | | 26.539 | 33.076 |
| physics + vehicle Lua, ms | | 0.082 | 0.208 |
| render, ms | | 2.358 | |

- Painter frames over 4 ms: 267; worst flush (project + bake) 31.96 ms, worst composite 0.108 ms.
- Detector: 3.286 us per contact, 69.592 ms total, worst frame 0.563 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 13.24 | 42.11 | 31.99 | 0.71 | 0.04 | 1.82 |
| 0.28 | 41.36 | 30.33 | 1.28 | 0.09 | 1.89 |
| 15.11 | 41.21 | 30.78 | 0.84 | 0.06 | 1.89 |
| 15.42 | 40.87 | 28.87 | 0.82 | 0.05 | 1.71 |
| 12.68 | 40.62 | 29.21 | 0.95 | 0.07 | 1.83 |
