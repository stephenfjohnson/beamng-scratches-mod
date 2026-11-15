# sustained - 20261114-205850_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r27

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.004 s - 2468 frames, 82.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14970 | 7832 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5444, BelowThresh 1667, NormalForce 27

Body materials: METAL 7766, PLASTIC 66

Surfaces: ASPHALT 7157, COBBLESTONE 675

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.044 |
| whole frame, ms | 12.16 (p50) | 13.518 | 17.962 |
| all GE Lua, ms | | 1.147 | 3.273 |
| physics + vehicle Lua, ms | | 0.081 | 0.39 |
| render, ms | | 1.835 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.525 us per contact, 32.862 ms total, worst frame 0.09 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.55 | 17.96 | 0.01 | 1.04 | 0.05 | 3.17 |
| 2.10 | 17.17 | 0.01 | 0.94 | 0.06 | 2.04 |
| 26.17 | 16.67 | 0.01 | 0.78 | 0.04 | 1.50 |
| 20.88 | 16.57 | 0.01 | 0.80 | 0.04 | 2.41 |
| 3.56 | 16.34 | 0.01 | 1.09 | 0.06 | 1.79 |
