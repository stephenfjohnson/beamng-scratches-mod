# sustained - 20261114-222725_sustained_synth-full-vk-endurance_r36

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.006 s - 2449 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14247 | 7584 | 41 | 504 | 102 | 151 | 172 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5563, BelowThresh 1079, NormalForce 21

Body materials: METAL 7547, PLASTIC 37

Surfaces: ASPHALT 7214, COBBLESTONE 370

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.223 | 1.678 | 14.229 |
| whole frame, ms | 12.192 (p50) | 15.022 | 28.048 |
| all GE Lua, ms | | 2.637 | 15.251 |
| physics + vehicle Lua, ms | | 0.077 | 0.196 |
| render, ms | | 1.892 | |

- Painter frames over 4 ms: 24; worst flush (project + bake) 1.671 ms, worst composite 0.29 ms.
- Detector: 3.393 us per contact, 69.924 ms total, worst frame 0.542 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.41 | 28.05 | 14.23 | 1.32 | 0.05 | 1.52 |
| 12.03 | 23.15 | 9.76 | 1.71 | 0.04 | 1.49 |
| 0.53 | 22.93 | 0.01 | 0.74 | 0.04 | 2.00 |
| 11.92 | 21.27 | 8.71 | 1.30 | 0.04 | 1.42 |
| 17.31 | 21.07 | 9.66 | 1.22 | 0.06 | 1.43 |
