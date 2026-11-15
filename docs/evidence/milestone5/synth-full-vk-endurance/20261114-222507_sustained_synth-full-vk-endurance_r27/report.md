# sustained - 20261114-222507_sustained_synth-full-vk-endurance_r27

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.005 s - 2469 frames, 82.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14991 | 8277 | 38 | 509 | 68 | 127 | 143 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5487, BelowThresh 1214, NormalForce 13

Body materials: METAL 8248, PLASTIC 29

Surfaces: ASPHALT 8170, COBBLESTONE 107

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.198 | 1.384 | 13.625 |
| whole frame, ms | 12.085 (p50) | 14.635 | 22.631 |
| all GE Lua, ms | | 2.376 | 14.665 |
| physics + vehicle Lua, ms | | 0.078 | 0.207 |
| render, ms | | 1.858 | |

- Painter frames over 4 ms: 22; worst flush (project + bake) 2.192 ms, worst composite 0.114 ms.
- Detector: 3.252 us per contact, 69.862 ms total, worst frame 0.379 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.41 | 22.63 | 6.45 | 1.37 | 0.05 | 2.02 |
| 0.47 | 21.99 | 12.20 | 14.66 | 0.06 | 1.54 |
| 11.81 | 21.90 | 8.71 | 1.35 | 0.07 | 1.37 |
| 23.61 | 21.71 | 3.08 | 1.27 | 0.05 | 2.47 |
| 11.98 | 21.49 | 8.88 | 1.17 | 0.09 | 1.57 |
