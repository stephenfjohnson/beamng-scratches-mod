# sustained - 20261114-223631_sustained_synth-full-d3d12-warm_r2

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.003 s - 2679 frames, 89.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16925 | 8636 | 38 | 565 | 82 | 138 | 166 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6107, BelowThresh 2171, NormalForce 11

Body materials: METAL 8584, PLASTIC 52

Surfaces: ASPHALT 8395, COBBLESTONE 241

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 0.794 | 6.037 | 30.859 |
| whole frame, ms | 10.883 (p50) | 16.67 | 37.788 |
| all GE Lua, ms | | 6.971 | 31.872 |
| physics + vehicle Lua, ms | | 0.082 | 1.286 |
| render, ms | | 2.438 | |

- Painter frames over 4 ms: 166; worst flush (project + bake) 1.885 ms, worst composite 0.116 ms.
- Detector: 3.292 us per contact, 76.774 ms total, worst frame 0.331 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.46 | 37.79 | 30.86 | 2.03 | 0.06 | 1.73 |
| 12.74 | 35.37 | 23.78 | 1.28 | 0.05 | 1.89 |
| 0.63 | 34.90 | 15.72 | 19.60 | 0.05 | 2.17 |
| 0.47 | 34.53 | 19.60 | 31.87 | 0.06 | 1.77 |
| 2.08 | 31.60 | 16.64 | 20.09 | 0.07 | 2.41 |
