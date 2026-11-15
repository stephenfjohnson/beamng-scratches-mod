# sustained - 20261114-193233_sustained_resumed-control-v2-disabled-vulkan-cold_r1

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.001 s - 2552 frames, 83.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14549 | 6567 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6458, BelowThresh 1519, NormalForce 5

Body materials: METAL 6561, PLASTIC 6

Surfaces: ASPHALT 6155, COBBLESTONE 412

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.057 |
| whole frame, ms | 11.887 (p50) | 13.378 | 37.813 |
| all GE Lua, ms | | 1.094 | 2.798 |
| physics + vehicle Lua, ms | | 0.078 | 0.521 |
| render, ms | | 1.788 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.467 us per contact, 28.685 ms total, worst frame 0.092 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 2.24 | 37.81 | 0.01 | 0.96 | 0.05 | 4.75 |
| 0.68 | 22.37 | 0.01 | 1.13 | 0.08 | 1.35 |
| 0.61 | 22.35 | 0.01 | 0.73 | 0.04 | 1.34 |
| 0.64 | 21.22 | 0.01 | 0.74 | 0.05 | 1.38 |
| 0.66 | 20.87 | 0.01 | 0.80 | 0.04 | 1.55 |
