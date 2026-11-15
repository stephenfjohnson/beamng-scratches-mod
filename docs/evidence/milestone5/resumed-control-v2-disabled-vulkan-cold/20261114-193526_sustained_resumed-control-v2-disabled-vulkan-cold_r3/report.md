# sustained - 20261114-193526_sustained_resumed-control-v2-disabled-vulkan-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(false) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(6); scratches_paint.setFlushInterval(0.2); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24)`

Settled: False after 30.003 s - 2500 frames, 81.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15358 | 6271 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 7254, BelowThresh 1800, NormalForce 33

Body materials: METAL 6238, PLASTIC 33

Surfaces: ASPHALT 5444, COBBLESTONE 827

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.006 | 0.008 | 0.044 |
| whole frame, ms | 12.138 (p50) | 13.96 | 36.186 |
| all GE Lua, ms | | 1.098 | 3.418 |
| physics + vehicle Lua, ms | | 0.079 | 0.325 |
| render, ms | | 1.75 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.488 us per contact, 30.219 ms total, worst frame 0.393 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 1.28 | 36.19 | 0.01 | 0.83 | 0.06 | 1.46 |
| 5.96 | 21.98 | 0.01 | 0.81 | 0.05 | 1.64 |
| 5.94 | 21.33 | 0.00 | 1.06 | 0.06 | 1.52 |
| 5.98 | 21.14 | 0.01 | 0.83 | 0.05 | 1.50 |
| 5.92 | 21.13 | 0.00 | 1.80 | 0.06 | 1.77 |
