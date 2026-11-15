# sustained - 20261114-201018_sustained_resumed-fixed2-full-vulkan-cold_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.002 s - 2264 frames, 75.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15407 | 8673 | 42 | 617 | 106 | 172 | 188 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5093, BelowThresh 1617, NormalForce 24

Body materials: METAL 8642, PLASTIC 31

Surfaces: ASPHALT 7707, COBBLESTONE 966

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.238 | 27.264 | 41.628 |
| whole frame, ms | 11.993 (p50) | 34.806 | 55.855 |
| all GE Lua, ms | | 28.735 | 42.899 |
| physics + vehicle Lua, ms | | 0.088 | 1.105 |
| render, ms | | 1.844 | |

- Painter frames over 4 ms: 167; worst flush (project + bake) 41.611 ms, worst composite 0.143 ms.
- Detector: 3.431 us per contact, 73.551 ms total, worst frame 0.502 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 8.22 | 55.86 | 41.63 | 0.98 | 0.05 | 1.29 |
| 24.70 | 55.52 | 41.18 | 0.90 | 0.05 | 1.47 |
| 8.49 | 55.29 | 40.27 | 0.89 | 0.07 | 1.33 |
| 7.40 | 54.81 | 39.56 | 0.87 | 0.05 | 1.54 |
| 9.31 | 54.57 | 40.16 | 0.81 | 0.05 | 1.34 |
