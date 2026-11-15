# sustained - 20261114-191529_sustained_resumed-control-v2-disabled-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.001 s - 2713 frames, 90.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 19463 | 9589 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 7994, BelowThresh 1808, NormalForce 72

Body materials: METAL 9581, PLASTIC 8

Surfaces: ASPHALT 8129, COBBLESTONE 1460

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.06 |
| whole frame, ms | 11.015 (p50) | 12.227 | 16.881 |
| all GE Lua, ms | | 1.083 | 3.864 |
| physics + vehicle Lua, ms | | 0.081 | 0.385 |
| render, ms | | 2.273 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.49 us per contact, 38.782 ms total, worst frame 0.073 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.48 | 16.88 | 0.01 | 0.82 | 0.05 | 1.98 |
| 22.04 | 15.93 | 0.01 | 1.26 | 0.11 | 2.98 |
| 4.85 | 15.64 | 0.01 | 1.19 | 0.06 | 1.93 |
| 19.85 | 15.51 | 0.01 | 0.88 | 0.06 | 1.82 |
| 21.18 | 15.36 | 0.01 | 0.95 | 0.06 | 2.28 |
