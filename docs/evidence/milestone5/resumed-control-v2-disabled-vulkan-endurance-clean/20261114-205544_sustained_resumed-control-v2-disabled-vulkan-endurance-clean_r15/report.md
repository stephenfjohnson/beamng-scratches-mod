# sustained - 20261114-205544_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.003 s - 2444 frames, 81.4 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14296 | 6979 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 6208, BelowThresh 1073, NormalForce 36

Body materials: METAL 6957, PLASTIC 22

Surfaces: ASPHALT 6153, COBBLESTONE 826

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.049 |
| whole frame, ms | 12.271 (p50) | 13.504 | 17.164 |
| all GE Lua, ms | | 1.14 | 3.177 |
| physics + vehicle Lua, ms | | 0.079 | 0.245 |
| render, ms | | 1.852 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.541 us per contact, 31.919 ms total, worst frame 0.048 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.02 | 17.16 | 0.01 | 1.15 | 0.06 | 2.57 |
| 7.51 | 16.34 | 0.01 | 0.94 | 0.08 | 4.22 |
| 14.18 | 16.27 | 0.01 | 1.18 | 0.06 | 1.54 |
| 25.16 | 16.16 | 0.01 | 0.82 | 0.06 | 1.48 |
| 28.32 | 15.92 | 0.01 | 0.85 | 0.05 | 2.80 |
