# sustained - 20261114-173447_sustained_candidate-d3d12-endurance_r15

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.0 s - 1358 frames, 39.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 19399 | 1811 | 1426 | 36 | 2587 | 464 | 474 | 0.0% | 31 | 123 |

Rejected contacts: BelowThresh 14168, PartExcluded 3256, Wheel 138, BodyMat 24, NormalForce 2

Body materials: METAL 1497, PLASTIC 314

Surfaces: ASPHALT 1366, COBBLESTONE 445

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 14.885 | 40.126 | 732.467 |
| whole frame, ms | 13.314 (p50) | 49.741 | 744.117 |
| all GE Lua, ms | | 41.153 | 733.765 |
| physics + vehicle Lua, ms | | 5.818 | 13.354 |
| render, ms | | 2.622 | |

- Painter frames over 4 ms: 616; worst flush (project + bake) 732.416 ms, worst composite 0.155 ms.
- Detector: 0.815 us per contact, 28.13 ms total, worst frame 0.389 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.16 | 744.12 | 732.47 | 1.07 | 0.09 | 3.72 |
| 24.75 | 94.05 | 44.76 | 41.78 | 0.10 | 1.62 |
| 6.91 | 67.02 | 57.47 | 1.44 | 2.05 | 1.52 |
| 18.53 | 66.58 | 55.82 | 1.27 | 3.47 | 2.22 |
| 0.60 | 66.33 | 54.86 | 1.07 | 0.08 | 1.76 |
