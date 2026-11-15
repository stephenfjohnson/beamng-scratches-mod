# sustained - 20261114-201818_sustained_resumed-fixed2-full-vulkan-endurance_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.007 s - 2280 frames, 75.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14022 | 7181 | 55 | 493 | 119 | 174 | 179 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5201, BelowThresh 1596, NormalForce 44

Body materials: METAL 7133, PLASTIC 48

Surfaces: ASPHALT 6894, COBBLESTONE 287

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.048 | 21.971 | 36.55 |
| whole frame, ms | 11.963 (p50) | 31.663 | 500.458 |
| all GE Lua, ms | | 23.356 | 38.462 |
| physics + vehicle Lua, ms | | 0.097 | 2.08 |
| render, ms | | 2.064 | |

- Painter frames over 4 ms: 178; worst flush (project + bake) 36.524 ms, worst composite 0.111 ms.
- Detector: 3.612 us per contact, 69.374 ms total, worst frame 0.546 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.72 | 500.46 | 2.75 | 23.36 | 0.08 | 1.40 |
| 0.28 | 49.12 | 34.31 | 0.84 | 0.07 | 1.82 |
| 3.07 | 49.10 | 36.17 | 0.91 | 0.11 | 1.29 |
| 0.97 | 48.22 | 35.56 | 0.82 | 0.05 | 1.24 |
| 14.10 | 47.73 | 33.29 | 0.95 | 0.06 | 1.44 |
