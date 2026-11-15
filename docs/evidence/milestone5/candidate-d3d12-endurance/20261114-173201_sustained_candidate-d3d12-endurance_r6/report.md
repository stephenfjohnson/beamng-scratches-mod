# sustained - 20261114-173201_sustained_candidate-d3d12-endurance_r6

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.012 s - 1336 frames, 37.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17366 | 2041 | 1616 | 34 | 2891 | 531 | 497 | 0.0% | 46 | 136 |

Rejected contacts: BelowThresh 11592, PartExcluded 2932, Wheel 551, BodyMat 239, NormalForce 11

Body materials: METAL 1796, PLASTIC 245

Surfaces: ASPHALT 1636, COBBLESTONE 405

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.998 | 43.388 | 60.981 |
| whole frame, ms | 16.922 (p50) | 54.356 | 74.708 |
| all GE Lua, ms | | 44.304 | 61.871 |
| physics + vehicle Lua, ms | | 5.511 | 12.29 |
| render, ms | | 2.638 | |

- Painter frames over 4 ms: 650; worst flush (project + bake) 60.934 ms, worst composite 0.201 ms.
- Detector: 0.956 us per contact, 30.021 ms total, worst frame 0.625 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.41 | 74.71 | 45.64 | 1.13 | 7.86 | 2.96 |
| 30.33 | 72.41 | 42.02 | 0.98 | 12.29 | 1.81 |
| 5.51 | 70.51 | 55.56 | 1.32 | 2.03 | 2.47 |
| 33.36 | 70.49 | 60.98 | 0.91 | 3.25 | 1.70 |
| 7.54 | 70.23 | 42.41 | 1.37 | 7.72 | 1.89 |
