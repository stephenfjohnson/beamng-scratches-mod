# sustained - 20261114-205936_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r30

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.011 s - 2463 frames, 82.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13513 | 6623 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5412, BelowThresh 1459, NormalForce 19

Body materials: METAL 6602, PLASTIC 21

Surfaces: ASPHALT 6419, COBBLESTONE 204

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.119 |
| whole frame, ms | 12.181 (p50) | 13.499 | 23.546 |
| all GE Lua, ms | | 1.152 | 3.67 |
| physics + vehicle Lua, ms | | 0.08 | 0.369 |
| render, ms | | 1.802 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.602 us per contact, 31.635 ms total, worst frame 0.045 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 24.99 | 23.55 | 0.01 | 2.97 | 0.08 | 1.64 |
| 21.25 | 16.65 | 0.01 | 0.93 | 0.06 | 1.40 |
| 21.11 | 16.37 | 0.01 | 2.87 | 0.06 | 1.73 |
| 19.70 | 16.11 | 0.01 | 0.95 | 0.07 | 2.27 |
| 4.53 | 15.96 | 0.01 | 1.40 | 0.07 | 2.97 |
