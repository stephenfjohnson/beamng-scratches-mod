# sustained - 20261114-173540_sustained_candidate-d3d12-endurance_r18

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.008 s - 1287 frames, 36.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15707 | 1963 | 1597 | 39 | 2852 | 474 | 498 | 0.0% | 46 | 130 |

Rejected contacts: BelowThresh 11541, PartExcluded 2077, Wheel 88, NormalForce 20, BodyMat 18

Body materials: METAL 1690, PLASTIC 273

Surfaces: ASPHALT 1517, COBBLESTONE 445, RUMBLE_STRIP 1

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 16.682 | 42.919 | 74.097 |
| whole frame, ms | 19.902 (p50) | 54.735 | 94.314 |
| all GE Lua, ms | | 44.255 | 75.478 |
| physics + vehicle Lua, ms | | 5.745 | 11.591 |
| render, ms | | 2.669 | |

- Painter frames over 4 ms: 645; worst flush (project + bake) 74.013 ms, worst composite 0.247 ms.
- Detector: 0.986 us per contact, 28.438 ms total, worst frame 0.509 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 8.18 | 94.31 | 74.10 | 39.46 | 0.19 | 2.94 |
| 14.17 | 76.83 | 48.67 | 1.72 | 10.85 | 2.23 |
| 20.47 | 75.44 | 66.91 | 1.26 | 1.60 | 1.75 |
| 5.70 | 75.20 | 66.09 | 1.27 | 1.06 | 1.77 |
| 8.98 | 74.09 | 53.96 | 10.47 | 1.87 | 1.96 |
