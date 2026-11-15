# sustained - 20261114-224207_sustained_synth-full-d3d12-endurance_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.002 s - 2641 frames, 87.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17990 | 9497 | 49 | 619 | 100 | 206 | 216 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6682, BelowThresh 1777, NormalForce 34

Body materials: METAL 9476, PLASTIC 21

Surfaces: ASPHALT 8331, COBBLESTONE 1166

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.031 | 11.118 | 34.749 |
| whole frame, ms | 10.956 (p50) | 21.611 | 369.456 |
| all GE Lua, ms | | 11.989 | 35.744 |
| physics + vehicle Lua, ms | | 0.082 | 1.736 |
| render, ms | | 2.344 | |

- Painter frames over 4 ms: 216; worst flush (project + bake) 1.795 ms, worst composite 0.279 ms.
- Detector: 3.29 us per contact, 80.005 ms total, worst frame 0.437 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.27 | 369.46 | 0.01 | 0.86 | 0.04 | 1.62 |
| 0.47 | 42.00 | 34.75 | 2.47 | 0.09 | 1.61 |
| 0.36 | 37.89 | 29.46 | 26.24 | 0.07 | 1.96 |
| 0.48 | 36.46 | 20.96 | 35.74 | 0.07 | 1.85 |
| 0.35 | 36.25 | 25.27 | 1.94 | 0.09 | 1.88 |
