# sustained - 20261114-202428_sustained_resumed-fixed2-full-vulkan-endurance_r27

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2248 frames, 74.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13926 | 6855 | 62 | 564 | 129 | 207 | 226 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5869, BelowThresh 1163, NormalForce 39

Body materials: METAL 6833, PLASTIC 22

Surfaces: ASPHALT 6058, COBBLESTONE 797

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.761 | 31.024 | 37.47 |
| whole frame, ms | 11.814 (p50) | 37.567 | 49.299 |
| all GE Lua, ms | | 31.864 | 38.732 |
| physics + vehicle Lua, ms | | 0.102 | 1.343 |
| render, ms | | 1.931 | |

- Painter frames over 4 ms: 206; worst flush (project + bake) 37.445 ms, worst composite 0.183 ms.
- Detector: 3.709 us per contact, 72.978 ms total, worst frame 0.336 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 18.92 | 49.30 | 35.61 | 1.05 | 0.06 | 2.12 |
| 0.28 | 48.68 | 34.71 | 0.78 | 0.10 | 1.46 |
| 25.18 | 48.53 | 34.54 | 0.75 | 0.05 | 1.52 |
| 20.22 | 48.42 | 35.41 | 0.87 | 0.05 | 1.47 |
| 24.72 | 48.27 | 35.48 | 0.83 | 0.06 | 1.34 |
