# sustained - 20261114-182329_sustained_resumed-v2-full-control_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.018 s - 2367 frames, 77.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13399 | 7197 | 86 | 596 | 162 | 269 | 171 | 0.6% | 0 | 2 |

Rejected contacts: PartExcluded 5001, BelowThresh 1159, NormalForce 42

Body materials: METAL 7188, PLASTIC 9

Surfaces: ASPHALT 6611, COBBLESTONE 586

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.272 | 30.926 | 58.121 |
| whole frame, ms | 10.369 (p50) | 40.36 | 65.81 |
| all GE Lua, ms | | 31.784 | 59.146 |
| physics + vehicle Lua, ms | | 0.128 | 2.938 |
| render, ms | | 2.29 | |

- Painter frames over 4 ms: 290; worst flush (project + bake) 58.076 ms, worst composite 0.148 ms.
- Detector: 3.417 us per contact, 66.911 ms total, worst frame 0.546 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.48 | 65.81 | 58.12 | 0.87 | 0.04 | 1.88 |
| 12.57 | 65.32 | 57.59 | 34.81 | 0.07 | 1.49 |
| 2.76 | 61.94 | 53.30 | 0.84 | 1.39 | 1.70 |
| 12.96 | 58.57 | 50.79 | 0.85 | 0.70 | 1.72 |
| 2.14 | 58.33 | 48.24 | 1.27 | 0.15 | 1.87 |
