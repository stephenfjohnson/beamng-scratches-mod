# sustained - 20261114-192214_sustained_resumed-selected-half-vulkan-cold_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(2048); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(true); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2380 frames, 79.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16369 | 7907 | 48 | 579 | 111 | 152 | 157 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6298, BelowThresh 2144, NormalForce 20

Body materials: METAL 7868, PLASTIC 39

Surfaces: ASPHALT 7288, COBBLESTONE 619

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.852 | 26.017 | 45.552 |
| whole frame, ms | 11.735 (p50) | 33.421 | 52.395 |
| all GE Lua, ms | | 27.184 | 46.644 |
| physics + vehicle Lua, ms | | 0.082 | 0.823 |
| render, ms | | 1.747 | |

- Painter frames over 4 ms: 144; worst flush (project + bake) 45.529 ms, worst composite 0.085 ms.
- Detector: 3.035 us per contact, 71.582 ms total, worst frame 0.885 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.47 | 52.40 | 45.55 | 0.78 | 0.05 | 1.35 |
| 0.88 | 49.44 | 37.85 | 0.72 | 0.05 | 1.24 |
| 0.28 | 47.80 | 35.71 | 0.71 | 0.05 | 1.34 |
| 17.98 | 47.75 | 34.68 | 0.85 | 0.05 | 1.20 |
| 20.50 | 47.49 | 34.76 | 0.70 | 0.05 | 1.21 |
