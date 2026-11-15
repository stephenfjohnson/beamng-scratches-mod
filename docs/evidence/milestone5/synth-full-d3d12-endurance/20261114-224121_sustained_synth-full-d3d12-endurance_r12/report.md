# sustained - 20261114-224121_sustained_synth-full-d3d12-endurance_r12

_assisted roof scrape v2: additive translation to 4 m/s for 30 seconds, preserving internal node motion; real collisions_

Remaining queues: `{"bake": 0, "jobs": 0, "stamps": 0}`

Tuning: `scratches_paint.setDamageResolution(4096); scratches_paint.setBakeBudget(3); scratches_paint.setFlushInterval(0.05); scratches_paint.setCoverageCoalescing(false); scratches_paint.setPanelGrouping(true); scratches_paint.setSyntheticAnchors(true)`

Settled: False after 30.0 s - 2659 frames, 88.3 fps average from sampled wall intervals (background limiter lifted)
Went past upside down: True (lowest up-vector z -1.0)

## Marks

| contacts | passed filters | impacts | streams | stamps | projections | bakes | missed | jobs dropped | deferred frames |
|---|---|---|---|---|---|---|---|---|---|
| 16699 | 8610 | 74 | 574 | 127 | 200 | 220 | 0.0% | 0 | 0 |

Rejected contacts: PartExcluded 6038, BelowThresh 2027, NormalForce 24

Body materials: METAL 8566, PLASTIC 44

Surfaces: ASPHALT 8178, COBBLESTONE 432

## Cost

| | avg | p95 | max |
|---|---|---|---|
| painter (GE), ms/frame | 1.047 | 11.057 | 26.951 |
| whole frame, ms | 10.911 (p50) | 20.734 | 45.104 |
| all GE Lua, ms | | 11.927 | 28.203 |
| physics + vehicle Lua, ms | | 0.081 | 1.905 |
| render, ms | | 2.239 | |

- Painter frames over 4 ms: 220; worst flush (project + bake) 2.404 ms, worst composite 0.259 ms.
- Detector: 3.27 us per contact, 76.18 ms total, worst frame 0.718 ms (profiled; the timer adds a little).

### Worst frames

| t (s) | frame ms | painter ms | GE Lua ms | physics+VLUA ms | render ms |
|---|---|---|---|---|---|
| 0.48 | 45.10 | 26.06 | 28.20 | 0.11 | 2.66 |
| 11.75 | 35.81 | 25.71 | 1.30 | 0.07 | 1.64 |
| 0.59 | 35.59 | 24.12 | 26.52 | 0.17 | 2.20 |
| 0.46 | 34.60 | 26.95 | 2.66 | 0.05 | 1.86 |
| 17.55 | 33.82 | 22.95 | 1.27 | 0.05 | 1.90 |
