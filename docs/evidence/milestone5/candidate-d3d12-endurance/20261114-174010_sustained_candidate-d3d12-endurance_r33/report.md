# sustained - 20261114-174010_sustained_candidate-d3d12-endurance_r33

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.024 s - 1388 frames, 44.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18608 | 1751 | 1334 | 35 | 2359 | 404 | 437 | 0.0% | 0 | 115 |

Rejected contacts: BelowThresh 14271, PartExcluded 2393, Wheel 136, NormalForce 36, BodyMat 21

Body materials: METAL 1542, PLASTIC 209

Surfaces: ASPHALT 1355, COBBLESTONE 396

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 13.048 | 38.492 | 75.885 |
| whole frame, ms | 11.979 (p50) | 47.455 | 84.373 |
| all GE Lua, ms | | 39.62 | 76.792 |
| physics + vehicle Lua, ms | | 5.439 | 9.506 |
| render, ms | | 2.328 | |

- Painter frames over 4 ms: 575; worst flush (project + bake) 75.849 ms, worst composite 0.132 ms.
- Detector: 0.827 us per contact, 25.842 ms total, worst frame 0.413 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.69 | 84.37 | 75.88 | 1.21 | 0.84 | 1.78 |
| 16.15 | 73.44 | 65.11 | 0.90 | 2.01 | 1.68 |
| 22.55 | 72.65 | 62.79 | 0.99 | 3.52 | 1.70 |
| 20.38 | 65.63 | 55.40 | 1.25 | 0.07 | 3.02 |
| 7.79 | 65.36 | 57.26 | 0.89 | 1.32 | 1.84 |
