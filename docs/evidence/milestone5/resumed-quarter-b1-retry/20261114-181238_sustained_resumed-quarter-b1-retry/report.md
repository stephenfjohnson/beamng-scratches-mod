# sustained - 20261114-181238_sustained_resumed-quarter-b1-retry

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(1)`

Settled: False after 30.011 s - 3082 frames, 84.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 33046 | 1748 | 1452 | 39 | 2267 | 454 | 2252 | 0.0% | 20 | 105 |

Rejected contacts: BelowThresh 27715, PartExcluded 3510, Wheel 56, BodyMat 15, NormalForce 2

Body materials: METAL 1542, PLASTIC 206

Surfaces: ASPHALT 1378, COBBLESTONE 366, RUMBLE_STRIP 4

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.583 | 2.03 | 63.478 |
| whole frame, ms | 10.659 (p50) | 15.001 | 74.947 |
| all GE Lua, ms | | 4.596 | 64.461 |
| physics + vehicle Lua, ms | | 0.085 | 1.667 |
| render, ms | | 2.274 | |

- Painter frames over 4 ms: 150; worst flush (project + bake) 63.423 ms, worst composite 0.329 ms.
- Detector: 0.792 us per contact, 42.652 ms total, worst frame 0.615 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 74.95 | 63.48 | 0.95 | 0.05 | 1.90 |
| 27.49 | 62.05 | 49.06 | 0.80 | 0.05 | 2.33 |
| 19.41 | 57.37 | 46.82 | 2.39 | 0.04 | 1.70 |
| 35.30 | 57.01 | 41.15 | 1.33 | 0.05 | 1.97 |
| 0.80 | 56.54 | 44.98 | 0.84 | 0.05 | 1.79 |
