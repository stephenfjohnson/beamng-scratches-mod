# sustained - 20261114-185517_sustained_resumed-selected-half-d3d12-endurance_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.001 s - 2594 frames, 86.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14710 | 7104 | 49 | 509 | 117 | 189 | 209 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6206, BelowThresh 1383, NormalForce 17

Body materials: METAL 7077, PLASTIC 27

Surfaces: ASPHALT 6396, COBBLESTONE 708

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.904 | 22.51 | 37.864 |
| whole frame, ms | 10.65 (p50) | 29.466 | 45.623 |
| all GE Lua, ms | | 23.497 | 38.803 |
| physics + vehicle Lua, ms | | 0.081 | 0.223 |
| render, ms | | 2.234 | |

- Painter frames over 4 ms: 213; worst flush (project + bake) 37.838 ms, worst composite 0.094 ms.
- Detector: 3.087 us per contact, 65.028 ms total, worst frame 0.35 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.45 | 45.62 | 37.86 | 0.64 | 0.06 | 1.74 |
| 12.42 | 44.10 | 34.13 | 0.87 | 0.06 | 2.02 |
| 1.55 | 43.01 | 36.14 | 0.77 | 0.03 | 1.53 |
| 15.02 | 42.47 | 30.46 | 1.27 | 0.07 | 1.87 |
| 11.73 | 42.39 | 31.77 | 1.14 | 0.05 | 1.83 |
