# sustained - 20261114-222553_sustained_synth-full-vk-endurance_r30

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.004 s - 2447 frames, 81.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13953 | 6617 | 81 | 589 | 150 | 218 | 232 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5573, BelowThresh 1736, NormalForce 27

Body materials: METAL 6585, PLASTIC 32

Surfaces: ASPHALT 5824, COBBLESTONE 793

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.281 | 2.147 | 13.45 |
| whole frame, ms | 12.175 (p50) | 15.352 | 26.704 |
| all GE Lua, ms | | 3.052 | 14.686 |
| physics + vehicle Lua, ms | | 0.081 | 0.223 |
| render, ms | | 1.793 | |

- Painter frames over 4 ms: 26; worst flush (project + bake) 2.741 ms, worst composite 0.081 ms.
- Detector: 3.007 us per contact, 64.612 ms total, worst frame 0.378 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.12 | 26.70 | 1.71 | 1.14 | 0.04 | 1.62 |
| 0.63 | 23.21 | 5.01 | 4.23 | 0.06 | 1.50 |
| 0.46 | 22.71 | 13.45 | 3.31 | 0.07 | 1.54 |
| 0.35 | 22.70 | 9.86 | 1.90 | 0.06 | 1.47 |
| 2.46 | 22.02 | 2.97 | 1.10 | 0.05 | 1.66 |
