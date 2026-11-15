# sustained - 20261114-194014_sustained_resumed-selected-half-vulkan-endurance_r18

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.005 s - 2368 frames, 78.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14030 | 7407 | 62 | 520 | 125 | 160 | 189 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5213, BelowThresh 1395, NormalForce 15

Body materials: METAL 7385, PLASTIC 22

Surfaces: ASPHALT 7254, COBBLESTONE 153

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.038 | 29.666 | 37.46 |
| whole frame, ms | 11.809 (p50) | 36.084 | 49.903 |
| all GE Lua, ms | | 30.51 | 38.63 |
| physics + vehicle Lua, ms | | 0.079 | 0.6 |
| render, ms | | 1.747 | |

- Painter frames over 4 ms: 156; worst flush (project + bake) 37.441 ms, worst composite 0.271 ms.
- Detector: 3.393 us per contact, 67.416 ms total, worst frame 0.599 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.10 | 49.90 | 37.46 | 0.78 | 0.05 | 1.27 |
| 23.03 | 48.88 | 35.74 | 0.82 | 0.05 | 1.35 |
| 14.36 | 48.70 | 36.61 | 0.86 | 0.06 | 1.17 |
| 19.50 | 48.36 | 34.44 | 1.07 | 0.06 | 1.47 |
| 13.55 | 48.07 | 35.25 | 0.95 | 0.05 | 1.20 |
