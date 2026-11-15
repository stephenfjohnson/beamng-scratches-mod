# sustained - 20261114-173728_sustained_candidate-d3d12-endurance_r24

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.028 s - 1659 frames, 44.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 19394 | 1851 | 1473 | 31 | 2664 | 582 | 471 | 0.0% | 35 | 123 |

Rejected contacts: BelowThresh 14431, PartExcluded 2983, Wheel 108, BodyMat 19, NormalForce 2

Body materials: METAL 1607, PLASTIC 244

Surfaces: ASPHALT 1429, COBBLESTONE 421, RUMBLE_STRIP 1

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 12.5 | 40.13 | 662.89 |
| whole frame, ms | 11.526 (p50) | 49.83 | 673.341 |
| all GE Lua, ms | | 41.243 | 664.162 |
| physics + vehicle Lua, ms | | 4.912 | 10.88 |
| render, ms | | 2.545 | |

- Painter frames over 4 ms: 637; worst flush (project + bake) 60.021 ms, worst composite 0.227 ms.
- Detector: 0.869 us per contact, 31.997 ms total, worst frame 0.532 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 20.28 | 673.34 | 662.89 | 48.40 | 0.13 | 2.34 |
| 24.86 | 72.37 | 36.03 | 24.34 | 0.05 | 1.61 |
| 29.70 | 69.54 | 59.19 | 0.91 | 3.41 | 2.16 |
| 17.37 | 68.11 | 60.07 | 1.07 | 0.12 | 2.20 |
| 14.11 | 67.38 | 57.70 | 0.91 | 1.41 | 2.20 |
