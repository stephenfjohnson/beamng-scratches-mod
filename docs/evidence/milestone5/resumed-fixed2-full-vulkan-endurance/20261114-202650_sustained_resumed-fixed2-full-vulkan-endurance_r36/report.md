# sustained - 20261114-202650_sustained_resumed-fixed2-full-vulkan-endurance_r36

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.001 s - 2278 frames, 75.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 14329 | 7326 | 48 | 529 | 125 | 181 | 190 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5361, BelowThresh 1615, NormalForce 27

Body materials: METAL 7265, PLASTIC 61

Surfaces: ASPHALT 6970, COBBLESTONE 356

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.266 | 25.654 | 37.238 |
| whole frame, ms | 11.792 (p50) | 33.443 | 289.051 |
| all GE Lua, ms | | 26.626 | 38.196 |
| physics + vehicle Lua, ms | | 0.098 | 10.903 |
| render, ms | | 2.17 | |

- Painter frames over 4 ms: 186; worst flush (project + bake) 37.209 ms, worst composite 1.468 ms.
- Detector: 3.875 us per contact, 76.015 ms total, worst frame 0.576 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 29.34 | 289.05 | 0.01 | 0.90 | 0.06 | 1.32 |
| 0.28 | 50.30 | 37.07 | 0.89 | 0.09 | 1.57 |
| 11.68 | 49.06 | 37.24 | 0.78 | 0.06 | 1.30 |
| 28.42 | 48.17 | 35.97 | 1.00 | 0.05 | 1.31 |
| 23.10 | 48.00 | 35.61 | 0.79 | 0.04 | 1.21 |
