# sustained - 20261114-194449_sustained_resumed-selected-half-vulkan-endurance_r36

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.001 s - 2380 frames, 79.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15457 | 8779 | 41 | 566 | 88 | 140 | 158 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5363, BelowThresh 1294, NormalForce 21

Body materials: METAL 8746, PLASTIC 33

Surfaces: ASPHALT 8332, COBBLESTONE 447

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.824 | 26.475 | 36.184 |
| whole frame, ms | 11.873 (p50) | 34.272 | 48.292 |
| all GE Lua, ms | | 27.573 | 37.17 |
| physics + vehicle Lua, ms | | 0.079 | 0.86 |
| render, ms | | 1.794 | |

- Painter frames over 4 ms: 145; worst flush (project + bake) 36.161 ms, worst composite 0.08 ms.
- Detector: 3.451 us per contact, 73.961 ms total, worst frame 0.327 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 13.45 | 48.29 | 35.39 | 0.77 | 0.04 | 1.33 |
| 15.65 | 47.86 | 35.87 | 0.80 | 0.05 | 1.23 |
| 29.84 | 47.84 | 34.61 | 0.94 | 0.05 | 1.25 |
| 16.20 | 47.72 | 34.65 | 0.85 | 0.04 | 1.19 |
| 18.96 | 47.68 | 35.39 | 0.95 | 0.06 | 1.35 |
