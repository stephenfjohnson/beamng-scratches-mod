# sustained - 20261114-190628_sustained_resumed-control-v2-full-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.0 s - 2460 frames, 82.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15024 | 8406 | 60 | 513 | 126 | 152 | 122 | 0.0% | 0 | 3 |

Rejected contacts: PartExcluded 5522, BelowThresh 1076, NormalForce 20

Body materials: METAL 8378, PLASTIC 28

Surfaces: ASPHALT 8266, COBBLESTONE 140

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.169 | 27.791 | 59.975 |
| whole frame, ms | 10.741 (p50) | 38.259 | 71.192 |
| all GE Lua, ms | | 28.812 | 61.042 |
| physics + vehicle Lua, ms | | 0.084 | 3.829 |
| render, ms | | 2.348 | |

- Painter frames over 4 ms: 218; worst flush (project + bake) 59.945 ms, worst composite 0.114 ms.
- Detector: 3.467 us per contact, 70.287 ms total, worst frame 0.739 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.48 | 71.19 | 59.98 | 0.78 | 0.04 | 1.80 |
| 0.91 | 67.54 | 57.82 | 0.89 | 2.71 | 1.77 |
| 2.08 | 61.17 | 54.13 | 32.83 | 0.06 | 1.50 |
| 0.69 | 58.58 | 41.75 | 0.89 | 0.05 | 2.87 |
| 0.51 | 54.74 | 47.73 | 41.22 | 0.05 | 1.52 |
