# sustained - 20261114-205042_sustained_resumed-control-v2-disabled-vulkan-endurance_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.004 s - 2456 frames, 81.8 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15947 | 8121 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6242, BelowThresh 1556, NormalForce 28

Body materials: METAL 8072, PLASTIC 49

Surfaces: ASPHALT 7149, COBBLESTONE 972

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.043 |
| whole frame, ms | 12.225 (p50) | 13.436 | 17.137 |
| all GE Lua, ms | | 1.12 | 3.255 |
| physics + vehicle Lua, ms | | 0.08 | 0.55 |
| render, ms | | 1.869 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.467 us per contact, 32.944 ms total, worst frame 0.162 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 16.26 | 17.14 | 0.01 | 0.95 | 0.06 | 1.87 |
| 6.75 | 16.93 | 0.01 | 0.69 | 0.04 | 1.41 |
| 6.83 | 16.44 | 0.01 | 0.79 | 0.04 | 2.30 |
| 9.30 | 16.39 | 0.01 | 0.91 | 0.06 | 3.82 |
| 9.47 | 16.30 | 0.01 | 0.94 | 0.05 | 2.50 |
