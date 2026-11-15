# sustained - 20261114-202210_sustained_resumed-fixed2-full-vulkan-endurance_r18

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.009 s - 2319 frames, 77.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16184 | 8891 | 49 | 640 | 100 | 148 | 166 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5894, BelowThresh 1370, NormalForce 29

Body materials: METAL 8833, PLASTIC 58

Surfaces: ASPHALT 7528, COBBLESTONE 1363

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.837 | 21.971 | 38.048 |
| whole frame, ms | 12.0 (p50) | 30.233 | 50.533 |
| all GE Lua, ms | | 22.924 | 39.541 |
| physics + vehicle Lua, ms | | 0.095 | 1.068 |
| render, ms | | 1.9 | |

- Painter frames over 4 ms: 150; worst flush (project + bake) 38.023 ms, worst composite 0.117 ms.
- Detector: 3.522 us per contact, 78.364 ms total, worst frame 0.419 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.03 | 50.53 | 38.05 | 0.98 | 0.07 | 1.21 |
| 0.28 | 50.00 | 36.89 | 0.80 | 0.07 | 1.18 |
| 3.56 | 47.83 | 34.67 | 0.93 | 0.08 | 1.27 |
| 26.14 | 47.76 | 35.24 | 0.99 | 0.07 | 1.28 |
| 16.53 | 47.76 | 34.54 | 0.73 | 0.05 | 1.73 |
