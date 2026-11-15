# sustained - 20261114-182402_sustained_resumed-v2-full-control_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.007 s - 2392 frames, 78.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13622 | 7683 | 51 | 525 | 113 | 201 | 139 | 0.0% | 0 | 2 |

Rejected contacts: PartExcluded 5223, BelowThresh 698, NormalForce 18

Body materials: METAL 7675, PLASTIC 8

Surfaces: ASPHALT 7246, COBBLESTONE 437

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.682 | 29.051 | 170.978 |
| whole frame, ms | 10.741 (p50) | 39.538 | 181.837 |
| all GE Lua, ms | | 30.014 | 172.118 |
| physics + vehicle Lua, ms | | 0.102 | 1.97 |
| render, ms | | 2.288 | |

- Painter frames over 4 ms: 232; worst flush (project + bake) 170.955 ms, worst composite 0.11 ms.
- Detector: 3.541 us per contact, 66.826 ms total, worst frame 0.733 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 17.04 | 181.84 | 170.98 | 0.73 | 0.05 | 1.66 |
| 14.76 | 68.33 | 57.01 | 0.83 | 0.05 | 1.68 |
| 14.14 | 65.15 | 53.84 | 1.00 | 0.06 | 1.73 |
| 14.56 | 63.67 | 53.91 | 0.78 | 0.20 | 1.81 |
| 14.35 | 60.45 | 49.27 | 0.83 | 0.05 | 1.74 |
