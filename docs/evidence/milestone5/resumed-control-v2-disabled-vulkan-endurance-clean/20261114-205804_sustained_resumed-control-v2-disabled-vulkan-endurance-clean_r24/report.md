# sustained - 20261114-205804_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r24

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.0 s - 2439 frames, 81.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15922 | 7791 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6667, BelowThresh 1427, NormalForce 37

Body materials: METAL 7751, PLASTIC 40

Surfaces: ASPHALT 6654, COBBLESTONE 1137

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.327 |
| whole frame, ms | 12.301 (p50) | 13.611 | 22.186 |
| all GE Lua, ms | | 1.179 | 3.015 |
| physics + vehicle Lua, ms | | 0.083 | 0.243 |
| render, ms | | 1.975 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.508 us per contact, 34.399 ms total, worst frame 0.353 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.22 | 22.19 | 0.00 | 3.01 | 0.07 | 2.10 |
| 8.86 | 20.93 | 0.01 | 1.35 | 0.09 | 1.65 |
| 24.60 | 20.71 | 0.01 | 0.97 | 0.05 | 1.48 |
| 23.54 | 18.53 | 0.01 | 1.08 | 0.07 | 1.66 |
| 13.51 | 18.11 | 0.01 | 1.04 | 0.09 | 1.56 |
