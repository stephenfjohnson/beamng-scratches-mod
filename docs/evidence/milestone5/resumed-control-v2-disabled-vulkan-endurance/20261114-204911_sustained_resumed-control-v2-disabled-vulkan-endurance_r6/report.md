# sustained - 20261114-204911_sustained_resumed-control-v2-disabled-vulkan-endurance_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.011 s - 2447 frames, 81.5 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14462 | 7436 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5404, BelowThresh 1601, NormalForce 21

Body materials: METAL 7407, PLASTIC 29

Surfaces: ASPHALT 6933, COBBLESTONE 503

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.047 |
| whole frame, ms | 12.266 (p50) | 13.426 | 23.511 |
| all GE Lua, ms | | 1.161 | 3.057 |
| physics + vehicle Lua, ms | | 0.081 | 0.346 |
| render, ms | | 1.921 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.551 us per contact, 32.021 ms total, worst frame 0.107 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.09 | 23.51 | 0.00 | 1.29 | 0.06 | 4.13 |
| 17.64 | 17.27 | 0.01 | 0.94 | 0.10 | 1.82 |
| 21.86 | 16.82 | 0.01 | 0.80 | 0.04 | 1.35 |
| 18.16 | 16.75 | 0.01 | 0.90 | 0.05 | 1.58 |
| 24.98 | 16.74 | 0.01 | 0.90 | 0.05 | 2.93 |
