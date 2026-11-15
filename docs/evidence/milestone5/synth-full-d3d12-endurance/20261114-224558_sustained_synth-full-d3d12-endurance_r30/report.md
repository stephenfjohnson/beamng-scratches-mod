# sustained - 20261114-224558_sustained_synth-full-d3d12-endurance_r30

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.002 s - 2662 frames, 88.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16766 | 9329 | 53 | 587 | 90 | 169 | 199 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6243, BelowThresh 1154, NormalForce 40

Body materials: METAL 9315, PLASTIC 14

Surfaces: ASPHALT 7618, COBBLESTONE 1711

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.953 | 11.125 | 29.528 |
| whole frame, ms | 10.935 (p50) | 20.985 | 36.355 |
| all GE Lua, ms | | 12.0 | 30.488 |
| physics + vehicle Lua, ms | | 0.079 | 0.757 |
| render, ms | | 2.24 | |

- Painter frames over 4 ms: 199; worst flush (project + bake) 1.846 ms, worst composite 0.111 ms.
- Detector: 3.288 us per contact, 75.44 ms total, worst frame 0.646 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.41 | 36.35 | 29.53 | 1.46 | 0.06 | 1.45 |
| 0.36 | 35.69 | 28.14 | 22.03 | 0.07 | 1.86 |
| 23.89 | 34.54 | 0.01 | 0.83 | 0.05 | 1.88 |
| 0.63 | 33.95 | 19.56 | 21.45 | 0.07 | 2.94 |
| 21.15 | 33.30 | 22.83 | 20.12 | 0.06 | 2.49 |
