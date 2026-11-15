# sustained - 20261114-224816_sustained_synth-full-d3d12-endurance_r39

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.008 s - 2639 frames, 87.0 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 15279 | 7713 | 73 | 599 | 118 | 221 | 259 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 5584, BelowThresh 1958, NormalForce 24

Body materials: METAL 7697, PLASTIC 16

Surfaces: ASPHALT 6979, COBBLESTONE 734

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.47 | 11.772 | 447.234 |
| whole frame, ms | 10.788 (p50) | 22.484 | 456.585 |
| all GE Lua, ms | | 12.747 | 448.341 |
| physics + vehicle Lua, ms | | 0.088 | 0.996 |
| render, ms | | 2.4 | |

- Painter frames over 4 ms: 259; worst flush (project + bake) 3.92 ms, worst composite 0.126 ms.
- Detector: 3.242 us per contact, 70.663 ms total, worst frame 0.386 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 3.23 | 456.59 | 447.23 | 1.60 | 0.06 | 1.71 |
| 0.48 | 45.46 | 25.00 | 30.97 | 0.07 | 3.63 |
| 0.46 | 38.62 | 30.15 | 5.11 | 0.06 | 1.91 |
| 2.75 | 36.67 | 17.47 | 1.69 | 0.07 | 1.85 |
| 14.32 | 36.43 | 25.33 | 2.63 | 0.15 | 3.15 |
