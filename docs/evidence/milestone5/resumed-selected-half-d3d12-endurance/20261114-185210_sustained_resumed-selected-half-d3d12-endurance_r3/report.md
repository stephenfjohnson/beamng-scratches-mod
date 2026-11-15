# sustained - 20261114-185210_sustained_resumed-selected-half-d3d12-endurance_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.012 s - 2562 frames, 85.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16856 | 8870 | 62 | 676 | 123 | 214 | 241 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6248, BelowThresh 1691, NormalForce 47

Body materials: METAL 8854, PLASTIC 16

Surfaces: ASPHALT 7826, COBBLESTONE 1044

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.231 | 25.5 | 37.403 |
| whole frame, ms | 10.613 (p50) | 32.286 | 44.761 |
| all GE Lua, ms | | 26.571 | 38.427 |
| physics + vehicle Lua, ms | | 0.079 | 0.283 |
| render, ms | | 2.283 | |

- Painter frames over 4 ms: 259; worst flush (project + bake) 37.379 ms, worst composite 0.191 ms.
- Detector: 3.001 us per contact, 72.672 ms total, worst frame 0.418 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.44 | 44.76 | 37.40 | 0.82 | 0.04 | 1.41 |
| 21.34 | 44.23 | 33.06 | 0.76 | 0.06 | 1.72 |
| 15.51 | 43.22 | 31.97 | 0.78 | 0.07 | 1.69 |
| 19.44 | 42.31 | 30.86 | 0.81 | 0.05 | 2.32 |
| 24.63 | 42.28 | 30.93 | 0.89 | 0.06 | 1.81 |
