# sustained - 20261114-190944_sustained_resumed-selected-half-d3d12-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2543 frames, 84.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14773 | 7376 | 61 | 570 | 137 | 234 | 260 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6166, BelowThresh 1176, NormalForce 55

Body materials: METAL 7371, PLASTIC 5

Surfaces: ASPHALT 6544, COBBLESTONE 832

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.477 | 26.21 | 38.196 |
| whole frame, ms | 10.547 (p50) | 33.956 | 50.27 |
| all GE Lua, ms | | 27.131 | 39.521 |
| physics + vehicle Lua, ms | | 0.082 | 0.66 |
| render, ms | | 2.162 | |

- Painter frames over 4 ms: 290; worst flush (project + bake) 38.158 ms, worst composite 0.151 ms.
- Detector: 3.233 us per contact, 69.71 ms total, worst frame 0.482 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.11 | 50.27 | 38.20 | 0.81 | 0.05 | 1.80 |
| 16.35 | 45.44 | 34.70 | 0.76 | 0.05 | 1.75 |
| 12.95 | 45.34 | 34.78 | 0.92 | 0.05 | 1.84 |
| 12.29 | 43.87 | 32.50 | 0.70 | 0.04 | 1.97 |
| 14.78 | 43.66 | 30.31 | 0.82 | 0.05 | 2.48 |
