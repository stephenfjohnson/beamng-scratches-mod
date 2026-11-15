# sustained - 20261114-180952_sustained_resumed-half-b6

_assisted roof scrape: maintain 4 m/s horizontal velocity for 30 seconds; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(6)`

Settled: False after 30.002 s - 2540 frames, 76.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 31137 | 1771 | 1477 | 41 | 2332 | 428 | 445 | 0.0% | 0 | 110 |

Rejected contacts: BelowThresh 26869, PartExcluded 1735, Wheel 684, NormalForce 54, BodyMat 24

Body materials: METAL 1596, PLASTIC 175

Surfaces: ASPHALT 1399, COBBLESTONE 372

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.843 | 30.076 | 54.817 |
| whole frame, ms | 10.972 (p50) | 41.127 | 65.738 |
| all GE Lua, ms | | 30.998 | 55.826 |
| physics + vehicle Lua, ms | | 0.542 | 2.153 |
| render, ms | | 2.29 | |

- Painter frames over 4 ms: 527; worst flush (project + bake) 54.78 ms, worst composite 0.133 ms.
- Detector: 0.827 us per contact, 39.972 ms total, worst frame 0.418 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.60 | 65.74 | 54.82 | 0.92 | 0.06 | 2.13 |
| 28.21 | 61.55 | 46.34 | 0.83 | 0.05 | 1.98 |
| 20.32 | 61.11 | 47.87 | 0.94 | 0.05 | 1.87 |
| 27.80 | 60.30 | 49.37 | 0.77 | 0.03 | 1.81 |
| 0.81 | 60.29 | 49.24 | 0.91 | 0.05 | 1.85 |
