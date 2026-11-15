# sustained - 20261114-191607_sustained_resumed-control-v2-disabled-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.002 s - 2729 frames, 90.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16362 | 8478 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6324, BelowThresh 1534, NormalForce 26

Body materials: METAL 8469, PLASTIC 9

Surfaces: ASPHALT 8051, COBBLESTONE 427

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.117 |
| whole frame, ms | 10.979 (p50) | 12.169 | 17.379 |
| all GE Lua, ms | | 1.08 | 3.137 |
| physics + vehicle Lua, ms | | 0.082 | 0.221 |
| render, ms | | 2.309 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.656 us per contact, 36.917 ms total, worst frame 0.125 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 21.93 | 17.38 | 0.01 | 0.76 | 0.05 | 1.84 |
| 22.92 | 17.32 | 0.01 | 0.88 | 0.06 | 2.40 |
| 22.70 | 15.33 | 0.02 | 1.26 | 0.08 | 3.47 |
| 8.54 | 15.05 | 0.01 | 0.86 | 0.06 | 1.97 |
| 1.94 | 15.03 | 0.01 | 0.80 | 0.05 | 1.97 |
