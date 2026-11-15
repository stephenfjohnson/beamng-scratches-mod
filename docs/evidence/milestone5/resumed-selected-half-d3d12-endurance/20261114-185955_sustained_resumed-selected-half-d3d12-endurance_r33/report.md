# sustained - 20261114-185955_sustained_resumed-selected-half-d3d12-endurance_r33

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.01 s - 2559 frames, 84.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16445 | 8654 | 64 | 629 | 113 | 203 | 235 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6288, BelowThresh 1476, NormalForce 27

Body materials: METAL 8648, PLASTIC 6

Surfaces: ASPHALT 7996, COBBLESTONE 658

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.367 | 25.755 | 412.238 |
| whole frame, ms | 10.671 (p50) | 32.581 | 418.444 |
| all GE Lua, ms | | 26.882 | 413.009 |
| physics + vehicle Lua, ms | | 0.079 | 0.486 |
| render, ms | | 2.205 | |

- Painter frames over 4 ms: 253; worst flush (project + bake) 412.203 ms, worst composite 0.131 ms.
- Detector: 3.043 us per contact, 70.213 ms total, worst frame 0.445 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 23.21 | 418.44 | 412.24 | 0.74 | 0.05 | 1.54 |
| 0.44 | 49.62 | 42.31 | 0.75 | 0.04 | 1.61 |
| 24.66 | 43.08 | 32.48 | 0.85 | 0.06 | 1.69 |
| 22.65 | 42.12 | 29.60 | 1.00 | 0.06 | 1.87 |
| 3.89 | 41.97 | 31.18 | 0.83 | 0.05 | 1.97 |
