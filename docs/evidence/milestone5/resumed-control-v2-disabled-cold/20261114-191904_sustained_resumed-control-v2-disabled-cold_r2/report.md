# sustained - 20261114-191904_sustained_resumed-control-v2-disabled-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.0 s - 2911 frames, 95.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 20958 | 10101 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 9600, BelowThresh 1231, NormalForce 26

Body materials: METAL 10093, PLASTIC 8

Surfaces: ASPHALT 9654, COBBLESTONE 447

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.15 |
| whole frame, ms | 10.453 (p50) | 11.895 | 20.045 |
| all GE Lua, ms | | 1.167 | 3.975 |
| physics + vehicle Lua, ms | | 0.083 | 0.45 |
| render, ms | | 2.404 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.553 us per contact, 41.759 ms total, worst frame 0.09 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 8.15 | 20.05 | 0.01 | 3.50 | 0.09 | 2.70 |
| 5.34 | 17.87 | 0.01 | 0.88 | 0.06 | 2.11 |
| 10.33 | 17.78 | 0.01 | 0.94 | 0.06 | 2.04 |
| 7.46 | 17.00 | 0.01 | 1.01 | 0.08 | 3.44 |
| 20.84 | 15.68 | 0.01 | 1.72 | 0.12 | 2.00 |
