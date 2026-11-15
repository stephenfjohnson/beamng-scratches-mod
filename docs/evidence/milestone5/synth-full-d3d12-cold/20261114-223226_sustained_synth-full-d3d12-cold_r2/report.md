# sustained - 20261114-223226_sustained_synth-full-d3d12-cold_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.002 s - 2708 frames, 90.2 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16175 | 7708 | 50 | 501 | 101 | 187 | 207 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6925, BelowThresh 1525, NormalForce 17

Body materials: METAL 7696, PLASTIC 12

Surfaces: ASPHALT 7354, COBBLESTONE 354

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.014 | 11.237 | 29.61 |
| whole frame, ms | 10.664 (p50) | 21.141 | 35.773 |
| all GE Lua, ms | | 12.14 | 30.676 |
| physics + vehicle Lua, ms | | 0.084 | 0.77 |
| render, ms | | 2.263 | |

- Painter frames over 4 ms: 207; worst flush (project + bake) 3.34 ms, worst composite 0.13 ms.
- Detector: 3.203 us per contact, 73.02 ms total, worst frame 0.602 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.45 | 35.77 | 29.61 | 2.59 | 0.05 | 1.74 |
| 0.34 | 34.52 | 24.25 | 1.70 | 0.08 | 1.82 |
| 0.46 | 34.40 | 19.41 | 30.68 | 0.06 | 1.89 |
| 16.39 | 34.21 | 22.77 | 1.11 | 0.06 | 1.94 |
| 4.03 | 33.62 | 23.39 | 2.59 | 0.10 | 2.35 |
