# sustained - 20261114-193755_sustained_resumed-selected-half-vulkan-endurance_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.013 s - 2335 frames, 77.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14586 | 7517 | 60 | 603 | 104 | 196 | 209 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5754, BelowThresh 1291, NormalForce 24

Body materials: METAL 7499, PLASTIC 18

Surfaces: ASPHALT 6614, COBBLESTONE 903

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.558 | 32.888 | 39.61 |
| whole frame, ms | 11.732 (p50) | 40.268 | 51.819 |
| all GE Lua, ms | | 33.808 | 40.539 |
| physics + vehicle Lua, ms | | 0.087 | 0.866 |
| render, ms | | 1.744 | |

- Painter frames over 4 ms: 188; worst flush (project + bake) 39.588 ms, worst composite 0.173 ms.
- Detector: 3.236 us per contact, 69.147 ms total, worst frame 0.468 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.82 | 51.82 | 39.61 | 0.94 | 0.05 | 1.83 |
| 0.91 | 49.90 | 36.65 | 0.72 | 0.05 | 1.43 |
| 20.57 | 49.14 | 36.71 | 0.88 | 0.04 | 1.16 |
| 19.56 | 48.73 | 36.13 | 0.81 | 0.06 | 1.32 |
| 22.41 | 48.56 | 35.47 | 0.86 | 0.05 | 1.22 |
