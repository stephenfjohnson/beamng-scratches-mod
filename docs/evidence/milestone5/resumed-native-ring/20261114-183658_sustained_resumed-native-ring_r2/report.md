# sustained - 20261114-183658_sustained_resumed-native-ring_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.01 s - 2610 frames, 86.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15869 | 9022 | 32 | 529 | 56 | 179 | 212 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5460, BelowThresh 1373, NormalForce 14

Body materials: METAL 9005, PLASTIC 17

Surfaces: ASPHALT 8300, COBBLESTONE 722

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.871 | 24.139 | 32.529 |
| whole frame, ms | 10.594 (p50) | 30.629 | 43.489 |
| all GE Lua, ms | | 25.028 | 33.675 |
| physics + vehicle Lua, ms | | 0.078 | 0.412 |
| render, ms | | 2.226 | |

- Painter frames over 4 ms: 193; worst flush (project + bake) 32.504 ms, worst composite 0.137 ms.
- Detector: 3.265 us per contact, 69.573 ms total, worst frame 0.346 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 22.47 | 43.49 | 28.83 | 1.01 | 0.06 | 1.81 |
| 23.44 | 43.14 | 31.82 | 0.79 | 0.05 | 1.95 |
| 12.35 | 43.05 | 31.20 | 1.13 | 0.11 | 1.97 |
| 2.07 | 42.59 | 31.78 | 0.83 | 0.04 | 2.00 |
| 22.89 | 42.20 | 32.06 | 0.76 | 0.05 | 1.85 |
