# sustained - 20261114-194403_sustained_resumed-selected-half-vulkan-endurance_r33

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.01 s - 2354 frames, 78.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14007 | 7557 | 53 | 500 | 110 | 174 | 196 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5222, BelowThresh 1221, NormalForce 7

Body materials: METAL 7538, PLASTIC 19

Surfaces: ASPHALT 7422, COBBLESTONE 135

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.151 | 30.753 | 39.867 |
| whole frame, ms | 11.742 (p50) | 37.034 | 52.44 |
| all GE Lua, ms | | 31.734 | 40.944 |
| physics + vehicle Lua, ms | | 0.086 | 0.619 |
| render, ms | | 1.829 | |

- Painter frames over 4 ms: 165; worst flush (project + bake) 39.847 ms, worst composite 0.095 ms.
- Detector: 3.385 us per contact, 67.031 ms total, worst frame 0.523 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.76 | 52.44 | 39.77 | 0.80 | 0.06 | 1.38 |
| 12.36 | 51.47 | 39.87 | 1.01 | 0.04 | 1.30 |
| 29.66 | 48.82 | 37.02 | 0.73 | 0.05 | 1.25 |
| 29.80 | 48.54 | 35.77 | 1.03 | 0.08 | 1.44 |
| 14.11 | 48.23 | 34.97 | 0.81 | 0.04 | 1.44 |
