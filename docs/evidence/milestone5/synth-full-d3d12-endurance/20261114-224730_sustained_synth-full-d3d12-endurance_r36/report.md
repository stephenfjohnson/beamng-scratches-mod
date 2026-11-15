# sustained - 20261114-224730_sustained_synth-full-d3d12-endurance_r36

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.011 s - 2644 frames, 88.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17158 | 8650 | 50 | 577 | 101 | 237 | 255 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6733, BelowThresh 1757, NormalForce 18

Body materials: METAL 8635, PLASTIC 15

Surfaces: ASPHALT 8106, COBBLESTONE 544

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.256 | 11.291 | 36.314 |
| whole frame, ms | 10.872 (p50) | 21.779 | 46.143 |
| all GE Lua, ms | | 12.195 | 37.492 |
| physics + vehicle Lua, ms | | 0.084 | 2.286 |
| render, ms | | 2.238 | |

- Painter frames over 4 ms: 255; worst flush (project + bake) 2.289 ms, worst composite 0.137 ms.
- Detector: 3.103 us per contact, 73.438 ms total, worst frame 0.428 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.43 | 46.14 | 36.31 | 36.88 | 0.07 | 2.25 |
| 0.42 | 42.60 | 35.71 | 2.14 | 0.05 | 1.56 |
| 0.45 | 38.99 | 28.48 | 37.49 | 0.08 | 2.31 |
| 12.44 | 37.59 | 26.88 | 1.51 | 0.05 | 1.82 |
| 12.70 | 37.25 | 17.78 | 19.70 | 0.05 | 1.88 |
