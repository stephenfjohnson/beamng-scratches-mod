# sustained - 20261114-202038_sustained_resumed-fixed2-full-vulkan-endurance_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.005 s - 2326 frames, 77.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13608 | 6948 | 47 | 518 | 102 | 148 | 165 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5222, BelowThresh 1420, NormalForce 18

Body materials: METAL 6883, PLASTIC 65

Surfaces: ASPHALT 6527, COBBLESTONE 421

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.924 | 23.832 | 41.24 |
| whole frame, ms | 11.966 (p50) | 31.73 | 53.288 |
| all GE Lua, ms | | 25.125 | 42.296 |
| physics + vehicle Lua, ms | | 0.084 | 0.735 |
| render, ms | | 1.749 | |

- Painter frames over 4 ms: 154; worst flush (project + bake) 41.217 ms, worst composite 0.188 ms.
- Detector: 3.395 us per contact, 65.336 ms total, worst frame 0.863 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.38 | 53.29 | 41.24 | 0.93 | 0.08 | 1.37 |
| 3.18 | 49.41 | 36.26 | 0.90 | 0.05 | 1.29 |
| 0.28 | 49.03 | 36.47 | 0.73 | 0.08 | 1.36 |
| 15.55 | 48.16 | 34.95 | 0.82 | 0.10 | 1.28 |
| 26.01 | 48.04 | 35.95 | 0.67 | 0.04 | 1.30 |
