# sustained - 20261114-202515_sustained_resumed-fixed2-full-vulkan-endurance_r30

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.002 s - 2258 frames, 75.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 12594 | 6678 | 53 | 495 | 127 | 213 | 228 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5046, BelowThresh 844, NormalForce 26

Body materials: METAL 6667, PLASTIC 11

Surfaces: ASPHALT 6323, COBBLESTONE 355

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.744 | 30.304 | 40.238 |
| whole frame, ms | 11.868 (p50) | 38.135 | 52.402 |
| all GE Lua, ms | | 31.272 | 41.233 |
| physics + vehicle Lua, ms | | 0.092 | 1.448 |
| render, ms | | 1.773 | |

- Painter frames over 4 ms: 203; worst flush (project + bake) 40.218 ms, worst composite 0.198 ms.
- Detector: 3.649 us per contact, 64.491 ms total, worst frame 0.441 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 25.31 | 52.40 | 40.24 | 0.79 | 0.05 | 1.25 |
| 15.00 | 50.47 | 37.36 | 1.07 | 0.06 | 1.27 |
| 0.28 | 50.08 | 35.78 | 0.99 | 0.08 | 1.45 |
| 17.16 | 49.72 | 36.40 | 0.86 | 0.05 | 1.27 |
| 22.00 | 48.70 | 36.22 | 0.93 | 0.06 | 1.45 |
