# sustained - 20261114-183626_sustained_resumed-native-ring_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.008 s - 2544 frames, 84.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15478 | 8492 | 51 | 549 | 104 | 203 | 228 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5513, BelowThresh 1442, NormalForce 31

Body materials: METAL 8481, PLASTIC 11

Surfaces: ASPHALT 7864, COBBLESTONE 628

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.157 | 25.159 | 33.775 |
| whole frame, ms | 10.586 (p50) | 32.338 | 43.818 |
| all GE Lua, ms | | 26.259 | 34.935 |
| physics + vehicle Lua, ms | | 0.086 | 0.474 |
| render, ms | | 2.571 | |

- Painter frames over 4 ms: 235; worst flush (project + bake) 33.736 ms, worst composite 0.208 ms.
- Detector: 3.497 us per contact, 73.839 ms total, worst frame 0.35 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.30 | 43.82 | 33.78 | 0.84 | 0.05 | 2.02 |
| 29.22 | 43.69 | 32.34 | 0.84 | 0.05 | 1.83 |
| 28.34 | 41.73 | 30.12 | 0.75 | 0.05 | 1.70 |
| 29.08 | 41.64 | 31.11 | 0.71 | 0.05 | 1.73 |
| 1.57 | 41.63 | 30.97 | 0.83 | 0.07 | 2.01 |
