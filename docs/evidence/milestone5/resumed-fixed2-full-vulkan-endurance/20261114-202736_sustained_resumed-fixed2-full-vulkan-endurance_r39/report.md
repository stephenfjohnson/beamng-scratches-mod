# sustained - 20261114-202736_sustained_resumed-fixed2-full-vulkan-endurance_r39

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.011 s - 2187 frames, 72.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15453 | 8708 | 67 | 658 | 148 | 276 | 280 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5037, BelowThresh 1692, NormalForce 16

Body materials: METAL 8685, PLASTIC 23

Surfaces: ASPHALT 7744, COBBLESTONE 964

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 3.109 | 28.094 | 36.526 |
| whole frame, ms | 11.897 (p50) | 35.496 | 49.208 |
| all GE Lua, ms | | 29.383 | 37.704 |
| physics + vehicle Lua, ms | | 0.105 | 10.927 |
| render, ms | | 2.065 | |

- Painter frames over 4 ms: 257; worst flush (project + bake) 36.491 ms, worst composite 0.118 ms.
- Detector: 3.794 us per contact, 80.805 ms total, worst frame 0.386 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.28 | 49.21 | 36.53 | 0.84 | 0.09 | 1.20 |
| 23.16 | 48.77 | 33.87 | 0.88 | 0.07 | 1.77 |
| 25.89 | 48.57 | 36.34 | 0.84 | 0.06 | 1.33 |
| 21.85 | 48.57 | 35.33 | 1.11 | 0.06 | 1.41 |
| 25.72 | 48.46 | 33.59 | 0.89 | 0.05 | 1.30 |
