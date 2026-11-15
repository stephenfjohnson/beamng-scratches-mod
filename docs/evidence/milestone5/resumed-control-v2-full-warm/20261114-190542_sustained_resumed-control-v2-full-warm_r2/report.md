# sustained - 20261114-190542_sustained_resumed-control-v2-full-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.006 s - 2438 frames, 81.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16371 | 8819 | 68 | 594 | 124 | 180 | 125 | 0.0% | 0 | 2 |

Rejected contacts: PartExcluded 5904, BelowThresh 1616, NormalForce 32

Body materials: METAL 8770, PLASTIC 49

Surfaces: ASPHALT 7991, COBBLESTONE 828

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.27 | 27.353 | 61.86 |
| whole frame, ms | 10.704 (p50) | 37.806 | 71.146 |
| all GE Lua, ms | | 28.338 | 62.789 |
| physics + vehicle Lua, ms | | 0.09 | 4.909 |
| render, ms | | 2.441 | |

- Painter frames over 4 ms: 220; worst flush (project + bake) 61.824 ms, worst composite 0.143 ms.
- Detector: 3.37 us per contact, 75.027 ms total, worst frame 0.428 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.90 | 71.15 | 61.86 | 0.75 | 2.68 | 1.67 |
| 0.68 | 64.66 | 46.92 | 0.90 | 0.05 | 2.19 |
| 0.48 | 63.06 | 51.43 | 0.91 | 0.06 | 2.07 |
| 2.02 | 51.63 | 39.81 | 0.89 | 4.63 | 2.13 |
| 2.24 | 51.11 | 43.98 | 0.81 | 0.08 | 1.96 |
