# sustained - 20261114-222159_sustained_synth-full-vk-endurance_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.005 s - 2461 frames, 82.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16511 | 9138 | 51 | 598 | 117 | 207 | 211 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5963, BelowThresh 1387, NormalForce 23

Body materials: METAL 9111, PLASTIC 27

Surfaces: ASPHALT 8045, COBBLESTONE 1093

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.262 | 1.987 | 13.54 |
| whole frame, ms | 12.122 (p50) | 15.699 | 25.622 |
| all GE Lua, ms | | 2.973 | 14.478 |
| physics + vehicle Lua, ms | | 0.085 | 0.197 |
| render, ms | | 2.023 | |

- Painter frames over 4 ms: 21; worst flush (project + bake) 1.947 ms, worst composite 0.208 ms.
- Detector: 3.395 us per contact, 78.982 ms total, worst frame 0.347 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.42 | 25.62 | 13.10 | 2.24 | 0.06 | 1.43 |
| 12.40 | 24.36 | 13.54 | 1.28 | 0.05 | 1.54 |
| 0.49 | 23.16 | 6.33 | 8.75 | 0.06 | 1.54 |
| 23.63 | 22.75 | 9.87 | 1.21 | 0.05 | 1.44 |
| 11.96 | 22.70 | 2.99 | 1.20 | 0.07 | 2.88 |
