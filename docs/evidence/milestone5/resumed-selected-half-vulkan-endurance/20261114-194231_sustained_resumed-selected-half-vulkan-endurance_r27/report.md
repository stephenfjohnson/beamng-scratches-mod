# sustained - 20261114-194231_sustained_resumed-selected-half-vulkan-endurance_r27

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2358 frames, 78.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14305 | 7551 | 65 | 555 | 140 | 187 | 204 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5656, BelowThresh 1076, NormalForce 22

Body materials: METAL 7522, PLASTIC 29

Surfaces: ASPHALT 6842, COBBLESTONE 709

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.396 | 31.968 | 39.372 |
| whole frame, ms | 11.715 (p50) | 38.167 | 48.513 |
| all GE Lua, ms | | 32.759 | 40.43 |
| physics + vehicle Lua, ms | | 0.079 | 0.448 |
| render, ms | | 1.693 | |

- Painter frames over 4 ms: 179; worst flush (project + bake) 39.35 ms, worst composite 0.102 ms.
- Detector: 3.235 us per contact, 68.36 ms total, worst frame 0.431 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.29 | 48.51 | 34.46 | 0.76 | 0.07 | 1.26 |
| 23.00 | 48.23 | 35.40 | 0.74 | 0.04 | 1.18 |
| 23.86 | 48.15 | 35.72 | 0.81 | 0.04 | 1.35 |
| 13.58 | 48.08 | 35.30 | 0.83 | 0.05 | 1.23 |
| 21.09 | 47.94 | 34.36 | 0.89 | 0.05 | 1.30 |
