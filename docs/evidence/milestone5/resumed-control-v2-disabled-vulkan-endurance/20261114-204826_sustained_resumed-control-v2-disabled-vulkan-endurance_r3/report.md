# sustained - 20261114-204826_sustained_resumed-control-v2-disabled-vulkan-endurance_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); if scratches_detect then scratches_detect.setPaintEnabled(false) end`

Settled: False after 30.002 s - 2449 frames, 81.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15300 | 7540 | 0 | 0 | 0 | 0 | 0 | 0% | 0 | 0 |

Rejected contacts: PartExcluded 5756, BelowThresh 1973, NormalForce 31

Body materials: METAL 7515, PLASTIC 25

Surfaces: ASPHALT 7165, COBBLESTONE 375

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.008 | 0.01 | 0.049 |
| whole frame, ms | 12.257 (p50) | 13.638 | 16.323 |
| all GE Lua, ms | | 1.185 | 3.365 |
| physics + vehicle Lua, ms | | 0.084 | 0.34 |
| render, ms | | 1.795 | |

- Painter frames over 4 ms: 0; worst flush (project + bake) 0.0 ms, worst composite 0.0 ms.
- Detector: 1.518 us per contact, 31.743 ms total, worst frame 0.276 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.48 | 16.32 | 0.01 | 0.89 | 0.05 | 1.80 |
| 25.95 | 16.28 | 0.01 | 1.18 | 0.08 | 2.64 |
| 4.39 | 16.22 | 0.01 | 0.72 | 0.05 | 2.61 |
| 2.98 | 16.11 | 0.01 | 0.87 | 0.05 | 1.34 |
| 4.46 | 16.09 | 0.01 | 1.00 | 0.07 | 2.56 |
