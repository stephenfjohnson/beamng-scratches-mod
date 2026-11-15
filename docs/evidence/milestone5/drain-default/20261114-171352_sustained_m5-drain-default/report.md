# sustained - 20261114-171352_sustained_m5-drain-default

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Settled: False after 30.009 s - 1113 frames, 33.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14201 | 1910 | 1510 | 43 | 2721 | 455 | 452 | 0.0% | 48 | 120 |

Rejected contacts: BelowThresh 9860, PartExcluded 2238, Wheel 103, NormalForce 61, BodyMat 29

Body materials: METAL 1642, PLASTIC 268

Surfaces: ASPHALT 1422, COBBLESTONE 488

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 17.944 | 43.959 | 61.888 |
| whole frame, ms | 27.372 (p50) | 57.561 | 79.05 |
| all GE Lua, ms | | 45.214 | 63.214 |
| physics + vehicle Lua, ms | | 4.776 | 11.53 |
| render, ms | | 2.938 | |

- Painter frames over 4 ms: 594; worst flush (project + bake) 61.837 ms, worst composite 0.233 ms.
- Detector: 1.119 us per contact, 28.607 ms total, worst frame 0.618 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.41 | 79.05 | 61.89 | 15.05 | 0.14 | 2.92 |
| 18.36 | 76.53 | 43.33 | 3.48 | 8.45 | 2.33 |
| 0.59 | 69.45 | 56.80 | 1.34 | 0.09 | 2.23 |
| 20.03 | 68.49 | 49.93 | 26.82 | 0.12 | 1.64 |
| 7.35 | 67.21 | 45.32 | 16.64 | 0.11 | 3.05 |
