# sustained - 20261114-173634_sustained_candidate-d3d12-endurance_r21

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.003 s - 1196 frames, 33.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20762 | 1868 | 1549 | 21 | 2885 | 509 | 529 | 0.0% | 24 | 140 |

Rejected contacts: BelowThresh 15845, PartExcluded 2701, Wheel 322, BodyMat 19, NormalForce 7

Body materials: METAL 1638, PLASTIC 230

Surfaces: ASPHALT 1410, COBBLESTONE 457, RUMBLE_STRIP 1

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 19.446 | 44.428 | 64.23 |
| whole frame, ms | 34.531 (p50) | 57.051 | 80.432 |
| all GE Lua, ms | | 46.011 | 65.386 |
| physics + vehicle Lua, ms | | 5.217 | 14.674 |
| render, ms | | 2.843 | |

- Painter frames over 4 ms: 687; worst flush (project + bake) 58.988 ms, worst composite 0.229 ms.
- Detector: 0.836 us per contact, 31.081 ms total, worst frame 0.394 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.33 | 80.43 | 38.11 | 48.93 | 0.13 | 2.41 |
| 25.73 | 78.04 | 49.14 | 1.36 | 2.00 | 2.84 |
| 9.94 | 77.20 | 48.29 | 1.29 | 12.48 | 2.01 |
| 9.24 | 76.85 | 57.73 | 10.83 | 2.54 | 2.12 |
| 22.05 | 76.37 | 43.06 | 1.16 | 14.67 | 3.12 |
