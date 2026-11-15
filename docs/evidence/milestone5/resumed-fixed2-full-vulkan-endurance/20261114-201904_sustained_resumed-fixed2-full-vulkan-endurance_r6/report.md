# sustained - 20261114-201904_sustained_resumed-fixed2-full-vulkan-endurance_r6

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.005 s - 2268 frames, 75.6 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15383 | 7649 | 55 | 571 | 127 | 208 | 222 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6119, BelowThresh 1583, NormalForce 32

Body materials: METAL 7621, PLASTIC 28

Surfaces: ASPHALT 6781, COBBLESTONE 868

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.779 | 31.34 | 36.562 |
| whole frame, ms | 11.76 (p50) | 39.628 | 49.191 |
| all GE Lua, ms | | 32.253 | 37.679 |
| physics + vehicle Lua, ms | | 0.093 | 1.117 |
| render, ms | | 1.825 | |

- Painter frames over 4 ms: 202; worst flush (project + bake) 36.532 ms, worst composite 0.327 ms.
- Detector: 3.298 us per contact, 69.722 ms total, worst frame 0.565 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 6.27 | 49.19 | 36.56 | 0.86 | 0.05 | 1.48 |
| 27.12 | 48.73 | 36.03 | 0.87 | 0.06 | 1.57 |
| 27.72 | 48.72 | 35.68 | 0.72 | 0.05 | 1.35 |
| 0.27 | 48.42 | 36.03 | 0.75 | 0.05 | 1.49 |
| 23.19 | 48.17 | 34.91 | 0.85 | 0.06 | 1.39 |
