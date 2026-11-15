# sustained - 20261114-223717_sustained_synth-full-d3d12-warm_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.008 s - 2637 frames, 87.9 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16668 | 8313 | 82 | 639 | 161 | 269 | 291 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6291, BelowThresh 2040, NormalForce 24

Body materials: METAL 8289, PLASTIC 24

Surfaces: ASPHALT 7742, COBBLESTONE 571

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.362 | 11.502 | 29.281 |
| whole frame, ms | 10.851 (p50) | 22.135 | 36.806 |
| all GE Lua, ms | | 12.459 | 30.277 |
| physics + vehicle Lua, ms | | 0.082 | 1.11 |
| render, ms | | 2.195 | |

- Painter frames over 4 ms: 291; worst flush (project + bake) 1.647 ms, worst composite 0.146 ms.
- Detector: 2.977 us per contact, 71.815 ms total, worst frame 0.427 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 12.42 | 36.81 | 27.18 | 1.23 | 0.06 | 1.73 |
| 0.58 | 36.31 | 16.80 | 16.80 | 0.07 | 1.69 |
| 0.43 | 36.05 | 29.28 | 28.90 | 0.06 | 1.40 |
| 0.41 | 34.74 | 28.08 | 2.16 | 0.05 | 1.55 |
| 0.34 | 32.84 | 22.36 | 1.66 | 0.06 | 1.66 |
