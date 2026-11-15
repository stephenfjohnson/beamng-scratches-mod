# sustained - 20261114-211037_sustained_resumed-fixed2-full-d3d12-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.006 s - 2353 frames, 77.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15408 | 8750 | 41 | 568 | 116 | 243 | 254 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5193, BelowThresh 1446, NormalForce 19

Body materials: METAL 8744, PLASTIC 6

Surfaces: ASPHALT 8382, COBBLESTONE 368

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.702 | 25.4 | 446.31 |
| whole frame, ms | 10.736 (p50) | 32.885 | 453.078 |
| all GE Lua, ms | | 26.562 | 447.325 |
| physics + vehicle Lua, ms | | 0.094 | 2.153 |
| render, ms | | 2.103 | |

- Painter frames over 4 ms: 460; worst flush (project + bake) 446.28 ms, worst composite 0.131 ms.
- Detector: 3.426 us per contact, 70.104 ms total, worst frame 0.461 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.17 | 453.08 | 446.31 | 0.87 | 0.67 | 1.39 |
| 17.20 | 47.35 | 39.65 | 0.89 | 0.10 | 1.72 |
| 29.76 | 46.90 | 36.51 | 0.79 | 0.07 | 1.89 |
| 12.08 | 46.77 | 34.39 | 0.91 | 0.05 | 2.00 |
| 13.48 | 46.71 | 35.03 | 0.87 | 0.06 | 1.86 |
