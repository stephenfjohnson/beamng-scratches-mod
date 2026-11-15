# sustained - 20261114-173349_sustained_candidate-d3d12-endurance_r12

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.02 s - 1257 frames, 34.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20287 | 2058 | 1627 | 56 | 2941 | 503 | 514 | 0.0% | 59 | 131 |

Rejected contacts: BelowThresh 15979, PartExcluded 1861, NormalForce 236, Wheel 115, BodyMat 38

Body materials: METAL 1768, PLASTIC 290

Surfaces: ASPHALT 1602, COBBLESTONE 454, RUMBLE_STRIP 2

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.967 | 43.94 | 142.496 |
| whole frame, ms | 25.834 (p50) | 56.195 | 165.756 |
| all GE Lua, ms | | 45.485 | 146.608 |
| physics + vehicle Lua, ms | | 5.664 | 18.246 |
| render, ms | | 2.564 | |

- Painter frames over 4 ms: 669; worst flush (project + bake) 142.444 ms, worst composite 0.133 ms.
- Detector: 0.888 us per contact, 31.345 ms total, worst frame 0.417 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 35.23 | 165.76 | 142.50 | 7.62 | 3.74 | 2.25 |
| 13.63 | 94.43 | 78.41 | 43.74 | 0.15 | 1.67 |
| 34.26 | 84.15 | 59.20 | 4.08 | 0.15 | 2.25 |
| 35.67 | 83.48 | 52.91 | 1.39 | 18.25 | 2.41 |
| 35.28 | 78.36 | 54.01 | 146.61 | 0.09 | 1.68 |
