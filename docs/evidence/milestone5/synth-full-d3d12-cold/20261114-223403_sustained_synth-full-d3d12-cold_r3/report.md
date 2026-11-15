# sustained - 20261114-223403_sustained_synth-full-d3d12-cold_r3

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `if scratches_detect then scratches_detect.setPaintEnabled(true) end; scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setProjectionBudget(6); scratches_paint.setLayerBudget(24); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.003 s - 2632 frames, 87.7 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 17598 | 9183 | 76 | 639 | 137 | 225 | 247 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 7676, BelowThresh 704, NormalForce 35

Body materials: METAL 9157, PLASTIC 26

Surfaces: ASPHALT 8252, COBBLESTONE 931

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.215 | 11.502 | 29.373 |
| whole frame, ms | 10.711 (p50) | 21.567 | 53.825 |
| all GE Lua, ms | | 12.465 | 30.553 |
| physics + vehicle Lua, ms | | 0.093 | 13.975 |
| render, ms | | 2.428 | |

- Painter frames over 4 ms: 247; worst flush (project + bake) 2.58 ms, worst composite 0.126 ms.
- Detector: 3.305 us per contact, 82.606 ms total, worst frame 0.581 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 22.25 | 53.82 | 25.09 | 2.39 | 0.06 | 1.65 |
| 22.23 | 43.64 | 0.37 | 0.90 | 13.98 | 2.19 |
| 22.38 | 41.33 | 7.35 | 1.69 | 0.37 | 1.60 |
| 22.36 | 41.28 | 0.32 | 2.24 | 9.25 | 2.02 |
| 22.32 | 38.52 | 19.92 | 1.71 | 1.24 | 1.88 |
