# sustained - 20261114-210023_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r33

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.009 s - 2465 frames, 82.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15767 | 7948 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5923, BelowThresh 1881, NormalForce 15

Body materials: METAL 7919, PLASTIC 29

Surfaces: ASPHALT 6657, COBBLESTONE 1291

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.093 |
| whole frame, ms | 12.171 (p50) | 13.301 | 18.594 |
| all GE Lua, ms | | 1.11 | 3.088 |
| physics + vehicle Lua, ms | | 0.078 | 0.185 |
| render, ms | | 1.69 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.449 us per contact, 32.403 ms total, worst frame 0.114 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 28.63 | 18.59 | 0.01 | 1.14 | 0.09 | 1.73 |
| 29.10 | 17.33 | 0.01 | 0.98 | 0.05 | 2.51 |
| 14.32 | 16.84 | 0.01 | 1.01 | 0.06 | 2.54 |
| 23.80 | 16.20 | 0.01 | 0.85 | 0.06 | 1.46 |
| 14.18 | 15.81 | 0.01 | 1.05 | 0.05 | 1.61 |
