# sustained - 20261114-210156_sustained_resumed-control-v2-disabled-vulkan-endurance-clean_r39

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.011 s - 2460 frames, 81.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15854 | 8146 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5517, BelowThresh 2173, NormalForce 18

Body materials: METAL 8088, PLASTIC 58

Surfaces: ASPHALT 7628, COBBLESTONE 518

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.184 |
| whole frame, ms | 12.167 (p50) | 13.991 | 18.519 |
| all GE Lua, ms | | 1.163 | 3.414 |
| physics + vehicle Lua, ms | | 0.084 | 0.36 |
| render, ms | | 2.005 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.513 us per contact, 34.367 ms total, worst frame 0.13 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 17.90 | 18.52 | 0.01 | 1.05 | 0.07 | 2.63 |
| 21.30 | 17.97 | 0.01 | 0.80 | 0.05 | 2.26 |
| 22.09 | 17.76 | 0.01 | 0.92 | 0.06 | 1.42 |
| 20.51 | 17.18 | 0.01 | 0.83 | 0.05 | 1.62 |
| 20.78 | 17.00 | 0.01 | 0.88 | 0.05 | 1.46 |
