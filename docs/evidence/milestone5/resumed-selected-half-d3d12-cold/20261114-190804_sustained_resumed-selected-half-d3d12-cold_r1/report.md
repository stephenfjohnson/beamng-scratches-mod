# sustained - 20261114-190804_sustained_resumed-selected-half-d3d12-cold_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.002 s - 2628 frames, 87.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15768 | 8734 | 48 | 516 | 103 | 163 | 194 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5822, BelowThresh 1202, NormalForce 10

Body materials: METAL 8719, PLASTIC 15

Surfaces: ASPHALT 8461, COBBLESTONE 273

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.595 | 13.574 | 32.77 |
| whole frame, ms | 10.65 (p50) | 23.447 | 43.884 |
| all GE Lua, ms | | 15.074 | 33.845 |
| physics + vehicle Lua, ms | | 0.084 | 0.384 |
| render, ms | | 2.375 | |

- Painter frames over 4 ms: 198; worst flush (project + bake) 32.742 ms, worst composite 0.18 ms.
- Detector: 3.626 us per contact, 77.047 ms total, worst frame 0.452 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 11.85 | 43.88 | 29.34 | 0.95 | 0.08 | 2.01 |
| 16.55 | 43.71 | 32.77 | 0.76 | 0.05 | 1.35 |
| 1.45 | 43.13 | 32.50 | 0.86 | 0.05 | 1.44 |
| 3.96 | 42.75 | 31.44 | 0.78 | 0.05 | 1.74 |
| 2.77 | 42.42 | 31.16 | 0.97 | 0.05 | 1.69 |
