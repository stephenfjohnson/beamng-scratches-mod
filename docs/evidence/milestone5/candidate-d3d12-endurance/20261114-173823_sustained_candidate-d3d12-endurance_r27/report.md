# sustained - 20261114-173823_sustained_candidate-d3d12-endurance_r27

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.005 s - 1265 frames, 37.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15495 | 1708 | 1420 | 26 | 2599 | 489 | 470 | 0.0% | 10 | 125 |

Rejected contacts: BelowThresh 11445, PartExcluded 2262, Wheel 46, NormalForce 17, BodyMat 17

Body materials: METAL 1449, PLASTIC 259

Surfaces: ASPHALT 1288, COBBLESTONE 419, RUMBLE_STRIP 1

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 15.995 | 43.403 | 68.168 |
| whole frame, ms | 14.805 (p50) | 54.244 | 98.126 |
| all GE Lua, ms | | 44.646 | 69.189 |
| physics + vehicle Lua, ms | | 5.315 | 13.251 |
| render, ms | | 2.711 | |

- Painter frames over 4 ms: 611; worst flush (project + bake) 68.1 ms, worst composite 0.313 ms.
- Detector: 0.939 us per contact, 26.223 ms total, worst frame 0.502 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 20.86 | 98.13 | 36.08 | 36.96 | 0.08 | 1.35 |
| 12.31 | 79.49 | 51.63 | 1.44 | 13.25 | 2.00 |
| 11.24 | 79.36 | 57.30 | 53.17 | 0.14 | 2.72 |
| 18.86 | 78.20 | 68.17 | 1.10 | 2.45 | 2.21 |
| 13.53 | 74.93 | 56.56 | 29.10 | 0.14 | 2.90 |
