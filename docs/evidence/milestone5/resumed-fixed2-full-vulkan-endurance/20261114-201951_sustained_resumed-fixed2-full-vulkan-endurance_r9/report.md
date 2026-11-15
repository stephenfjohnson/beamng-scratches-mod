# sustained - 20261114-201951_sustained_resumed-fixed2-full-vulkan-endurance_r9

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true)`

Settled: False after 30.01 s - 2289 frames, 76.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 13658 | 6590 | 51 | 501 | 119 | 201 | 213 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5494, BelowThresh 1508, NormalForce 66

Body materials: METAL 6537, PLASTIC 53

Surfaces: ASPHALT 6110, COBBLESTONE 480

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 2.672 | 31.726 | 38.239 |
| whole frame, ms | 11.783 (p50) | 38.27 | 50.474 |
| all GE Lua, ms | | 32.599 | 39.143 |
| physics + vehicle Lua, ms | | 0.085 | 1.84 |
| render, ms | | 1.709 | |

- Painter frames over 4 ms: 197; worst flush (project + bake) 38.209 ms, worst composite 0.195 ms.
- Detector: 3.276 us per contact, 63.433 ms total, worst frame 0.413 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.28 | 50.47 | 36.40 | 0.82 | 0.08 | 1.15 |
| 0.96 | 49.85 | 37.11 | 0.83 | 0.05 | 1.24 |
| 8.85 | 48.22 | 32.14 | 0.98 | 0.06 | 2.23 |
| 29.96 | 48.17 | 34.58 | 0.92 | 0.07 | 1.36 |
| 3.84 | 48.14 | 35.40 | 0.71 | 0.06 | 1.25 |
