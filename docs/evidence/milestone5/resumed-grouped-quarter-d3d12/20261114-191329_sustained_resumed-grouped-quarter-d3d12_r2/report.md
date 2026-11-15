# sustained - 20261114-191329_sustained_resumed-grouped-quarter-d3d12_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(1024); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.008 s - 2594 frames, 85.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13818 | 6050 | 45 | 407 | 97 | 157 | 182 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6941, BelowThresh 807, NormalForce 20

Body materials: METAL 6036, PLASTIC 14

Surfaces: ASPHALT 5750, COBBLESTONE 300

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.715 | 18.544 | 386.187 |
| whole frame, ms | 10.762 (p50) | 26.575 | 398.105 |
| all GE Lua, ms | | 19.497 | 387.296 |
| physics + vehicle Lua, ms | | 0.081 | 0.67 |
| render, ms | | 2.27 | |

- Painter frames over 4 ms: 150; worst flush (project + bake) 386.154 ms, worst composite 0.196 ms.
- Detector: 3.155 us per contact, 62.583 ms total, worst frame 0.341 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 19.76 | 398.11 | 386.19 | 0.83 | 0.05 | 2.14 |
| 1.21 | 51.51 | 39.62 | 1.24 | 0.14 | 2.58 |
| 0.28 | 46.41 | 34.17 | 1.06 | 0.08 | 2.51 |
| 2.21 | 44.80 | 33.92 | 1.00 | 0.08 | 1.84 |
| 13.56 | 44.42 | 33.67 | 0.71 | 0.04 | 1.74 |
