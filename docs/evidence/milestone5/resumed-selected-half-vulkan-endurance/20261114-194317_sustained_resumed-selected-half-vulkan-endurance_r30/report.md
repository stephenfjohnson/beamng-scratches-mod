# sustained - 20261114-194317_sustained_resumed-selected-half-vulkan-endurance_r30

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.004 s - 2303 frames, 76.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15375 | 7866 | 88 | 663 | 151 | 236 | 247 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5656, BelowThresh 1822, NormalForce 31

Body materials: METAL 7837, PLASTIC 29

Surfaces: ASPHALT 6783, COBBLESTONE 1083

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.894 | 32.807 | 37.684 |
| whole frame, ms | 11.666 (p50) | 38.951 | 50.972 |
| all GE Lua, ms | | 33.773 | 38.641 |
| physics + vehicle Lua, ms | | 0.09 | 1.086 |
| render, ms | | 1.919 | |

- Painter frames over 4 ms: 215; worst flush (project + bake) 37.664 ms, worst composite 0.067 ms.
- Detector: 3.283 us per contact, 73.627 ms total, worst frame 0.467 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.31 | 50.97 | 37.68 | 0.83 | 0.04 | 1.38 |
| 1.57 | 50.11 | 37.10 | 0.79 | 0.04 | 1.20 |
| 0.28 | 49.65 | 36.83 | 0.73 | 0.05 | 1.39 |
| 23.37 | 49.47 | 36.40 | 0.74 | 0.05 | 1.14 |
| 16.92 | 48.93 | 36.19 | 0.82 | 0.04 | 1.31 |
