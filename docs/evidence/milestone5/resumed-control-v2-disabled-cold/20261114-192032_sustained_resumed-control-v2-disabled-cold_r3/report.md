# sustained - 20261114-192032_sustained_resumed-control-v2-disabled-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.004 s - 2897 frames, 95.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16354 | 6992 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 8001, BelowThresh 1339, NormalForce 22

Body materials: METAL 6979, PLASTIC 13

Surfaces: ASPHALT 6228, COBBLESTONE 764

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.007 | 0.047 |
| whole frame, ms | 10.494 (p50) | 11.715 | 16.495 |
| all GE Lua, ms | | 1.072 | 3.046 |
| physics + vehicle Lua, ms | | 0.08 | 0.327 |
| render, ms | | 2.149 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.66 us per contact, 35.499 ms total, worst frame 0.089 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 26.28 | 16.50 | 0.00 | 0.90 | 0.06 | 1.71 |
| 3.73 | 15.90 | 0.01 | 1.09 | 0.07 | 2.04 |
| 0.24 | 14.72 | 0.00 | 0.99 | 0.06 | 2.17 |
| 7.71 | 14.35 | 0.00 | 2.72 | 0.06 | 1.68 |
| 17.54 | 14.32 | 0.01 | 0.90 | 0.05 | 1.94 |
