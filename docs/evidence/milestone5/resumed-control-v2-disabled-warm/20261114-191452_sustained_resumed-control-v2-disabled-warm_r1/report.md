# sustained - 20261114-191452_sustained_resumed-control-v2-disabled-warm_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.01 s - 2724 frames, 90.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15301 | 7639 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6711, BelowThresh 933, NormalForce 18

Body materials: METAL 7628, PLASTIC 11

Surfaces: ASPHALT 7356, COBBLESTONE 283

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.012 | 0.069 |
| whole frame, ms | 10.97 (p50) | 12.311 | 21.135 |
| all GE Lua, ms | | 1.185 | 4.918 |
| physics + vehicle Lua, ms | | 0.086 | 0.239 |
| render, ms | | 2.52 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.752 us per contact, 36.25 ms total, worst frame 0.243 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.63 | 21.14 | 0.01 | 1.20 | 0.06 | 1.86 |
| 11.28 | 19.23 | 0.01 | 3.61 | 0.08 | 2.62 |
| 18.74 | 18.49 | 0.01 | 2.63 | 0.05 | 1.94 |
| 11.83 | 17.22 | 0.01 | 4.92 | 0.07 | 2.10 |
| 2.88 | 17.03 | 0.01 | 0.89 | 0.06 | 1.93 |
