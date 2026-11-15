# sustained - 20261114-224643_sustained_synth-full-d3d12-endurance_r33

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.0 s - 2630 frames, 87.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17039 | 8671 | 58 | 606 | 98 | 194 | 220 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6651, BelowThresh 1694, NormalForce 23

Body materials: METAL 8660, PLASTIC 11

Surfaces: ASPHALT 8082, COBBLESTONE 589

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.22 | 11.5 | 200.564 |
| whole frame, ms | 10.917 (p50) | 21.919 | 210.98 |
| all GE Lua, ms | | 12.431 | 201.574 |
| physics + vehicle Lua, ms | | 0.084 | 2.149 |
| render, ms | | 2.297 | |

- Painter frames over 4 ms: 220; worst flush (project + bake) 1.891 ms, worst composite 0.118 ms.
- Detector: 3.126 us per contact, 75.411 ms total, worst frame 1.543 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 5.70 | 210.98 | 200.56 | 1.59 | 0.06 | 1.72 |
| 0.42 | 38.63 | 30.74 | 2.18 | 0.05 | 1.40 |
| 0.34 | 36.86 | 25.79 | 1.43 | 0.04 | 1.85 |
| 24.85 | 33.27 | 21.84 | 1.56 | 0.06 | 1.96 |
| 15.51 | 32.70 | 22.28 | 1.52 | 0.05 | 1.73 |
