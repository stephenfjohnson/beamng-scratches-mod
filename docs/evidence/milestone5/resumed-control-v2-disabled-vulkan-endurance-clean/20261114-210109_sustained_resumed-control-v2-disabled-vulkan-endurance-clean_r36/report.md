# sustained - 20261114-210109_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r36

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.009 s - 2465 frames, 82.1 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14207 | 7223 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5473, BelowThresh 1493, NormalForce 18

Body materials: METAL 7206, PLASTIC 17

Surfaces: ASPHALT 7146, COBBLESTONE 77

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.091 |
| whole frame, ms | 12.188 (p50) | 13.226 | 17.344 |
| all GE Lua, ms | | 1.136 | 2.79 |
| physics + vehicle Lua, ms | | 0.079 | 0.266 |
| render, ms | | 1.868 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.566 us per contact, 32.271 ms total, worst frame 0.211 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 24.05 | 17.34 | 0.01 | 1.05 | 0.06 | 2.40 |
| 8.79 | 17.19 | 0.01 | 0.87 | 0.05 | 2.99 |
| 6.74 | 16.44 | 0.01 | 0.95 | 0.06 | 1.38 |
| 13.86 | 16.41 | 0.01 | 0.84 | 0.08 | 2.51 |
| 24.96 | 16.08 | 0.01 | 1.49 | 0.05 | 1.56 |
