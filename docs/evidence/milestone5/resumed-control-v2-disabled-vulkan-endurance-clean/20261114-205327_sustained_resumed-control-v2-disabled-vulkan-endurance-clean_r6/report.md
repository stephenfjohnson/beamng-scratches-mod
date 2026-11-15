# sustained - 20261114-205327_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.009 s - 2451 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14119 | 6554 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5871, BelowThresh 1677, NormalForce 17

Body materials: METAL 6531, PLASTIC 23

Surfaces: ASPHALT 5925, COBBLESTONE 629

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.033 |
| whole frame, ms | 12.235 (p50) | 13.498 | 20.491 |
| all GE Lua, ms | | 1.15 | 3.401 |
| physics + vehicle Lua, ms | | 0.081 | 0.292 |
| render, ms | | 1.895 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.52 us per contact, 31.787 ms total, worst frame 0.215 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 4.63 | 20.49 | 0.01 | 1.02 | 0.06 | 2.29 |
| 0.72 | 18.10 | 0.01 | 1.17 | 0.07 | 1.77 |
| 2.74 | 17.90 | 0.01 | 0.85 | 0.05 | 1.56 |
| 13.00 | 17.20 | 0.01 | 0.98 | 0.05 | 1.65 |
| 0.54 | 16.40 | 0.01 | 1.09 | 0.06 | 2.57 |
