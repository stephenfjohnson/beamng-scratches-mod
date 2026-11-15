# sustained - 20261114-202123_sustained_resumed-fixed2-full-vulkan-endurance_r15

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.004 s - 2340 frames, 77.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15648 | 8322 | 57 | 563 | 105 | 138 | 150 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6045, BelowThresh 1269, NormalForce 12

Body materials: METAL 8278, PLASTIC 44

Surfaces: ASPHALT 7487, COBBLESTONE 835

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.745 | 11.802 | 38.936 |
| whole frame, ms | 11.983 (p50) | 20.714 | 51.81 |
| all GE Lua, ms | | 12.884 | 39.872 |
| physics + vehicle Lua, ms | | 0.085 | 0.882 |
| render, ms | | 1.796 | |

- Painter frames over 4 ms: 140; worst flush (project + bake) 38.915 ms, worst composite 0.135 ms.
- Detector: 3.532 us per contact, 75.672 ms total, worst frame 0.498 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.38 | 51.81 | 38.94 | 0.82 | 0.08 | 1.30 |
| 0.27 | 49.18 | 36.40 | 0.79 | 0.04 | 1.29 |
| 13.66 | 48.46 | 34.98 | 0.98 | 0.08 | 1.45 |
| 19.38 | 48.06 | 35.98 | 0.69 | 0.04 | 1.39 |
| 3.09 | 48.00 | 35.97 | 0.74 | 0.05 | 1.20 |
