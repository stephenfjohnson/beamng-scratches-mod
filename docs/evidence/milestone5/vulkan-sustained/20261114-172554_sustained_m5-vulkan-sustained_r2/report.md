# sustained - 20261114-172554_sustained_m5-vulkan-sustained_r2

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.005 s - 2172 frames, 69.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 22653 | 1616 | 1290 | 34 | 2133 | 372 | 410 | 0.0% | 0 | 98 |

Rejected contacts: BelowThresh 19108, PartExcluded 1824, Wheel 82, BodyMat 16, NormalForce 7

Body materials: METAL 1426, PLASTIC 190

Surfaces: ASPHALT 1258, COBBLESTONE 358

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.505 | 34.506 | 79.396 |
| whole frame, ms | 12.385 (p50) | 45.019 | 104.234 |
| all GE Lua, ms | | 35.546 | 80.558 |
| physics + vehicle Lua, ms | | 0.645 | 3.118 |
| render, ms | | 2.082 | |

- Painter frames over 4 ms: 484; worst flush (project + bake) 79.353 ms, worst composite 0.141 ms.
- Detector: 0.941 us per contact, 36.011 ms total, worst frame 0.757 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.62 | 104.23 | 79.40 | 1.14 | 0.08 | 1.68 |
| 0.83 | 69.90 | 53.72 | 1.65 | 0.09 | 1.78 |
| 27.76 | 60.85 | 51.01 | 1.48 | 0.35 | 1.47 |
| 24.86 | 58.79 | 45.71 | 1.07 | 0.09 | 1.85 |
| 29.20 | 58.67 | 45.34 | 1.09 | 0.04 | 1.42 |
