# sustained - 20261114-185603_sustained_resumed-selected-half-d3d12-endurance_r18

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.0 s - 2614 frames, 87.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16217 | 7773 | 51 | 523 | 102 | 142 | 168 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6766, BelowThresh 1663, NormalForce 15

Body materials: METAL 7749, PLASTIC 24

Surfaces: ASPHALT 7616, COBBLESTONE 157

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.441 | 8.244 | 39.472 |
| whole frame, ms | 10.683 (p50) | 17.076 | 46.236 |
| all GE Lua, ms | | 9.183 | 40.467 |
| physics + vehicle Lua, ms | | 0.082 | 0.367 |
| render, ms | | 2.45 | |

- Painter frames over 4 ms: 187; worst flush (project + bake) 39.443 ms, worst composite 0.153 ms.
- Detector: 3.137 us per contact, 69.661 ms total, worst frame 0.337 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.45 | 46.24 | 39.47 | 0.91 | 0.06 | 1.54 |
| 26.48 | 43.88 | 32.58 | 0.80 | 0.07 | 1.70 |
| 3.01 | 43.11 | 31.91 | 0.76 | 0.05 | 2.25 |
| 2.73 | 42.02 | 30.62 | 1.67 | 0.06 | 1.94 |
| 0.27 | 41.45 | 30.02 | 0.98 | 0.05 | 1.93 |
