# sustained - 20261114-224341_sustained_synth-full-d3d12-endurance_r21

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.008 s - 2718 frames, 90.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17311 | 10127 | 48 | 630 | 104 | 265 | 279 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5845, BelowThresh 1315, NormalForce 24

Body materials: METAL 10120, PLASTIC 7

Surfaces: ASPHALT 9180, COBBLESTONE 947

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.299 | 11.449 | 31.023 |
| whole frame, ms | 10.562 (p50) | 21.832 | 278.16 |
| all GE Lua, ms | | 12.421 | 32.041 |
| physics + vehicle Lua, ms | | 0.083 | 0.821 |
| render, ms | | 2.196 | |

- Painter frames over 4 ms: 279; worst flush (project + bake) 1.601 ms, worst composite 0.121 ms.
- Detector: 3.437 us per contact, 81.94 ms total, worst frame 0.807 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 24.22 | 278.16 | 11.52 | 1.38 | 0.05 | 1.78 |
| 0.42 | 39.57 | 31.02 | 2.09 | 0.04 | 1.43 |
| 0.44 | 33.67 | 26.03 | 32.04 | 0.06 | 1.70 |
| 20.87 | 32.53 | 22.09 | 1.97 | 0.12 | 2.70 |
| 15.71 | 32.22 | 21.89 | 1.31 | 0.06 | 1.66 |
