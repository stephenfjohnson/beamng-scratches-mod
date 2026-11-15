# sustained - 20261114-194535_sustained_resumed-selected-half-vulkan-endurance_r39

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.003 s - 2329 frames, 77.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15790 | 8441 | 68 | 681 | 133 | 204 | 232 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5619, BelowThresh 1692, NormalForce 38

Body materials: METAL 8425, PLASTIC 16

Surfaces: ASPHALT 7309, COBBLESTONE 1132

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.625 | 33.151 | 38.849 |
| whole frame, ms | 11.652 (p50) | 39.946 | 49.235 |
| all GE Lua, ms | | 34.147 | 40.424 |
| physics + vehicle Lua, ms | | 0.084 | 0.843 |
| render, ms | | 1.758 | |

- Painter frames over 4 ms: 192; worst flush (project + bake) 38.824 ms, worst composite 0.086 ms.
- Detector: 3.219 us per contact, 72.961 ms total, worst frame 0.437 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.72 | 49.23 | 36.63 | 0.94 | 0.06 | 1.25 |
| 22.53 | 49.14 | 35.37 | 0.98 | 0.04 | 1.53 |
| 18.08 | 48.80 | 35.51 | 0.92 | 0.05 | 1.39 |
| 13.26 | 48.48 | 35.70 | 0.75 | 0.07 | 1.27 |
| 12.87 | 48.41 | 35.47 | 0.69 | 0.06 | 1.22 |
