# sustained - 20261114-181051_sustained_resumed-half-b1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(1)`

Settled: False after 30.01 s - 3090 frames, 84.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 42435 | 2123 | 1359 | 74 | 2146 | 450 | 2278 | 0.0% | 7 | 116 |

Rejected contacts: BelowThresh 33476, PartExcluded 3907, Wheel 2708, NormalForce 209, BodyMat 12

Body materials: METAL 1459, PLASTIC 664

Surfaces: ASPHALT 1767, COBBLESTONE 337, RUMBLE_STRIP 19

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.633 | 4.599 | 48.346 |
| whole frame, ms | 10.557 (p50) | 15.996 | 60.904 |
| all GE Lua, ms | | 5.691 | 49.336 |
| physics + vehicle Lua, ms | | 0.086 | 1.192 |
| render, ms | | 2.317 | |

- Painter frames over 4 ms: 173; worst flush (project + bake) 48.296 ms, worst composite 0.393 ms.
- Detector: 0.826 us per contact, 52.012 ms total, worst frame 0.483 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.59 | 60.90 | 48.35 | 1.02 | 0.06 | 2.76 |
| 22.72 | 59.86 | 47.62 | 1.80 | 0.05 | 1.88 |
| 23.69 | 59.12 | 46.50 | 0.78 | 0.04 | 1.69 |
| 26.80 | 59.09 | 47.56 | 0.77 | 0.04 | 1.87 |
| 0.80 | 59.01 | 47.58 | 0.93 | 0.06 | 1.78 |
