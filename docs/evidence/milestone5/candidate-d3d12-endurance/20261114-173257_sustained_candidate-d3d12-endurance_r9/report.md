# sustained - 20261114-173257_sustained_candidate-d3d12-endurance_r9

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.031 s - 1324 frames, 38.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 21999 | 3098 | 1463 | 196 | 2623 | 536 | 487 | 0.0% | 71 | 127 |

Rejected contacts: BelowThresh 15373, PartExcluded 3315, Wheel 158, NormalForce 36, BodyMat 19

Body materials: METAL 2219, PLASTIC 879

Surfaces: ASPHALT 2361, COBBLESTONE 737

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.459 | 40.431 | 461.792 |
| whole frame, ms | 14.578 (p50) | 51.017 | 469.868 |
| all GE Lua, ms | | 41.538 | 462.841 |
| physics + vehicle Lua, ms | | 6.061 | 13.167 |
| render, ms | | 2.723 | |

- Painter frames over 4 ms: 634; worst flush (project + bake) 68.524 ms, worst composite 0.167 ms.
- Detector: 1.067 us per contact, 37.702 ms total, worst frame 0.487 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.85 | 469.87 | 461.79 | 34.57 | 0.09 | 2.09 |
| 18.14 | 77.62 | 68.57 | 0.88 | 2.05 | 2.49 |
| 33.07 | 74.65 | 58.03 | 1.29 | 7.13 | 2.45 |
| 23.04 | 72.81 | 43.92 | 1.20 | 2.58 | 2.60 |
| 0.58 | 69.29 | 59.87 | 0.89 | 0.07 | 1.97 |
