# sustained - 20261114-171544_sustained_m5-fastflush_r3

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setFlushInterval(0.05)`

Settled: False after 30.023 s - 967 frames, 29.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16613 | 1887 | 1615 | 17 | 2926 | 455 | 490 | 0.0% | 54 | 128 |

Rejected contacts: BelowThresh 12279, PartExcluded 2133, Wheel 245, BodyMat 61, NormalForce 8

Body materials: METAL 1712, PLASTIC 175

Surfaces: ASPHALT 1475, COBBLESTONE 412

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 22.882 | 44.941 | 62.149 |
| whole frame, ms | 41.175 (p50) | 59.574 | 125.988 |
| all GE Lua, ms | | 46.029 | 63.438 |
| physics + vehicle Lua, ms | | 0.14 | 7.174 |
| render, ms | | 2.735 | |

- Painter frames over 4 ms: 645; worst flush (project + bake) 62.103 ms, worst composite 0.211 ms.
- Detector: 0.86 us per contact, 24.74 ms total, worst frame 0.524 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 23.33 | 125.99 | 48.39 | 37.67 | 0.06 | 1.53 |
| 18.17 | 81.77 | 62.15 | 29.59 | 0.11 | 1.73 |
| 13.29 | 78.28 | 60.28 | 27.22 | 0.11 | 2.68 |
| 6.46 | 74.13 | 55.93 | 22.50 | 0.12 | 1.89 |
| 18.39 | 70.41 | 48.68 | 44.82 | 0.14 | 2.41 |
