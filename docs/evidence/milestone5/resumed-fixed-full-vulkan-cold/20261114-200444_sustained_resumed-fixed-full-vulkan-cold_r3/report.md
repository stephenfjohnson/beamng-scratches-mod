# sustained - 20261114-200444_sustained_resumed-fixed-full-vulkan-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.001 s - 2208 frames, 73.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14622 | 7107 | 66 | 600 | 133 | 230 | 251 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5585, BelowThresh 1918, NormalForce 12

Body materials: METAL 7086, PLASTIC 21

Surfaces: ASPHALT 6469, COBBLESTONE 638

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.752 | 26.042 | 38.963 |
| whole frame, ms | 11.789 (p50) | 34.318 | 52.229 |
| all GE Lua, ms | | 27.302 | 40.064 |
| physics + vehicle Lua, ms | | 0.109 | 1.78 |
| render, ms | | 2.229 | |

- Painter frames over 4 ms: 229; worst flush (project + bake) 38.938 ms, worst composite 0.193 ms.
- Detector: 3.858 us per contact, 79.515 ms total, worst frame 0.518 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 23.93 | 52.23 | 38.96 | 1.30 | 0.13 | 1.79 |
| 12.41 | 51.25 | 38.95 | 0.76 | 0.06 | 1.51 |
| 24.70 | 48.81 | 34.84 | 0.92 | 0.06 | 1.38 |
| 4.11 | 48.65 | 36.63 | 0.92 | 0.05 | 1.33 |
| 29.95 | 47.94 | 35.02 | 1.01 | 0.06 | 1.66 |
