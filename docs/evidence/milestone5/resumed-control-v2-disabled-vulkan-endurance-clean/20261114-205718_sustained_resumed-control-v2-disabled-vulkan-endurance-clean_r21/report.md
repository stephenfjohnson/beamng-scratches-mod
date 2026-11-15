# sustained - 20261114-205718_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r21

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.004 s - 2448 frames, 81.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13366 | 6472 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5511, BelowThresh 1376, NormalForce 7

Body materials: METAL 6437, PLASTIC 35

Surfaces: ASPHALT 5905, COBBLESTONE 567

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.16 |
| whole frame, ms | 12.245 (p50) | 13.394 | 19.204 |
| all GE Lua, ms | | 1.12 | 3.476 |
| physics + vehicle Lua, ms | | 0.078 | 0.194 |
| render, ms | | 1.82 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.627 us per contact, 31.67 ms total, worst frame 0.222 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.96 | 19.20 | 0.01 | 0.77 | 0.06 | 3.00 |
| 16.19 | 19.03 | 0.01 | 0.87 | 0.05 | 3.11 |
| 0.04 | 17.63 | 0.01 | 0.73 | 0.05 | 1.72 |
| 12.55 | 16.93 | 0.01 | 0.90 | 0.05 | 2.91 |
| 19.59 | 16.41 | 0.01 | 1.02 | 0.06 | 2.43 |
