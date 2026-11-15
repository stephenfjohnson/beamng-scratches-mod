# sustained - 20261114-193112_sustained_resumed-control-v2-full-vulkan_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.007 s - 2320 frames, 77.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14952 | 7993 | 53 | 521 | 108 | 162 | 123 | 0.0% | 0 | 1 |

Rejected contacts: PartExcluded 5766, BelowThresh 1168, NormalForce 25

Body materials: METAL 7969, PLASTIC 24

Surfaces: ASPHALT 7577, COBBLESTONE 416

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.697 | 6.234 | 51.989 |
| whole frame, ms | 12.097 (p50) | 19.704 | 65.206 |
| all GE Lua, ms | | 7.157 | 52.905 |
| physics + vehicle Lua, ms | | 0.083 | 0.709 |
| render, ms | | 1.841 | |

- Painter frames over 4 ms: 146; worst flush (project + bake) 51.963 ms, worst composite 0.099 ms.
- Detector: 3.426 us per contact, 70.486 ms total, worst frame 0.426 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.48 | 65.21 | 51.99 | 1.20 | 0.07 | 1.67 |
| 0.69 | 53.84 | 45.48 | 1.29 | 0.07 | 1.43 |
| 12.40 | 53.27 | 41.12 | 0.69 | 0.05 | 1.56 |
| 17.32 | 52.46 | 40.43 | 0.76 | 0.05 | 1.63 |
| 21.45 | 52.12 | 40.35 | 1.00 | 0.07 | 1.40 |
