# sustained - 20261114-173916_sustained_candidate-d3d12-endurance_r30

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.021 s - 1318 frames, 36.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20388 | 1981 | 1679 | 20 | 2998 | 491 | 539 | 0.0% | 14 | 144 |

Rejected contacts: BelowThresh 16011, PartExcluded 2187, Wheel 169, BodyMat 35, NormalForce 5

Body materials: METAL 1791, PLASTIC 190

Surfaces: ASPHALT 1582, COBBLESTONE 396, RUMBLE_STRIP 3

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 16.875 | 40.803 | 334.842 |
| whole frame, ms | 25.246 (p50) | 50.996 | 344.699 |
| all GE Lua, ms | | 41.975 | 336.017 |
| physics + vehicle Lua, ms | | 5.877 | 12.959 |
| render, ms | | 2.476 | |

- Painter frames over 4 ms: 699; worst flush (project + bake) 334.81 ms, worst composite 0.15 ms.
- Detector: 0.791 us per contact, 28.651 ms total, worst frame 0.586 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.81 | 344.70 | 334.84 | 0.71 | 0.05 | 1.89 |
| 19.13 | 75.39 | 28.27 | 0.94 | 6.68 | 2.07 |
| 4.82 | 75.34 | 44.76 | 1.29 | 1.18 | 2.74 |
| 17.80 | 66.42 | 51.77 | 36.48 | 0.09 | 2.61 |
| 11.92 | 65.12 | 53.94 | 0.99 | 2.43 | 1.60 |
