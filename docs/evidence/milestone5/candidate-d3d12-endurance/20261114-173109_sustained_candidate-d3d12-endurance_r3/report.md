# sustained - 20261114-173109_sustained_candidate-d3d12-endurance_r3

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.03 s - 1356 frames, 39.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18078 | 1929 | 1639 | 24 | 2867 | 478 | 497 | 0.0% | 12 | 126 |

Rejected contacts: BelowThresh 13866, PartExcluded 2164, Wheel 89, BodyMat 22, NormalForce 8

Body materials: METAL 1718, PLASTIC 211

Surfaces: ASPHALT 1493, COBBLESTONE 436

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 14.94 | 39.972 | 69.867 |
| whole frame, ms | 15.509 (p50) | 49.774 | 80.81 |
| all GE Lua, ms | | 40.937 | 70.983 |
| physics + vehicle Lua, ms | | 5.377 | 13.859 |
| render, ms | | 2.311 | |

- Painter frames over 4 ms: 647; worst flush (project + bake) 69.828 ms, worst composite 0.187 ms.
- Detector: 0.822 us per contact, 25.135 ms total, worst frame 0.439 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 6.37 | 80.81 | 69.87 | 0.94 | 2.33 | 2.49 |
| 21.64 | 70.69 | 36.51 | 1.77 | 10.98 | 6.50 |
| 8.87 | 68.69 | 56.71 | 0.78 | 3.21 | 2.38 |
| 31.98 | 67.44 | 52.55 | 1.24 | 5.87 | 2.38 |
| 0.60 | 66.93 | 55.70 | 0.85 | 0.05 | 1.79 |
