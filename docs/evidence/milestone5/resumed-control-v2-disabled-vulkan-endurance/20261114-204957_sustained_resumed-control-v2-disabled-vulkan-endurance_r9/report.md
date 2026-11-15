# sustained - 20261114-204957_sustained_resumed-control-v2-disabled-vulkan-endurance_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.001 s - 2458 frames, 81.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14605 | 7530 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5484, BelowThresh 1567, NormalForce 24

Body materials: METAL 7490, PLASTIC 40

Surfaces: ASPHALT 7331, COBBLESTONE 199

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.011 | 0.042 |
| whole frame, ms | 12.178 (p50) | 13.88 | 18.612 |
| all GE Lua, ms | | 1.178 | 4.245 |
| physics + vehicle Lua, ms | | 0.082 | 0.357 |
| render, ms | | 1.919 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.613 us per contact, 33.138 ms total, worst frame 0.523 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 16.58 | 18.61 | 0.01 | 1.05 | 0.05 | 1.64 |
| 8.78 | 18.04 | 0.01 | 0.92 | 0.05 | 1.58 |
| 8.68 | 17.96 | 0.01 | 1.17 | 0.07 | 1.55 |
| 13.18 | 17.93 | 0.01 | 1.04 | 0.07 | 1.54 |
| 10.06 | 17.60 | 0.01 | 0.93 | 0.05 | 2.72 |
