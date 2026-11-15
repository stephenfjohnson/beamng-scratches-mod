# sustained - 20261114-182434_sustained_resumed-v2-full-control_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.011 s - 2487 frames, 83.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 18093 | 10932 | 43 | 616 | 79 | 173 | 110 | 0.0% | 0 | 1 |

Rejected contacts: PartExcluded 6628, BelowThresh 500, NormalForce 33

Body materials: METAL 10924, PLASTIC 8

Surfaces: ASPHALT 10052, COBBLESTONE 880

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.059 | 24.587 | 128.015 |
| whole frame, ms | 10.596 (p50) | 32.729 | 138.667 |
| all GE Lua, ms | | 25.67 | 129.355 |
| physics + vehicle Lua, ms | | 0.092 | 4.703 |
| render, ms | | 2.279 | |

- Painter frames over 4 ms: 195; worst flush (project + bake) 57.64 ms, worst composite 0.11 ms.
- Detector: 3.463 us per contact, 82.849 ms total, worst frame 0.703 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.72 | 138.67 | 128.01 | 51.16 | 0.08 | 2.82 |
| 13.90 | 66.93 | 57.67 | 1.05 | 0.42 | 1.74 |
| 0.70 | 59.92 | 49.86 | 0.97 | 0.67 | 2.46 |
| 0.52 | 57.11 | 48.42 | 43.50 | 0.07 | 2.04 |
| 0.50 | 55.30 | 42.37 | 29.44 | 0.10 | 2.28 |
