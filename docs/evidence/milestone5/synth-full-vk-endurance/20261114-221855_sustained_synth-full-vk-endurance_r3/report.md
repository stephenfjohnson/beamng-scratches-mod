# sustained - 20261114-221855_sustained_synth-full-vk-endurance_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.008 s - 2461 frames, 81.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14996 | 7788 | 59 | 574 | 113 | 188 | 212 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5776, BelowThresh 1410, NormalForce 22

Body materials: METAL 7766, PLASTIC 22

Surfaces: ASPHALT 7502, COBBLESTONE 286

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.288 | 2.029 | 19.364 |
| whole frame, ms | 11.996 (p50) | 15.873 | 185.853 |
| all GE Lua, ms | | 3.383 | 20.294 |
| physics + vehicle Lua, ms | | 0.094 | 0.297 |
| render, ms | | 2.122 | |

- Painter frames over 4 ms: 38; worst flush (project + bake) 1.727 ms, worst composite 0.12 ms.
- Detector: 3.473 us per contact, 75.844 ms total, worst frame 0.367 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 27.05 | 185.85 | 0.01 | 1.24 | 0.08 | 1.48 |
| 25.97 | 94.19 | 0.01 | 2.93 | 0.07 | 2.01 |
| 25.45 | 49.73 | 0.01 | 3.85 | 0.07 | 1.80 |
| 13.28 | 30.15 | 4.05 | 2.02 | 0.06 | 1.51 |
| 0.48 | 25.94 | 19.36 | 7.63 | 0.07 | 1.40 |
