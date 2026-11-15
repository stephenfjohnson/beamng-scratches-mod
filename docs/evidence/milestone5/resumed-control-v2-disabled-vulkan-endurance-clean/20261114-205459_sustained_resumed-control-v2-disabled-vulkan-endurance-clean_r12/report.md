# sustained - 20261114-205459_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.006 s - 2469 frames, 82.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16739 | 8781 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6320, BelowThresh 1551, NormalForce 87

Body materials: METAL 8741, PLASTIC 40

Surfaces: ASPHALT 7588, COBBLESTONE 1193

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.035 |
| whole frame, ms | 12.166 (p50) | 13.435 | 22.812 |
| all GE Lua, ms | | 1.121 | 2.634 |
| physics + vehicle Lua, ms | | 0.079 | 0.222 |
| render, ms | | 1.699 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.448 us per contact, 34.042 ms total, worst frame 0.081 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 8.02 | 22.81 | 0.01 | 0.94 | 0.06 | 1.55 |
| 15.19 | 22.08 | 0.03 | 0.78 | 0.07 | 1.61 |
| 12.41 | 19.17 | 0.01 | 2.45 | 0.06 | 1.89 |
| 18.73 | 18.98 | 0.01 | 0.87 | 0.04 | 1.45 |
| 14.46 | 17.63 | 0.01 | 1.11 | 0.05 | 1.41 |
