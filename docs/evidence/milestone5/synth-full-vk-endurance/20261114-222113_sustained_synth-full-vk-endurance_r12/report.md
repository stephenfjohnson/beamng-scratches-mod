# sustained - 20261114-222113_sustained_synth-full-vk-endurance_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.003 s - 2472 frames, 82.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15302 | 7898 | 64 | 589 | 140 | 201 | 220 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5797, BelowThresh 1583, NormalForce 24

Body materials: METAL 7829, PLASTIC 69

Surfaces: ASPHALT 7288, COBBLESTONE 610

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.273 | 1.945 | 15.496 |
| whole frame, ms | 12.026 (p50) | 15.203 | 29.035 |
| all GE Lua, ms | | 2.987 | 16.408 |
| physics + vehicle Lua, ms | | 0.084 | 0.422 |
| render, ms | | 1.906 | |

- Painter frames over 4 ms: 31; worst flush (project + bake) 3.253 ms, worst composite 0.39 ms.
- Detector: 3.12 us per contact, 71.419 ms total, worst frame 0.378 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.68 | 29.03 | 2.63 | 8.34 | 0.07 | 1.92 |
| 0.65 | 23.89 | 9.11 | 8.21 | 0.07 | 2.47 |
| 9.57 | 23.60 | 13.03 | 2.18 | 0.06 | 1.53 |
| 0.45 | 23.01 | 15.50 | 2.82 | 0.05 | 1.56 |
| 0.64 | 22.82 | 7.23 | 4.41 | 0.10 | 1.68 |
