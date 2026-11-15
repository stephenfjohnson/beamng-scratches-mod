# sustained - 20261114-222332_sustained_synth-full-vk-endurance_r21

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.012 s - 2453 frames, 81.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16338 | 8982 | 56 | 606 | 127 | 216 | 221 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5978, BelowThresh 1348, NormalForce 30

Body materials: METAL 8949, PLASTIC 33

Surfaces: ASPHALT 8183, COBBLESTONE 799

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.273 | 2.047 | 14.089 |
| whole frame, ms | 12.149 (p50) | 15.142 | 25.547 |
| all GE Lua, ms | | 2.887 | 15.016 |
| physics + vehicle Lua, ms | | 0.081 | 0.258 |
| render, ms | | 1.854 | |

- Painter frames over 4 ms: 29; worst flush (project + bake) 1.676 ms, worst composite 0.327 ms.
- Detector: 3.246 us per contact, 75.897 ms total, worst frame 0.754 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.46 | 25.55 | 14.09 | 1.43 | 0.06 | 1.43 |
| 1.24 | 25.05 | 3.00 | 1.89 | 0.06 | 1.52 |
| 19.62 | 22.89 | 8.57 | 1.10 | 0.05 | 1.36 |
| 24.89 | 22.21 | 6.56 | 1.55 | 0.05 | 1.52 |
| 0.46 | 21.61 | 13.85 | 2.71 | 0.07 | 1.67 |
