# sustained - 20261114-171506_sustained_m5-fastflush_r2

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setFlushInterval(0.05)`

Settled: False after 30.009 s - 1076 frames, 29.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15121 | 1859 | 1650 | 15 | 2905 | 516 | 532 | 0.0% | 24 | 136 |

Rejected contacts: BelowThresh 9997, PartExcluded 2520, Wheel 713, BodyMat 29, NormalForce 3

Body materials: METAL 1654, PLASTIC 205

Surfaces: ASPHALT 1418, COBBLESTONE 441

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 22.589 | 44.625 | 475.918 |
| whole frame, ms | 40.902 (p50) | 59.512 | 483.859 |
| all GE Lua, ms | | 45.958 | 477.006 |
| physics + vehicle Lua, ms | | 0.155 | 11.227 |
| render, ms | | 2.757 | |

- Painter frames over 4 ms: 700; worst flush (project + bake) 57.469 ms, worst composite 0.155 ms.
- Detector: 0.858 us per contact, 25.266 ms total, worst frame 0.608 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.95 | 483.86 | 475.92 | 35.27 | 0.06 | 2.03 |
| 20.89 | 76.23 | 54.88 | 20.99 | 0.08 | 2.89 |
| 30.01 | 73.99 | 55.47 | 36.08 | 0.06 | 2.98 |
| 24.69 | 72.92 | 57.05 | 38.06 | 0.09 | 2.01 |
| 25.20 | 72.91 | 53.99 | 37.83 | 0.11 | 2.33 |
