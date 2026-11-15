# sustained - 20261114-222245_sustained_synth-full-vk-endurance_r18

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.0 s - 2445 frames, 81.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14675 | 6951 | 75 | 607 | 123 | 217 | 240 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5600, BelowThresh 2105, NormalForce 19

Body materials: METAL 6917, PLASTIC 34

Surfaces: ASPHALT 6212, COBBLESTONE 739

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.297 | 2.309 | 14.164 |
| whole frame, ms | 12.145 (p50) | 15.474 | 243.365 |
| all GE Lua, ms | | 3.294 | 15.141 |
| physics + vehicle Lua, ms | | 0.081 | 0.446 |
| render, ms | | 1.857 | |

- Painter frames over 4 ms: 28; worst flush (project + bake) 2.682 ms, worst composite 0.196 ms.
- Detector: 2.943 us per contact, 65.881 ms total, worst frame 0.364 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.11 | 243.37 | 0.01 | 0.79 | 0.06 | 1.49 |
| 0.46 | 23.94 | 14.16 | 1.95 | 0.06 | 1.89 |
| 12.99 | 23.71 | 3.10 | 5.97 | 0.07 | 1.54 |
| 13.39 | 21.81 | 2.99 | 1.12 | 0.04 | 1.50 |
| 28.97 | 21.50 | 3.31 | 1.58 | 0.08 | 2.04 |
