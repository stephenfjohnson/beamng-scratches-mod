# sustained - 20261114-171427_sustained_m5-fastflush_r1

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setFlushInterval(0.05)`

Settled: False after 30.037 s - 1080 frames, 29.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16823 | 1913 | 1491 | 28 | 2723 | 571 | 519 | 0.0% | 5 | 125 |

Rejected contacts: BelowThresh 11759, PartExcluded 2977, Wheel 105, BodyMat 51, NormalForce 18

Body materials: METAL 1730, PLASTIC 183

Surfaces: ASPHALT 1484, COBBLESTONE 423, RUMBLE_STRIP 6

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 22.466 | 47.043 | 64.417 |
| whole frame, ms | 40.184 (p50) | 63.224 | 85.312 |
| all GE Lua, ms | | 48.42 | 66.139 |
| physics + vehicle Lua, ms | | 0.175 | 12.614 |
| render, ms | | 3.224 | |

- Painter frames over 4 ms: 697; worst flush (project + bake) 64.36 ms, worst composite 0.428 ms.
- Detector: 1.034 us per contact, 30.503 ms total, worst frame 0.551 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 35.17 | 85.31 | 64.42 | 47.33 | 0.14 | 2.64 |
| 34.86 | 80.30 | 62.21 | 32.88 | 0.08 | 2.75 |
| 8.53 | 78.52 | 54.91 | 31.75 | 0.14 | 2.52 |
| 34.56 | 77.24 | 56.02 | 39.07 | 0.13 | 3.47 |
| 11.62 | 77.15 | 57.44 | 32.55 | 0.13 | 3.11 |
