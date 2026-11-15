# sustained - 20261114-202256_sustained_resumed-fixed2-full-vulkan-endurance_r21

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2220 frames, 74.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13181 | 6705 | 61 | 529 | 125 | 232 | 245 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5188, BelowThresh 1260, NormalForce 28

Body materials: METAL 6688, PLASTIC 17

Surfaces: ASPHALT 6012, COBBLESTONE 693

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.005 | 29.612 | 43.443 |
| whole frame, ms | 11.812 (p50) | 37.399 | 55.445 |
| all GE Lua, ms | | 30.634 | 44.343 |
| physics + vehicle Lua, ms | | 0.107 | 1.119 |
| render, ms | | 2.106 | |

- Painter frames over 4 ms: 224; worst flush (project + bake) 43.418 ms, worst composite 0.158 ms.
- Detector: 3.793 us per contact, 70.07 ms total, worst frame 0.405 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 13.70 | 55.44 | 43.44 | 0.89 | 0.06 | 1.44 |
| 20.13 | 49.30 | 37.00 | 0.76 | 0.04 | 1.36 |
| 20.40 | 49.05 | 35.47 | 0.81 | 0.05 | 1.19 |
| 15.10 | 48.50 | 34.77 | 0.85 | 0.06 | 1.50 |
| 17.73 | 48.44 | 35.34 | 0.95 | 0.05 | 1.23 |
