# sustained - 20261114-180850_sustained_resumed-full-b6

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6)`

Settled: False after 30.019 s - 1422 frames, 41.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20042 | 1875 | 1555 | 28 | 2791 | 457 | 475 | 0.0% | 41 | 128 |

Rejected contacts: BelowThresh 15453, PartExcluded 2516, Wheel 152, BodyMat 32, NormalForce 14

Body materials: METAL 1603, PLASTIC 272

Surfaces: ASPHALT 1441, COBBLESTONE 431, RUMBLE_STRIP 3

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 14.205 | 40.388 | 447.554 |
| whole frame, ms | 12.404 (p50) | 50.319 | 458.445 |
| all GE Lua, ms | | 41.365 | 452.094 |
| physics + vehicle Lua, ms | | 5.428 | 11.022 |
| render, ms | | 2.277 | |

- Painter frames over 4 ms: 626; worst flush (project + bake) 63.477 ms, worst composite 1.845 ms.
- Detector: 0.893 us per contact, 29.531 ms total, worst frame 0.577 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 28.22 | 458.45 | 447.55 | 37.91 | 0.14 | 1.96 |
| 19.21 | 72.50 | 63.51 | 0.87 | 3.03 | 1.69 |
| 10.98 | 72.33 | 56.75 | 36.95 | 0.10 | 1.81 |
| 14.71 | 69.22 | 60.56 | 0.95 | 1.76 | 1.78 |
| 5.42 | 65.68 | 55.75 | 0.99 | 2.42 | 1.64 |
