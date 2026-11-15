# sustained - 20261114-211123_sustained_resumed-fixed2-full-d3d12-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2391 frames, 79.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17251 | 9041 | 47 | 592 | 117 | 211 | 229 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6575, BelowThresh 1599, NormalForce 36

Body materials: METAL 9030, PLASTIC 11

Surfaces: ASPHALT 8445, COBBLESTONE 596

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.133 | 24.142 | 47.134 |
| whole frame, ms | 10.788 (p50) | 30.811 | 53.721 |
| all GE Lua, ms | | 24.995 | 47.885 |
| physics + vehicle Lua, ms | | 0.096 | 2.267 |
| render, ms | | 2.168 | |

- Painter frames over 4 ms: 414; worst flush (project + bake) 47.104 ms, worst composite 0.141 ms.
- Detector: 3.279 us per contact, 76.261 ms total, worst frame 0.429 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.44 | 53.72 | 47.13 | 0.84 | 0.04 | 1.39 |
| 2.70 | 48.12 | 33.96 | 0.71 | 0.05 | 1.78 |
| 28.26 | 47.24 | 36.30 | 0.87 | 0.06 | 1.74 |
| 1.85 | 46.99 | 36.68 | 0.69 | 0.04 | 1.67 |
| 1.98 | 45.38 | 31.00 | 1.12 | 0.06 | 1.88 |
